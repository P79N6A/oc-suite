//
//  _net_cache.m
//  consumer
//
//  Created by fallen.ink on 9/15/16.
//
//

#include <sys/socket.h>
#include <sys/xattr.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#import <SystemConfiguration/SCNetworkReachability.h>
#import <MacTypes.h>
#import "_net_cache.h"
#import "_net_cache_private.h"
#import "_net_date_parser.h"
#import "_net_download_operation.h"
#import "_vendor_zip.h"

#if USE_ASSERTS
#define ASSERT_NO_CONNECTION_WHEN_IN_OFFLINE_MODE_FOR_URL(url) NSAssert( [(url) isFileURL] || [self offlineMode] == NO, @"No connection should be opened if we're in offline mode - this seems like a bug")
#else
#define ASSERT_NO_CONNECTION_WHEN_IN_OFFLINE_MODE_FOR_URL(url) do{}while(0)
#endif

const double kAFCacheInfiniteFileSize = 0.0;
const double kAFCacheArchiveDelay = 30.0; // archive every 30s

extern NSString* const UIApplicationWillResignActiveNotification;

@interface _NetCache ()

@property (nonatomic, copy) NSString *context;
@property (nonatomic, strong) NSTimer *archiveTimer;
@property (nonatomic, assign) BOOL wantsToArchive;
@property (nonatomic, assign) BOOL connectedToNetwork;
@property (nonatomic, strong) NSOperationQueue *packageArchiveQueue;
@property (nonatomic, strong) NSOperationQueue *downloadOperationQueue;
@property (nonatomic, strong) NSString* version;
@property (nonatomic, assign, readonly) NSString* infoDictionaryPath;
@property (nonatomic, assign, readonly) NSString* metaDataDictionaryPath;
@property (nonatomic, assign, readonly) NSString* expireInfoDictionaryPath;

@end

@implementation _NetCache

@def_singleton( _NetCache )

#pragma mark - init methods

- (instancetype)init {
    if (self = [super init]) {
        [self initWithContext:nil];
        
        self.diskCacheDisplacementTresholdSize = kDefaultDiskCacheDisplacementTresholdSize;
    }
    
    return self;
}

- (void)initWithContext:(NSString *)context {
    {
        
#if TARGET_OS_IPHONE
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(serializeState)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(serializeState)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
#endif
        
        [self reinitialize];
        
        [self initMimeTypes];
    }
}

- (void)initialize {
    _offlineMode = NO;
    _wantsToArchive = NO;
    _connectedToNetwork = NO;
    _archiveInterval = kAFCacheArchiveDelay;
    _failOnStatusCodeAbove400 = YES;
    _cacheWithHashname = YES;
    _maxItemFileSize = kAFCacheInfiniteFileSize;
    _networkTimeoutIntervals.IMSRequest = kDefaultNetworkTimeoutIntervalIMSRequest;
    _networkTimeoutIntervals.GETRequest = kDefaultNetworkTimeoutIntervalGETRequest;
    _networkTimeoutIntervals.PackageRequest = kDefaultNetworkTimeoutIntervalPackageRequest;
    _totalRequestsForSession = 0;
    _packageArchiveQueue = [[NSOperationQueue alloc] init];
    [_packageArchiveQueue setMaxConcurrentOperationCount:1];
    
    _downloadOperationQueue = [[NSOperationQueue alloc] init];
    [_downloadOperationQueue setMaxConcurrentOperationCount:kAFCacheDefaultConcurrentConnections];
    
    if (!_dataPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *appId = [@"afcache" stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
        _dataPath = [[[paths objectAtIndex: 0] stringByAppendingPathComponent: appId] copy];
    }
    
    [self deserializeState];
    
    /* check for existence of cache directory */
    if ([[NSFileManager defaultManager] fileExistsAtPath:_dataPath]) {
        LOG(@ "Successfully unarchived cache store");
    } else {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:_dataPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
            LOG(@ "Failed to create cache directory at path %@: %@", _dataPath, [error description]);
        } else {
            NSString *dataPath = _dataPath;
            if ([[dataPath pathComponents] containsObject:@"Library"]) {
                while (![[dataPath lastPathComponent] isEqualToString:@"Library"] && ![[dataPath lastPathComponent] isEqualToString:@"Caches"]) {
                    [_NetCache addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:dataPath]];
                    dataPath = [dataPath stringByDeletingLastPathComponent];
                }
            }
        }
    }
    
    [_NetCache addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:_dataPath]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDataPath:(NSString*)newDataPath {
    if (self.context && self.dataPath) {
        NSLog(@"Error: Can't change data path on instanced AFCache");
        NSAssert(NO, @"Can't change data path on instanced AFCache");
        return;
    }
    if (self.wantsToArchive) {
        [self serializeState];
    }
    _dataPath = [newDataPath copy];
    double fileSize = self.maxItemFileSize;
    [self reinitialize];
    self.maxItemFileSize = fileSize;
}

- (int)concurrentConnections {
    return (int)[self.downloadOperationQueue maxConcurrentOperationCount];
}

- (void)setConcurrentConnections:(int)maxConcurrentConnections {
    [self.downloadOperationQueue setMaxConcurrentOperationCount:maxConcurrentConnections];
}

// The method reinitialize really initializes the cache.
// This is usefull for testing, when you want to, uh, reinitialize

- (void)reinitialize {
    if (self.wantsToArchive) {
        [self serializeState];
    }
    [self cancelAllDownloads];
    
    [self initialize];
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1 || TARGET_OS_MAC && MAC_OS_X_VERSION_MIN_ALLOWED < MAC_OS_X_VERSION_10_8
    if (![[NSFileManager defaultManager] fileExistsAtPath:[URL path]]) {
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey: NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        NSLog(@"Error excluding %@ from backup: %@", [URL lastPathComponent], error);
    }
    return success;
#else
    NSLog(@"ERROR: System does not support excluding files from backup");
    return NO;
#endif
}

// remove all cache entries are not in a given set
- (void)doHousekeepingWithRequiredCacheItemURLs:(NSSet*)requiredURLs {
    NSMutableSet *fileNames = [NSMutableSet set];
    
    NSMutableDictionary* cacheInfoForFileName = [NSMutableDictionary dictionary];
    for (NSURL* cacheURL in requiredURLs) {
        _NetCacheRequest *item = [self cacheableRequestFromCacheStore:cacheURL];
        if (item.info) {
            NSString* fileName = item.info.filename;
            [fileNames addObject:fileName];
            [cacheInfoForFileName setObject:item.info forKey:fileName];
        }
        
    }
    [fileNames addObject:kAFCachePackageInfoDictionaryFilename];
    [fileNames addObject:kAFCacheMetadataFilename];
    [fileNames addObject:kAFCacheExpireInfoDictionaryFilename];
    NSSet* fileNameSet = [NSSet setWithSet:fileNames];
    __block NSMutableArray* urlsToRemove = [NSMutableArray array];
    [self performBlockOnAllCacheFiles:^(NSURL *url) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            NSLog(@"ERROR: cleanup encountered error: %@", error);
        }
        else if (! [isDirectory boolValue]) {
            NSString* fileName = [url lastPathComponent];
            if(![fileNameSet containsObject:[fileName stringByDeletingPathExtension]])
            {
                [urlsToRemove addObject:url];
            }
        }
    }];
    for (NSURL* url in urlsToRemove) {
        [self removeCacheEntryAndFileForFileURL:url];
    }
}
- (void)performBlockOnAllCacheFiles:(void (^)(NSURL* url))cacheItemActionBlock {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *directoryURL = [NSURL fileURLWithPath:self.dataPath];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:nil
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             NSLog(@"ERROR: encountered error while processing all cache files: %@", error);
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator) {
        cacheItemActionBlock(url);
    }
}

// remove all expired cache entries
// TODO: exchange with a better displacement strategy
- (void)doHousekeeping {
    if ([self offlineMode]) return; // don't cleanup if we're in offline mode
    unsigned long size = [self diskCacheSize];
    if (size < self.diskCacheDisplacementTresholdSize) return;
    NSDate *now = [NSDate date];
    NSArray *keys = nil;
    NSString *key = nil;
    for (_NetCacheRequestInfo *info in [self.cachedItemInfos allValues]) {
        if (info.expireDate && info.expireDate == [now earlierDate:info.expireDate]) {
            keys = [self.cachedItemInfos allKeysForObject:info];
            if ([keys count] > 0) {
                key = [keys objectAtIndex:0];
                [self removeCacheEntry:info fileOnly:NO];
                NSString* fullPath = [self.dataPath stringByAppendingPathComponent:key];
                [self removeCacheEntryWithFilePath:fullPath fileOnly:NO];
            }
        }
    }
}

- (void)removeCacheEntryWithFilePath:(NSString *)filePath fileOnly:(BOOL)fileOnly {
    // TODO: Implement me or remove me (I am called in doHousekeeping)
    NSLog(@"TODO: Implement me or remove me (I am called in doHousekeeping)");
}

- (unsigned long)diskCacheSize {
#define MINBLOCK 4096
    NSDictionary				*fattrs;
    NSDirectoryEnumerator		*de;
    unsigned long               size = 0;
    
    de = [[NSFileManager defaultManager]
          enumeratorAtPath:self.dataPath];
    
    while([de nextObject]) {
        fattrs = [de fileAttributes];
        if (![[fattrs valueForKey:NSFileType]
              isEqualToString:NSFileTypeDirectory]) {
            size += ((([[fattrs valueForKey:NSFileSize] unsignedIntValue] +
                       MINBLOCK - 1) / MINBLOCK) * MINBLOCK);
        }
    }
    return size;
}

#pragma mark - Query

- (BOOL)hasCachedRequestForURL:(NSURL *)url {
    _NetCacheRequest *request = [self cacheableRequestFromCacheStore:url];
    if (request) {
        return nil != request.data;
    }
    
    return NO;
}

- (_NetCacheRequest *)cacheableRequestFromCacheForURL:(NSURL *)url {
    _NetCacheRequest *request = [self cacheableRequestFromCacheStore:url];
    
    // check validity of cached item
    // TODO: (Claus Weymann:) validate this check (does this ensure that we continue downloading but also detect corrupt files?)
    if (![request isDataLoaded] && ([request hasDownloadFileAttribute] || ![request hasValidContentLength]) && ![self isDownloadingURL:url]) {
        // Claus Weymann: item is not vailid and not allready being downloaded, set item to nil to trigger download
        request = nil;
    }
    
    return request;
}

- (NSURL *)urlOrRedirectURLInOfflineModeForURL:(NSURL *)url
                                    redirected:(BOOL *)redirected {
    *redirected = NO;
    if ([self offlineMode]) {
        // In offline mode we change the request URL to the redirected URL (if any)
        // TODO: Michael Markowski has left this comment (I don't know if it still holds true):
        // AFAIU redirects of type 302 MUST NOT be cached
        // since we do not distinguish between 301 and 302 or other types of redirects, nor save the status code anywhere
        // we simply only check the cached redirects if we're in offline mode
        // see http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html 13.4 Response Cacheability
        NSString *redirectURL = [self.urlRedirects valueForKey:[url absoluteString]];
        if (redirectURL) {
            url = [NSURL URLWithString: redirectURL];
            *redirected = YES;
        }
    }
    return url;
}

- (_NetCacheRequest *)cachedRequestForURL:(NSURL *)url
                      urlCredential:(NSURLCredential *)urlCredential
                    completionBlock:(NetCacheRequestBlock)completionBlock
                          failBlock:(NetCacheRequestBlock)failBlock
{
    // delegate to our internal method
    return [self _internalCachedRequestForURL:url
                                urlCredential:urlCredential
                              completionBlock:completionBlock
                                    failBlock:failBlock
                                progressBlock:nil
                         requestConfiguration:nil];
}

- (_NetCacheRequest *)cachedRequestForURL:(NSURL *)url
                            urlCredential:(NSURLCredential *)urlCredential
                          completionBlock:(NetCacheRequestBlock)completionBlock
                                failBlock:(NetCacheRequestBlock)failBlock
                            progressBlock:(NetCacheRequestBlock)progressBlock {
    // delegate to our internal method
    return [self _internalCachedRequestForURL:url
                                 urlCredential:urlCredential
                               completionBlock:completionBlock
                                     failBlock:failBlock
                                 progressBlock:progressBlock
                          requestConfiguration:nil];
}

- (_NetCacheRequest *)cachedRequestForURL:(NSURL *)url
                            urlCredential:(NSURLCredential *)urlCredential
                          completionBlock:(NetCacheRequestBlock)completionBlock
                                failBlock:(NetCacheRequestBlock)failBlock
                            progressBlock:(NetCacheRequestBlock)progressBlock
                     requestConfiguration:(_NetCacheRequestConfiguration *)requestConfiguration
{
    // delegate to our internal method
    return [self _internalCachedRequestForURL:url
                                urlCredential:urlCredential
                              completionBlock:completionBlock
                                    failBlock:failBlock
                                progressBlock:progressBlock
                         requestConfiguration:requestConfiguration];
}

- (_NetCacheRequest *)_internalCachedRequestForURL:(NSURL *)url
                                     urlCredential:(NSURLCredential *)urlCredential
                                   completionBlock:(NetCacheRequestBlock)completionBlock
                                         failBlock:(NetCacheRequestBlock)failBlock
                                     progressBlock:(NetCacheRequestBlock)progressBlock
                              requestConfiguration:(_NetCacheRequestConfiguration *)requestConfiguration {
    // validate URL and handle invalid url
    if (![self isValidRequestURL:url]) {
        [self handleInvalidURLRequest:failBlock];
        return nil;
    }
    
    if ([url isFileURL]) {
        _NetCacheRequest *shortCircuitItem = [[_NetCacheRequest alloc] init];
        shortCircuitItem.url = url;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
            shortCircuitItem.data = [NSData dataWithContentsOfURL: url];
            if (completionBlock) {
                completionBlock(shortCircuitItem);
            }
        }
        else {
            if (failBlock) {
                failBlock(shortCircuitItem);
            }
        }
        
        return shortCircuitItem;
    }
    
    // increase count of request in this session
    _totalRequestsForSession++;
    
    // extract option-parts from requestConfiguration.options
    BOOL invalidateCacheEntry = (requestConfiguration.options & kAFCacheInvalidateEntry) != 0;
    BOOL revalidateCacheEntry = (requestConfiguration.options & kAFCacheRevalidateEntry) != 0;
    BOOL justFetchHTTPHeader = (requestConfiguration.options & kAFCacheJustFetchHTTPHeader) != 0;
    BOOL isPackageArchive = (requestConfiguration.options & kAFCacheIsPackageArchive) != 0;
    BOOL neverRevalidate = (requestConfiguration.options & kAFCacheNeverRevalidate) != 0;
    BOOL returnFileBeforeRevalidation = (requestConfiguration.options & kAFCacheReturnFileBeforeRevalidation) != 0;
    
    // Update URL with redirected URL if in offline mode
    BOOL didRewriteURL = NO; // the request URL might be rewritten by the cache internally when we're in offline mode
    url = [self urlOrRedirectURLInOfflineModeForURL:url redirected:&didRewriteURL];
    
    // try to get object from disk
    _NetCacheRequest *request = nil;
    if (!invalidateCacheEntry) {
        request = [self cacheableRequestFromCacheForURL:url];
    }
    
    BOOL performGETRequest = NO; // will be set to YES if we're online and have a cache miss
    
    if (!request) {
        // if we are in offline mode and do not have a cached version, so return nil
        if (!url.isFileURL && [self offlineMode]) {
            if (failBlock) {
                failBlock(nil);
            }
            return nil;
        }
        
        // we're online - create a new item, since we had a cache miss
        request = [[_NetCacheRequest alloc] init];
        performGETRequest = YES;
    }
    
    // setup item
    request.tag = self.totalRequestsForSession;
    request.url = url;
    request.userData = requestConfiguration.userData;
    request.urlCredential = urlCredential;
    request.justFetchHTTPHeader = justFetchHTTPHeader;
    request.isPackageArchive = isPackageArchive;
    request.URLInternallyRewritten = didRewriteURL;
    request.servedFromCache = !performGETRequest;
    request.info.request = requestConfiguration.request;
    request.hasReturnedCachedItemBeforeRevalidation = NO;
    
    if (!self.cacheWithHashname) {
        request.info.filename = [self filenameForURL:request.url];
    }
    
    [request addCompletionBlock:completionBlock failBlock:failBlock progressBlock:progressBlock];
    
    if (performGETRequest) {
        // TODO: Why do we cache the item here? Nothing has been downloaded yet?
        [self.cachedItemInfos setObject:request.info forKey:[url absoluteString]];
        
        [self addItemToDownloadQueue:request];
        return request;
    } else {
        // object found in cache.
        // now check if it is fresh enough to serve it from disk.
        // pretend it's fresh when cache is in offline mode
        request.servedFromCache = YES;
        
        if (![self isConnectedToNetwork] || ([self offlineMode] && !revalidateCacheEntry)) {
            // return item and call delegate only if fully loaded
            if (request.data) {
                if (completionBlock) {
                    completionBlock(request);
                }
                return request;
            }
            
            if (![self isQueuedOrDownloadingURL:request.url]) {
                if ([request hasValidContentLength] && !request.canMapData) {
                    // Perhaps the item just can not be mapped.
                    if (completionBlock) {
                        completionBlock(request);
                    }
                    return request;
                }
                
                // nobody is downloading, but we got the item from the cachestore.
                // Something is wrong -> fail
                if (failBlock) {
                    failBlock(request);
                }
                return nil;
            }
        }
        
        request.isRevalidating = revalidateCacheEntry;
        
        // Check if item is fully loaded already
        if (request.canMapData && !request.data && ![request hasValidContentLength]) {
            [self addItemToDownloadQueue:request];
            return request;
        }
        
        // Item is fresh, so call didLoad selector and return the cached item.
        if ([request isFresh] || returnFileBeforeRevalidation || neverRevalidate) {
            request.cacheStatus = NetCacheStatusFresh;
#ifdef RESUMEABLE_DOWNLOAD
            if(request.currentContentLength < request.info.contentLength) {
                //resume download
                request.cacheStatus = NetCacheStatusDownloading;
                [self handleDownloadItem:item ignoreQueue:shouldIgnoreQueue];
            }
#else
            request.currentContentLength = request.info.contentLength;
            if (completionBlock) {
                completionBlock(request);
            }
            LOG(@"serving from cache: %@", request.url);
#endif
            if (returnFileBeforeRevalidation) {
                request.hasReturnedCachedItemBeforeRevalidation = YES;
            } else {
                return request;
            }
            //item.info.responseTimestamp = [NSDate timeIntervalSinceReferenceDate];
        }
        
        // Item is not fresh, fire an If-Modified-Since request
        //#ifndef RESUMEABLE_DOWNLOAD
        // reset data, because there may be old data set already
        request.data = nil;//will cause the data to be reloaded from file when accessed next time
        //#endif
        
        // save information that object was in cache and has to be revalidated
        request.cacheStatus = NetCacheStatusRevalidationPending;
        
        NSMutableURLRequest *IMSRequest = [NSMutableURLRequest requestWithURL:url
                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                              timeoutInterval:self.networkTimeoutIntervals.IMSRequest];
        
        NSDate *lastModified = [NSDate dateWithTimeIntervalSinceReferenceDate: [request.info.lastModified timeIntervalSinceReferenceDate]];
        [IMSRequest addValue:[_NetDateParser formatHTTPDate:lastModified] forHTTPHeaderField:kHTTPHeaderIfModifiedSince];
        [IMSRequest setValue:@"" forHTTPHeaderField:AFCacheInternalRequestHeader];
        
        if (request.info.eTag) {
            [IMSRequest addValue:request.info.eTag forHTTPHeaderField:kHTTPHeaderIfNoneMatch];
        }
        else {
            NSDate *lastModified = [NSDate dateWithTimeIntervalSinceReferenceDate:
                                    [request.info.lastModified timeIntervalSinceReferenceDate]];
            // TODO: Why do we overwrite the existing header field here already set above?
            [IMSRequest addValue:[_NetDateParser formatHTTPDate:lastModified] forHTTPHeaderField:kHTTPHeaderIfModifiedSince];
        }
        
        request.IMSRequest = IMSRequest;
        ASSERT_NO_CONNECTION_WHEN_IN_OFFLINE_MODE_FOR_URL(IMSRequest.URL);
        
        [self addItemToDownloadQueue:request];
    }
    
    return request;
}

#pragma mark - synchronous request methods

/*
 * performs a synchroneous request
 *
 */

- (_NetCacheRequest *)cachedObjectForURLSynchronous:(NSURL *)url {
    return [self cachedObjectForURLSynchronous:url options:0];
}

- (_NetCacheRequest *)cachedObjectForURLSynchronous:(NSURL *)url
                                            options:(int)options {
    
#if MAINTAINER_WARNINGS
    //#warning BK: this is in support of using file urls with ste-engine - no info yet for shortCircuiting
#endif
    if( [url isFileURL] ) {
        _NetCacheRequest *shortCircuitItem = [[_NetCacheRequest alloc] init];
        shortCircuitItem.data = [NSData dataWithContentsOfURL: url];
        return shortCircuitItem;
    }
    
    bool invalidateCacheEntry = (options & kAFCacheInvalidateEntry) != 0;
    _NetCacheRequest *obj = nil;
    if (url) {
        // try to get object from disk if cache is enabled
        if (!invalidateCacheEntry) {
            obj = [self cacheableRequestFromCacheStore: url];
        }
        // Object not in cache. Load it from url.
        if (!obj) {
            NSURLResponse *response = nil;
            NSError *err = nil;
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
            // The synchronous request will indirectly invoke AFURLCache's
            // storeCachedResponse:forRequest: and add a cacheable item
            // accordingly.
            
            ASSERT_NO_CONNECTION_WHEN_IN_OFFLINE_MODE_FOR_URL(url);
            
            NSData *data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &err];
            if ([response respondsToSelector: @selector(statusCode)]) {
                NSInteger statusCode = [( (NSHTTPURLResponse *)response )statusCode];
                if (statusCode != 200 && statusCode != 304) {
                    return nil;
                }
            }
            // If request was successful there should be a cacheable item now.
            if (data) {
                obj = [self cacheableRequestFromCacheStore: url];
            }
        }
    }
    return obj;
}

#pragma mark - URL cache state testing

- (BOOL)isQueuedOrDownloadingURL: (NSURL*)url {
    return ([self isQueuedURL:url] || [self isDownloadingURL:url]);
}

- (BOOL)isDownloadingURL:(NSURL *)url {
    return ([[self nonCancelledDownloadOperationForURL:url] isExecuting]);
}

- (_NetDownloadOperation *)nonCancelledDownloadOperationForURL:(NSURL*)url {
    for (_NetDownloadOperation *downloadOperation in [self.downloadOperationQueue operations]) {
        if (![downloadOperation isCancelled] && [[downloadOperation.cacheableItem.url absoluteString] isEqualToString:[url absoluteString]]) {
            return downloadOperation;
        }
    }
    return nil;
}

#pragma mark - State (de-)serialization

- (void)serializeState {
    @synchronized (self.archiveTimer) {
        [self.archiveTimer invalidate];
        self.wantsToArchive = NO;
        [self serializeState:[self stateDictionary]];
    }
}

- (NSDictionary*)stateDictionary {
    return @{kAFCacheInfoStoreCachedObjectsKey : self.cachedItemInfos,
             kAFCacheInfoStoreRedirectsKey : self.urlRedirects,
             kAFCacheInfoStorePackageInfosKey : self.packageInfos,
             kAFCacheVersionKey : self.version?:@"",
             };
}

//TODO: state dictionary bundles information about state but is not serialized (persisted) as such. it  splits into parts and serializes some of the information. why?
- (void)serializeState:(NSDictionary*)state {
    @autoreleasepool {
#if AFCACHE_LOGGING_ENABLED
        AFLog(@"start archiving");
        CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
#endif
        @synchronized(self)
        {
            @autoreleasepool {
                if (self.totalRequestsForSession % kHousekeepingInterval == 0) [self doHousekeeping];
                
                NSDictionary *infoStore = @{
                                            kAFCacheInfoStoreCachedObjectsKey : state[kAFCacheInfoStoreCachedObjectsKey],
                                            kAFCacheInfoStoreRedirectsKey : state[kAFCacheInfoStoreRedirectsKey]};
                [self saveDictionary:infoStore ToFile:self.expireInfoDictionaryPath];
                
                NSDictionary* packageInfos = [state valueForKey:kAFCacheInfoStorePackageInfosKey];
                [self saveDictionary:packageInfos ToFile:self.infoDictionaryPath];
                
                NSDictionary* metaData = @{kAFCacheVersionKey:[state valueForKey:kAFCacheVersionKey]};
                [self saveDictionary:metaData ToFile:self.metaDataDictionaryPath];
            }
        }
#if AFCACHE_LOGGING_ENABLED
        AFLog(@"Finish archiving in %f", CFAbsoluteTimeGetCurrent() - start);
#endif
    }
}

- (void)saveDictionary:(NSDictionary *)dictionary ToFile:(NSString *)fileName {
    NSData *serializedData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    if (serializedData) {
        NSError *error = nil;
#if TARGET_OS_IPHONE
        NSDataWritingOptions options = NSDataWritingAtomic | NSDataWritingFileProtectionNone;
#else
        NSDataWritingOptions options = NSDataWritingAtomic;
#endif
        if (![serializedData writeToFile:fileName options:options error:&error]) {
            NSLog(@"Error: Could not write dictionary to file '%@': Error = %@, infoStore = %@", fileName, error, dictionary);
        }
        [_NetCache addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:fileName]];
    } else {
        NSLog(@"Error: Could not archive dictionary %@", dictionary);
    }
}

- (void)deserializeState {
    // Deserialize cacheable item info store
    NSDictionary *archivedExpireDates = [NSKeyedUnarchiver unarchiveObjectWithFile: self.expireInfoDictionaryPath];
    NSMutableDictionary *cachedItemInfos = [archivedExpireDates objectForKey:kAFCacheInfoStoreCachedObjectsKey];
    NSMutableDictionary *urlRedirects = [archivedExpireDates objectForKey:kAFCacheInfoStoreRedirectsKey];
    if (cachedItemInfos && urlRedirects) {
        _cachedItemInfos = [NSMutableDictionary dictionaryWithDictionary:cachedItemInfos];
        _urlRedirects = [NSMutableDictionary dictionaryWithDictionary: urlRedirects];
        LOG(@ "Successfully unarchived expires dictionary");
    } else {
        _cachedItemInfos = [NSMutableDictionary dictionary];
        _urlRedirects = [NSMutableDictionary dictionary];
        LOG(@ "Created new expires dictionary");
    }
    
    // Deserialize package infos
    NSDictionary *archivedPackageInfos = [NSKeyedUnarchiver unarchiveObjectWithFile: self.infoDictionaryPath];
    if (archivedPackageInfos) {
        _packageInfos = [NSMutableDictionary dictionaryWithDictionary: archivedPackageInfos];
        LOG(@ "Successfully unarchived package infos dictionary");
    }
    else {
        _packageInfos = [[NSMutableDictionary alloc] init];
        LOG(@ "Created new package infos dictionary");
    }
    
    // Deserialize metaData
    
    NSDictionary* metaData = [NSKeyedUnarchiver unarchiveObjectWithFile: self.metaDataDictionaryPath];
    if ([metaData isKindOfClass:[NSDictionary class]]) {
        TODO("做迁移")
//        [self migrateFromVersion:metaData[kAFCacheVersionKey]];
    } else {
        TODO("做迁移")
//        [self migrateFromVersion:nil];
    }
}

- (void)startArchiveThread:(NSTimer*)timer {
    self.wantsToArchive = NO;
    NSMutableDictionary* state = [NSMutableDictionary dictionaryWithDictionary: [self stateDictionary]];
    
    // Copy state items as they shall not be altered when state is persisted
    // TODO: This copy code must be synchronized with state modifications
    for (id key in [state allKeys]) {
        NSObject *stateItem = [state objectForKey:key];
        [state setObject:[stateItem copy] forKey:key];
    }
    
    [NSThread detachNewThreadSelector:@selector(serializeState:)
                             toTarget:self
                           withObject:state];
}

- (void)archive {
    @synchronized (self.archiveTimer) {
        [self.archiveTimer invalidate];
        if (self.archiveInterval > 0) {
            self.archiveTimer = [NSTimer scheduledTimerWithTimeInterval:[self archiveInterval]
                                                                 target:self
                                                               selector:@selector(startArchiveThread:)
                                                               userInfo:nil
                                                                repeats:NO];
        }
        self.wantsToArchive = YES;
    }
}

- (void)archiveNow {
    @synchronized (self.archiveTimer) {
        [self.archiveTimer invalidate];
        [self startArchiveThread:nil];
        [self archive];
    }
}

/* removes every file in the cache directory */
- (void)invalidateAll {
    NSError *error;
    
    /* remove the cache directory and its contents */
    if (![[NSFileManager defaultManager] removeItemAtPath: self.dataPath error: &error]) {
        NSLog(@ "Failed to remove cache contents at path: %@", self.dataPath);
        //return; If there was no old directory we for sure want a new one...
    }
    
    /* create a new cache directory */
    if (![[NSFileManager defaultManager] createDirectoryAtPath: self.dataPath
                                   withIntermediateDirectories: NO
                                                    attributes: nil
                                                         error: &error]) {
        NSLog(@ "Failed to create new cache directory at path: %@", self.dataPath);
        return; // this is serious. we need this directory.
    }
    self.cachedItemInfos = [NSMutableDictionary dictionary];
    self.urlRedirects = [NSMutableDictionary dictionary];
    [self archive];
}

- (NSString *)filenameForURL:(NSURL *) url {
    return [self filenameForURLString:[url absoluteString]];
}

- (NSString *)filenameForURLString:(NSString *)URLString {
#ifdef AFCACHE_MAINTAINER_WARNINGS
#warning TODO cleanup
#endif
    if ([URLString hasPrefix:@"data:"]) return nil;
    NSString *filepath = [URLString stringByRegex:@".*://" substitution:@""];
    NSString *filepath1 = [filepath stringByRegex:@":[0-9]?*/" substitution:@""];
    NSString *filepath2 = [filepath1 stringByRegex:@"#.*" substitution:@""];
    NSString *filepath3 = [filepath2 stringByRegex:@"\?.*" substitution:@""];
    NSString *filepath4 = [filepath3 stringByRegex:@"//*" substitution:@"/"];
    
    
    if (self.cacheWithoutUrlParameter) {
        NSArray *comps = [filepath4 componentsSeparatedByString:@"?"];
        if (comps) {
            filepath4 = [comps objectAtIndex:0];
        }
    }
    
    if (self.cacheWithoutHostname) {
        NSMutableArray *pathComps = [NSMutableArray arrayWithArray:[filepath4 pathComponents]];
        if (pathComps) {
            [pathComps removeObjectAtIndex:0];
            
            return [NSString pathWithComponents:pathComps];
        }
    }
    
    return filepath4;
}

- (NSString *)filePath: (NSString *) filename {
    return [self.dataPath stringByAppendingPathComponent: filename];
}

- (NSString *)filePathForFilename:(NSString *)filename pathExtension:(NSString *)pathExtension {
    if (!pathExtension) {
        return [self filePath:filename];
    } else {
        return [[self.dataPath stringByAppendingPathComponent:filename] stringByAppendingPathExtension:pathExtension];
    }
}

- (NSString *)filePathForURL: (NSURL *) url {
    return [self.dataPath stringByAppendingPathComponent: [self filenameForURL: url]];
}

- (NSString *)fullPathForCacheableItem:(_NetCacheRequest *)item {
    if (!item) {
        return nil;
    }
    
    NSString *fullPath;
    if (!self.cacheWithHashname) {
        return [self filePathForURL:item.url];
    } else {
#if USE_ASSERTS
        NSAssert([item.info.filename length] > 0, @"Filename length MUST NOT be zero! This is a software bug");
#endif
        return [self filePathForFilename:item.info.filename pathExtension:[item.url pathExtension]];
    }
}

- (void)removeCacheEntry:(_NetCacheRequestInfo *)info fileOnly:(BOOL)fileOnly {
    [self removeCacheEntry:info fileOnly:fileOnly fallbackURL:nil];
}

- (void)removeCacheEntry:(_NetCacheRequestInfo *)info fileOnly:(BOOL) fileOnly fallbackURL:(NSURL *)fallbackURL; {
    if (!info) {
        return;
    }
    // remove redirects to this entry
    for (id redirectKey in [self.urlRedirects allValues]) {
        if ([redirectKey isKindOfClass:[NSString class]]) {
            id redirectTarget = [self.urlRedirects objectForKey:redirectKey];
            if ([redirectTarget isKindOfClass:[NSString class]]) {
                if([redirectTarget isEqualToString:[info.request.URL absoluteString]])
                {
                    [self.urlRedirects removeObjectForKey:redirectKey];
                }
            }
            
        }
    }
    
    NSString *filePath = nil;
    if (!self.cacheWithHashname) {
        filePath = [self filePathForURL:info.request.URL];
    } else {
        if (fallbackURL) {
            filePath = [self filePathForFilename:info.filename pathExtension:[fallbackURL pathExtension]];
        } else {
            filePath = [self filePathForFilename:info.filename pathExtension:[info.request.URL pathExtension]];
        }
    }
    
    BOOL fileNonExistentOrDeleted = [self deleteFileAtPath:filePath];
    
    if (!fileOnly && (fileNonExistentOrDeleted)) {
        if (fallbackURL) {
            [self.cachedItemInfos removeObjectForKey:[fallbackURL absoluteString]];
        }
        else {
            NSURL* requestURL = [info.request URL];
            if (requestURL) {
                [self.cachedItemInfos removeObjectForKey:[requestURL absoluteString]];
            }
        }
    }
}

// TODO: 移动到 sandbox
- (void)removeCacheEntryAndFileForFileURL:(NSURL*)fileURL {
    TODO("// TODO: 移动到 sandbox")
    NSSet* results = [self.cachedItemInfos keysOfEntriesPassingTest:^BOOL(id key, id evaluatedObject, BOOL *stop) {
        if ([evaluatedObject isKindOfClass:[_NetCacheRequestInfo class]]) {
            return [((_NetCacheRequestInfo *)evaluatedObject).filename isEqualToString:[[fileURL lastPathComponent] stringByDeletingPathExtension]];
        }
        return NO;
    }];
    
    if ([results count] > 0) {
        //delete file and entry for files with corresponding infos (should only be one)
        for (NSString* key in results) {
            _NetCacheRequestInfo *info = self.cachedItemInfos[key];
            [self removeCacheEntry:info fileOnly:NO fallbackURL:[NSURL URLWithString:key]];
        }
    } else {
        NSError* error = nil;
        if(![[NSFileManager defaultManager] removeItemAtURL:fileURL error: &error]) {
            LOG(@"WARNING: failed to delete orphaned cache file at %@ with error : %@", fileURL, error);
        }
    }
}

- (BOOL)deleteFileAtPath:(NSString*)filePath {
    BOOL successfullyDeletedFile = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSError* error = nil;
    if (fileExists) {
        successfullyDeletedFile = [[NSFileManager defaultManager] removeItemAtPath: filePath error: &error];
        if (!successfullyDeletedFile) {
            LOG(@"ERROR: failed to delete file %@ because of error: %@", filePath, error);
        } else {
            LOG(@ "Successfully removed item at %@", filePath);
        }
    }
    return (!fileExists) || successfullyDeletedFile;
}

#pragma mark - internal core methods

- (void)updateModificationDataAndTriggerArchiving:(_NetCacheRequest *)cacheableItem {
    NSError *error = nil;
    NSString *filePath = [self fullPathForCacheableItem:cacheableItem];
    
    /* reset the file's modification date to indicate that the URL has been checked */
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDate date], NSFileModificationDate, nil];
    
    if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:filePath error:&error]) {
        LOG(@"Failed to reset modification date for cache item %@", filePath);
    }
    [self archive];
}

- (NSOutputStream*)createOutputStreamForItem:(_NetCacheRequest *)cacheableItem {
    NSString *filePath = [self fullPathForCacheableItem: cacheableItem];
    
    // remove file if exists
    if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
        [self removeCacheEntry:cacheableItem.info fileOnly:YES];
        LOG(@"removing %@", filePath);
    }
    
    // create directory if not exists
    NSString *pathToDirectory = [filePath stringByDeletingLastPathComponent];
    BOOL isDirectory = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToDirectory isDirectory:&isDirectory] || !isDirectory) {
        NSError* error = nil;
        if (!isDirectory) {
            if (![[NSFileManager defaultManager] removeItemAtPath:pathToDirectory error:&error]) {
                LOG(@"AFCache: Could not remove directory \"%@\" (Error: %@)", pathToDirectory, [error localizedDescription]);
            }
        }
        if ( [[NSFileManager defaultManager] createDirectoryAtPath:pathToDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            LOG(@"creating directory %@", pathToDirectory);
            [_NetCache addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:pathToDirectory]];
        } else {
            LOG(@"Failed to create directory at path %@", pathToDirectory);
        }
    }
    
    // write file
    if (self.maxItemFileSize == kAFCacheInfiniteFileSize || cacheableItem.info.contentLength < self.maxItemFileSize) {
        /* file doesn't exist, so create it */
#if TARGET_OS_IPHONE
        NSDictionary *fileAttributes = @{NSFileProtectionKey:NSFileProtectionNone};
#else
        NSDictionary *fileAttributes = nil;
#endif
        if (![[NSFileManager defaultManager] createFileAtPath:filePath
                                                     contents:nil
                                                   attributes:fileAttributes]) {
            LOG(@"Error: could not create file \"%@\"", filePath);
        }
        
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        [_NetCache addSkipBackupAttributeToItemAtURL:fileURL];
        
        NSOutputStream *outputStream = [[NSOutputStream alloc] initWithURL:fileURL append:NO];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream open];
        return outputStream;
    } else {
        LOG(@ "AFCache: item %@ \nsize exceeds maxItemFileSize (%f). Won't write file to disk",cacheableItem.url, self.maxItemFileSize);
        [self.cachedItemInfos removeObjectForKey: [cacheableItem.url absoluteString]];
        return nil;
    }
}

- (BOOL)_fileExistsOrPendingForCacheableItem:(_NetCacheRequest *)item {
    if (![self isValidRequestURL:item.url]) {
        return NO;
    }
    
    // the complete path
    NSString *filePath = [self fullPathForCacheableItem:item];
    
    LOG(@"checking for file at path %@", filePath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
        // file doesn't exist. check if someone else is downloading the url already
        if ([self isQueuedOrDownloadingURL:item.url]) {
            LOG(@"Someone else is already downloading the URL: %@.", [item.url absoluteString]);
        } else {
            LOG(@"Cache miss for URL: %@.", [item.url absoluteString]);
            return NO;
        }
    }
    return YES;
}

// If the file exists on disk we return a new AFCacheableItem for it,
// but it may be only half loaded yet.
- (_NetCacheRequest *)cacheableRequestFromCacheStore:(NSURL *)URL {
    if (![self isValidRequestURL:URL]) {
        return nil;
    }
    
    if ([[URL absoluteString] hasPrefix:@"data:"]) {
        return nil;
    }
    
    _NetCacheRequestInfo *info = [self.cachedItemInfos objectForKey: [URL absoluteString]];
    if (!info) {
        NSString *redirectURLString = [self.urlRedirects valueForKey:[URL absoluteString]];
        info = [self.cachedItemInfos objectForKey: redirectURLString];
    }
    if (!info) {
        return nil;
    }
    
    LOG(@"Cache hit for URL: %@", [URL absoluteString]);
    
    // check if there is an item in pendingConnections
    _NetCacheRequest *cacheableItem;
    _NetDownloadOperation *downloadOperation = [self nonCancelledDownloadOperationForURL:URL];
    if ([downloadOperation isExecuting]) {
        // TODO: This concept of AFCache was broken: Returning a running download request does not conform to this method's name
        cacheableItem = downloadOperation.cacheableItem;
    } else {
        cacheableItem = [[_NetCacheRequest alloc] init];
        cacheableItem.cache = self;
        cacheableItem.url = URL;
        cacheableItem.info = info;
        cacheableItem.currentContentLength = 0;//info.contentLength;
        
        if (!self.cacheWithHashname)
        {
            cacheableItem.info.filename = [self filenameForURL:cacheableItem.url];
        }
        
        // check if file is valid
        
        /*  ======>
         *
         *  This is the place where we check if the URL is already in the queue
         *
         *  TODO: Remove comment as soon as all that internal method got cleaned up
         *
         *  <======
         */
        
        
        BOOL fileExistsOrPending = [self _fileExistsOrPendingForCacheableItem:cacheableItem];
        if (!fileExistsOrPending) {
            // Something went wrong
            LOG(@"Cache info store out of sync for url %@, removing cached file %@.", [URL absoluteString], [self fullPathForCacheableItem:cacheableItem]);
            // TODO: The concept is broken here. Why are we going to delete a file that obviously DOES NOT EXIST? maybe it makes sense when the url is pending?
            [self removeCacheEntry:cacheableItem.info fileOnly:YES];
            cacheableItem = nil;
        }
        else
        {
            //make sure that we continue downloading by setting the length (currently done by reading out file lenth in the info.actualLength accessor)
            cacheableItem.info.cachePath = [self fullPathForCacheableItem:cacheableItem];
        }
    }
    
    // Update item's status
    if ([self offlineMode]) {
        cacheableItem.cacheStatus = NetCacheStatusFresh;
    }
    else if (cacheableItem.isRevalidating) {
        cacheableItem.cacheStatus = NetCacheStatusRevalidationPending;
    } else if (nil != cacheableItem.data || !cacheableItem.canMapData) {
        cacheableItem.cacheStatus = [cacheableItem isFresh] ? NetCacheStatusFresh : NetCacheStatusStale;
    }
    
    return cacheableItem;
}

#pragma mark - Cancel requests on cache

- (void)cancelAllRequestsForURL:(NSURL *)url {
    if (!url) {
        return;
    }
    for (_NetDownloadOperation *downloadOperation in [self.downloadOperationQueue operations]) {
        if ([[downloadOperation.cacheableItem.url absoluteString] isEqualToString:[url absoluteString]]) {
            [downloadOperation cancel];
        }
    }
}

- (void)cancelAsynchronousOperationsForURL:(NSURL *)url itemDelegate:(id)itemDelegate {
    if (!url || !itemDelegate) {
        return;
    }
    for (_NetDownloadOperation *downloadOperation in [self.downloadOperationQueue operations]) {
        if ((downloadOperation.cacheableItem.delegate == itemDelegate) && ([[downloadOperation.cacheableItem.url absoluteString] isEqualToString:[url absoluteString]])) {
            [downloadOperation cancel];
        }
    }
}

- (void)cancelAsynchronousOperationsForDelegate:(id)itemDelegate {
    if (!itemDelegate) {
        return;
    }
    
    for (_NetDownloadOperation *downloadOperation in [self.downloadOperationQueue operations]) {
        if (downloadOperation.cacheableItem.delegate == itemDelegate) {
            [downloadOperation cancel];
        }
    }
}

- (void)cancelAllDownloads {
    [self.downloadOperationQueue cancelAllOperations];
}

- (BOOL)isQueuedURL:(NSURL*)url {
    _NetDownloadOperation *downloadOperation = [self nonCancelledDownloadOperationForURL:url];
    return downloadOperation && !([downloadOperation isExecuting] || [downloadOperation isFinished]);
}

- (void)prioritizeURL:(NSURL*)url {
    [[self nonCancelledDownloadOperationForURL:url] setQueuePriority:NSOperationQueuePriorityVeryHigh];
}

/**
 * Add the item to the downloadQueue
 */
- (void)addItemToDownloadQueue:(_NetCacheRequest *)item {
    if ([self offlineMode]) {
        [item sendFailSignalToClientItems];
        return;
    }
    
    //check if we can download
    if (![item.url isFileURL] && [self offlineMode]) {
        //we can not download this item at the moment
        [item sendFailSignalToClientItems];
        return;
    }
    
    // check if we are downloading already
    if ([self isDownloadingURL: item.url])
    {
        // don't start another connection
        LOG(@"We are downloading already. Won't start another connection for %@", item.url);
        return;
    }
    
    NSURLRequest *theRequest = item.info.request;
    
    // no original request, check if we want to send an IMS request
    if (!theRequest) {
        theRequest = item.IMSRequest;
    }
    // this is a reqular request, create a new one
    if (!theRequest) {
        NSTimeInterval timeout = item.isPackageArchive ? self.networkTimeoutIntervals.PackageRequest : self.networkTimeoutIntervals.GETRequest;
        theRequest = [NSMutableURLRequest requestWithURL: item.url
                                             cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval: timeout];
    }
    
    if ([theRequest isKindOfClass:[NSMutableURLRequest class]])
    {
#ifdef RESUMEABLE_DOWNLOAD
        uint64_t dataAlreadyDownloaded = item.info.actualLength;
        NSString* rangeToDownload = [NSString stringWithFormat:@"%lld-",dataAlreadyDownloaded];
        uint64_t expectedFileSize = item.info.contentLength;
        if(expectedFileSize > 0)
            rangeToDownload = [rangeToDownload stringByAppendingFormat:@"%lld",expectedFileSize];
        AFLog(@"range %@",rangeToDownload);
        [(NSMutableURLRequest*)theRequest setValue:rangeToDownload forHTTPHeaderField:@"Range"];
#endif
        [(NSMutableURLRequest*)theRequest setValue:@"" forHTTPHeaderField:AFCacheInternalRequestHeader];
    }
    
    item.info.requestTimestamp = [NSDate timeIntervalSinceReferenceDate];
    item.info.responseTimestamp = 0.0;
    item.info.request = theRequest;
    
    ASSERT_NO_CONNECTION_WHEN_IN_OFFLINE_MODE_FOR_URL(theRequest.URL);
    
    _NetDownloadOperation *downloadOperation = [[_NetDownloadOperation alloc] initWithCacheableItem:item];
    [self.downloadOperationQueue addOperation:downloadOperation];
}

- (BOOL)hasCachedItemForURL:(NSURL *)url {
    _NetCacheRequest *item = [self cacheableRequestFromCacheStore:url];
    if (item) {
        return nil != item.data;
    }
    
    return NO;
}


#pragma mark - offline mode & pause methods

- (BOOL)suspended {
    return [self.downloadOperationQueue isSuspended];
}

- (void)setSuspended:(BOOL)pause {
    [self.downloadOperationQueue setSuspended:pause];
    [self.packageArchiveQueue setSuspended:pause];
    
    // TODO: Do we really need to cancel already running downloads? If not, just remove the following lines
    if (pause) {
        // TODO: Cancel current downloads and add running download operations to a list...
    }
    else {
        // TODO: ...whose items are now added back to the queue with highest priority to start downloading them again
    }
}

/*
 * Returns whether we currently have a working connection
 * Note: This should be done asynchronously, i.e. use
 * SCNetworkReachabilityScheduleWithRunLoop and let it update our information.
 */
- (BOOL)isConnectedToNetwork  {
    // Create zero address
    struct sockaddr_in zeroAddress;
    bzero( &zeroAddress, sizeof(zeroAddress) );
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        //NSLog(@"Error. Could not recover network reachability flags\n");
        return 0;
    }
    BOOL isReachable = (flags & kSCNetworkFlagsReachable) == kSCNetworkFlagsReachable;
    BOOL needsConnection = (flags & kSCNetworkFlagsConnectionRequired) == kSCNetworkFlagsConnectionRequired;
    
    return isReachable && !needsConnection;
}

- (void)setConnectedToNetwork:(BOOL)connected {
    if (_connectedToNetwork != connected) {
        [self willChangeValueForKey:@"connectedToNetwork"];
        _connectedToNetwork = connected;
        [self didChangeValueForKey:@"connectedToNetwork"];
    }
}

#pragma mark - Helper

/**
 * @return is that url valid to be requested
 */
- (BOOL)isValidRequestURL:(NSURL *)url {
    // url should not be nil nor having a zero length, also it must have a scheme
    return [[url absoluteString] length] > 0 && [[url scheme] length] > 0;
}

/**
 *
 */
- (void)handleInvalidURLRequest:(NetCacheRequestBlock)failBlock {
    NSError *error = [NSError errorWithDomain:@"URL is not set" code:-1 userInfo:nil];
    
    _NetCacheRequest *item = [[_NetCacheRequest alloc] init];
    item.error = error;
    
    if (failBlock) {
        failBlock(item);
    }
}
#pragma mark helper

- (NSString *)infoDictionaryPath {
    return [self.dataPath stringByAppendingPathComponent:kAFCachePackageInfoDictionaryFilename];
}

- (NSString *)metaDataDictionaryPath {
    return [self.dataPath stringByAppendingPathComponent:kAFCacheMetadataFilename];
}

- (NSString *)expireInfoDictionaryPath {
    return [self.dataPath stringByAppendingPathComponent:kAFCacheExpireInfoDictionaryFilename];
}

@end

#pragma mark - 

@implementation _NetCache (Packaging)

enum ManifestKeys {
    ManifestKeyURL = 0,
    ManifestKeyLastModified = 1,
    ManifestKeyExpires = 2,
    ManifestKeyMimeType = 3,
    ManifestKeyFilename = 4,
};

//- (_NetCacheRequest *)requestPackageArchive:(NSURL *)url delegate:(id)aDelegate {
//    _NetCacheRequest *item = [self cachedObjectForURL:url
//                                            delegate:aDelegate
//                                            selector:@selector(packageArchiveDidFinishLoading:)
//                                     didFailSelector:@selector(packageArchiveDidFailLoading:)
//                                             options:kAFCacheIsPackageArchive | kAFCacheRevalidateEntry
//                                            userData:nil
//                                            username:nil
//                                            password:nil request:nil];
//    return item;
//}
//
//- (_NetCacheRequest *)requestPackageArchive:(NSURL *)url
//                                   delegate:(id)aDelegate
//                                   username:(NSString *)username
//                                   password:(NSString *)password {
//    _NetCacheRequest *item = [self cachedObjectForURL: url
//                                            delegate: aDelegate
//                                            selector: @selector(packageArchiveDidFinishLoading:)
//                                     didFailSelector:  @selector(packageArchiveDidFailLoading:)
//                                             options: kAFCacheIsPackageArchive | kAFCacheRevalidateEntry
//                                            userData: nil
//                                            username: username
//                                            password: password request:nil];
//    return item;
//}

- (void)packageArchiveDidFinishLoading: (_NetCacheRequest *) cacheableItem {
    if ([cacheableItem.delegate respondsToSelector:@selector(packageArchiveDidFinishLoading:)]) {
        [cacheableItem.delegate performSelector:@selector(packageArchiveDidFinishLoading:) withObject:cacheableItem];
    }
}

- (void)unzipWithArguments:(NSDictionary *)arguments {
    @autoreleasepool {
        
        LOG(@"starting to unzip archive");
        
        // get arguments from dictionary
        NSString *pathToZip				= arguments[@"pathToZip"];
        _NetCacheRequest *cacheableItem	= arguments[@"cacheableItem"];
        __unsafe_unretained NSString* urlCacheStorePath = arguments[@"urlCacheStorePath"];
        BOOL preservePackageInfo		= [arguments[@"preservePackageInfo"] boolValue];
        NSDictionary *userData			= arguments[@"userData"];
        
        ZipArchive *zip = [[ZipArchive alloc] init];
        BOOL success = [zip UnzipOpenFile:pathToZip];
        [zip UnzipFileTo:[pathToZip stringByDeletingLastPathComponent] overWrite:YES];
        [zip UnzipCloseFile];
        if (success) {
            __unsafe_unretained NSString *pathToManifest = [NSString stringWithFormat:@"%@/%@", urlCacheStorePath, @"manifest.afcache"];
            
            __unsafe_unretained _NetPackageInfo *packageInfo;
            __unsafe_unretained NSURL *itemURL = cacheableItem.url;
            
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(newPackageInfoByImportingCacheManifestAtPath:intoCacheStoreWithPath:withPackageURL:)]];
            [inv setTarget:self];
            [inv setSelector:@selector(newPackageInfoByImportingCacheManifestAtPath:intoCacheStoreWithPath:withPackageURL:)];
            
            // if you have arguments, set them up here
            // starting at 2, since 0 is the target and 1 is the selector
            [inv setArgument:&pathToManifest atIndex:2];
            [inv setArgument:&urlCacheStorePath atIndex:3];
            [inv setArgument:&itemURL atIndex:4];
            
            [inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
            
            [inv getReturnValue:&packageInfo];
            
            // store information about the imported items
            if (preservePackageInfo) {
                [packageInfo.userData addEntriesFromDictionary:userData];
                [self.packageInfos setObject:packageInfo forKey:[cacheableItem.url absoluteString]];
            }
            else {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:pathToZip error:&error];
            }
            
            if (((id)cacheableItem.delegate) == self) {
                NSAssert(false, @"you may not assign the AFCache singleton as a delegate.");
            }
            
            [self performSelectorOnMainThread:@selector(performArchiveReadyWithItem:)
                                   withObject:cacheableItem
                                waitUntilDone:YES];
            
            [self performSelectorOnMainThread:@selector(archive) withObject:nil waitUntilDone:YES];
            LOG(@"finished unzipping archive");
        } else {
            LOG(@"Unzipping failed. Broken archive?");
            [self performSelectorOnMainThread:@selector(performUnarchivingFailedWithItem:)
                                   withObject:cacheableItem
                                waitUntilDone:YES];
        }
    }
}

- (_NetPackageInfo *)newPackageInfoByImportingCacheManifestAtPath:(NSString *)manifestPath
                                           intoCacheStoreWithPath:(NSString *)urlCacheStorePath withPackageURL:(NSURL*)packageURL {
    
    NSError *error = nil;
    _NetCacheRequestInfo *info = nil;
    NSString *URL = nil;
    NSString *lastModified = nil;
    NSString *expires = nil;
    NSString *mimeType = nil;
    NSString *filename = nil;
    int line = 0;
    
    // create a package info object for this package
    // that enables the cache to keep track of items that have been included in a package
    _NetPackageInfo *packageInfo = [[_NetPackageInfo alloc] init];
    packageInfo.packageURL = packageURL;
    
    NSMutableArray *resourceURLs = [[NSMutableArray alloc] init];
    
    //NSString *pathToMetaFolder = [NSString stringWithFormat:@"%@/%@", urlCacheStorePath, @".userdata"];
    NSString *manifest = [NSString stringWithContentsOfFile:manifestPath encoding:NSASCIIStringEncoding error:&error];
    NSArray *entries = [manifest componentsSeparatedByString:@"\n"];
    
    NSMutableDictionary* cacheInfoDictionary = [NSMutableDictionary dictionary];
    _NetDateParser* dateParser = [[_NetDateParser alloc] init];
    for (NSString *entry in entries) {
        line++;
        if ([entry length] == 0) {
            continue;
        }
        
        NSArray *values = [entry componentsSeparatedByString:@" ; "];
        if ([values count] == 0) continue;
        if ([values count] < 5) {
            NSArray *keyval = [entry componentsSeparatedByString:@" = "];
            if ([keyval count] == 2) {
                NSString *key_ = [keyval objectAtIndex:0];
                NSString *val_ = [keyval objectAtIndex:1];
                if ([@"baseURL" isEqualToString:key_]) {
                    packageInfo.baseURL = [NSURL URLWithString:val_];
                }
            } else {
                NSLog(@"Invalid entry in manifest in line %d: %@", line, entry);
            }
            continue;
        }
        info = [[_NetCacheRequestInfo alloc] init];
        
        // parse url
        URL = [values objectAtIndex:ManifestKeyURL];
        
        // parse last-modified
        lastModified = [values objectAtIndex:ManifestKeyLastModified];
        info.lastModified = [dateParser gh_parseHTTP:lastModified];
        
        // parse expires
        expires = [values objectAtIndex:ManifestKeyExpires];
        info.expireDate = [dateParser gh_parseHTTP:expires];
        
        mimeType = [values objectAtIndex:ManifestKeyMimeType];
        
        if( 0 == [mimeType length] || [mimeType isEqualToString:@"NULL"] ) {
            mimeType = nil;
        } else {
            info.mimeType = mimeType;
        }
        
        filename = [values objectAtIndex:ManifestKeyFilename];
        if ([filename length] > 0 && ![filename isEqualToString:@"NULL"]) {
            info.filename = filename;
        } else {
            NSLog(@"No filename given for entry in line %d: %@", line, entry);
        }
        
        uint64_t contentLength = [self setContentLengthForFileAtPath:[urlCacheStorePath stringByAppendingPathComponent: filename]];
        
        info.contentLength = contentLength;
        
#if MAINTAINER_WARNINGS
#warning BK: textEncodingName always nil here
#endif
        
        info.response = [[NSURLResponse alloc] initWithURL: [NSURL URLWithString: URL]
                                                  MIMEType:mimeType
                                     expectedContentLength: contentLength
                                          textEncodingName: nil];
        
        [resourceURLs addObject:URL];
        
        [cacheInfoDictionary setObject:info forKey:URL];
    }
    
    packageInfo.resourceURLs = [NSArray arrayWithArray:resourceURLs];
    
    // import generated cacheInfos in to the AFCache info store
    [self storeCacheInfo:cacheInfoDictionary];
    
    return packageInfo;
}

- (void)storeCacheInfo:(NSDictionary*)dictionary {
    @synchronized(self) {
        for (NSString* key in dictionary) {
            _NetCacheRequestInfo* info = [dictionary objectForKey:key];
            [self.cachedItemInfos setObject:info forKey:key];
        }
    }
}

#pragma mark serialization methods

- (void)performArchiveReadyWithItem:(_NetCacheRequest *)cacheableItem
{
    cacheableItem.info.packageArchiveStatus = NetCachePackageArchiveStatusConsumed;
}

- (void)performUnarchivingFailedWithItem:(_NetCacheRequest *)cacheableItem
{
    cacheableItem.info.packageArchiveStatus = NetCachePackageArchiveStatusUnarchivingFailed;
}

#pragma mark - import

// import and optionally overwrite a cacheableitem. might fail if a download with the very same url is in progress.
- (BOOL)cacheRequest:(_NetCacheRequest *)request withData:(NSData *)theData {
    if (request == nil || [self isQueuedOrDownloadingURL:request.url]) {
        return NO;
    }
    
    [request setDataAndFile:theData];
    
    [self.cachedItemInfos setObject:request.info forKey:[request.url absoluteString]];
    
    [self archive];
    
    return YES;
}

- (BOOL)cacheRequest:(_NetCacheRequest *)request dataWithFileAtURL:(NSURL *)URL {
    if (request == nil ||
        [self isQueuedOrDownloadingURL:request.url]) {
        return NO;
    }
    
    NSString *fullPathForCacheableItem = [self fullPathForCacheableItem:request];
    NSError *error = nil;
    BOOL didMoveItemAtPath = [[NSFileManager defaultManager] moveItemAtPath:URL.path
                                                                     toPath:fullPathForCacheableItem
                                                                      error:&error];
    if (!didMoveItemAtPath) {
        return NO;
    }
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:fullPathForCacheableItem]
                                         options:NSDataReadingMappedIfSafe
                                           error:nil];
    request.data = data;
    request.info.contentLength = [data length];
    
    [self.cachedItemInfos setObject:request.info forKey:[request.url absoluteString]];
    [self archive];
    
    return YES;
}

- (_NetCacheRequest *)cacheRequestForURL:(NSURL *)url data:(NSData *)data {
    _NetCacheRequest *cachedRequest = [self cacheableRequestFromCacheStore:url];
    if (cachedRequest) {
        return cachedRequest;
    } else {
        _NetCacheRequest *request = [[_NetCacheRequest alloc] initWithURL:url lastModified:[NSDate date] expireDate:nil];
        
        [self cacheRequest:request withData:data];
        
        return request;
    }
}

- (_NetCacheRequest *)cacheRequestForURL:(NSURL *)url dataWithFileAtURL:(NSURL*)URL {
    _NetCacheRequest *cachedRequest = [self cacheableRequestFromCacheStore:url];
    if (cachedRequest) {
        return cachedRequest;
    } else {
        _NetCacheRequest *request = [[_NetCacheRequest alloc] initWithURL:url lastModified:[NSDate date] expireDate:nil];
        [self cacheRequest:request dataWithFileAtURL:url];
        return request;
    }
}

- (void)purgeCacheableItemForURL:(NSURL *)url {
    if (!url) {
        return;
    }
    _NetCacheRequestInfo *cacheableItemInfo = [self.cachedItemInfos valueForKey:[url absoluteString]];
    [self removeCacheEntry:cacheableItemInfo fileOnly:NO fallbackURL:url];
}

- (void)purgePackageArchiveForURL:(NSURL *)url {
    [self purgeCacheableItemForURL:url];
}

- (NSString *)userDataPathForPackageArchiveKey:(NSString *)archiveKey {
    if (archiveKey == nil) {
        return [NSString stringWithFormat:@"%@/%@", self.dataPath, kAFCacheUserDataFolder];
    } else {
        return [NSString stringWithFormat:@"%@/%@/%@", self.dataPath, kAFCacheUserDataFolder, archiveKey];
    }
}

// Return package information for package with urlstring as key
- (_NetPackageInfo *)packageInfoForURL:(NSURL*)url {
    NSString *key = [url absoluteString];
    return [self.packageInfos valueForKey:key];
}

@end

#pragma mark - 

@implementation _NetCache (FileAttributes)

- (uint64_t)setContentLengthForFileAtPath:(NSString*)filePath {
    NSError* err = nil;
    NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&err];
    if (err) {
        LOG(@"Could not get file attributes for %@", filePath);
        return 0;
    }
    uint64_t fileSize = [attrs fileSize];
    if (0 != setxattr(filePath.fileSystemRepresentation, kAFCacheContentLengthFileAttribute, &fileSize, sizeof(fileSize), 0, 0)) {
        LOG(@"Could not set content length for file %@", filePath);
        return 0;
    }
    return fileSize;
}

@end

#pragma mark - 

@implementation _NetCache ( MimeType )

// TODO: This method should not be realized within a category as this category is private anyway
- (void)initMimeTypes {
    // TODO: Assign to _suffixToMimeTypeMap as this is a init method (as soon as this method goes to main implementation file)
    self.suffixToMimeTypeMap = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"application/msword",				        @".doc",
                                @"application/msword",						@".dot",
                                @"application/vnd.ms-excel",			    @".xls",
                                @"application/vnd.ms-excel",				@".xlt",
                                @"text/comma-separated-values",             @".csv",
                                @"text/tab-separated-values",               @".tab",
                                @"text/tab-separated-values",				@".tsv",
                                @"application/vnd.ms-powerpoint",           @".ppt",
                                @"application/vnd.ms-project",              @".mpp",
                                @"application/vnd.ms-works",                @".wps",
                                @"application/vnd.ms-works",				@".wdb",
                                @"application/x-visio",                     @".vsd",
                                @"application/x-visio",                     @".vst",
                                @"application/x-visio",						@".vsw",
                                @"application/wordperfect",                 @".wpd",
                                @"application/wordperfect",                 @".wp5",
                                @"application/wordperfect",					@".wp6",
                                @"application/rtf",                         @".rtf",
                                @"text/plain",                              @".txt",
                                @"text/plain",							    @".text",
                                @"text/html",                               @".html",
                                @"text/html",						        @".htm",
                                @"application/hta",                         @".hta",
                                @"message/rfc822",						    @".mime",
                                @"text/xml",                                @".xml",
                                @"text/xml",                                @".xsl",
                                @"text/xml",		                        @".xslt",
                                @"application/xhtml+xml",                   @".html",
                                @"application/xhtml+xml",                   @".xhtml",
                                @"application/xml-dtd",                     @".dtd",
                                @"application/xml-external-parsed-entity",  @".xml",
                                @"text/sgml",                               @".sgm",
                                @"text/sgml",                               @".sgml",
                                @"text/css",                                @".css",
                                @"text/javascript",                         @".js",
                                @"application/x-javascript",                @".ls",
                                @"image/gif",		                        @".gif",
                                @"image/jpeg",                              @".jpg",
                                @"image/jpeg",                              @".jpeg",
                                @"image/jpeg",						        @".jpe",
                                @"image/png",							    @".png",
                                @"image/tiff",                              @".tif",
                                @"image/tiff",                              @".tiff",
                                @"image/bmp",                               @".bmp",
                                @"image/x-pict",                            @".pict",
                                @"image/x-icon",                            @".ico",
                                @"image/x-icon",                            @".icl",
                                @"image/vnd.dwg",                           @".dwg",
                                @"audio/x-wav",                             @".wav",
                                @"audio/x-mpeg",                            @".mpa",
                                @"audio/x-mpeg",                            @".abs",
                                @"audio/x-mpeg",                            @".mpega",
                                @"audio/x-mpeg",                            @".mp3",
                                @"audio/x-mpeg-2",                          @".mp2a",
                                @"audio/x-mpeg-2",                          @".mpa2",
                                @"application/x-pn-realaudio",              @".ra",
                                @"application/x-pn-realaudio",              @".ram",
                                @"application/vnd.rn-realmedia",            @".rm",
                                @"audio/x-aiff",                            @".aif",
                                @"audio/x-aiff",                            @".aiff",
                                @"audio/x-aiff",                            @".aifc",
                                @"audio/x-midi",                            @".mid",
                                @"audio/x-midi",                            @".midi",
                                @"video/mpeg",                              @".mpeg",
                                @"video/mpeg",                              @".mpg",
                                @"video/mpeg",                              @".mpe",
                                @"video/mpeg-2",                            @".mpv2",
                                @"video/mpeg-2",                            @".mp2v",
                                @"video/quicktime",                         @".mov",
                                @"video/quicktime",                         @".moov",
                                @"video/x-msvideo",                         @".avi",
                                @"application/pdf",                         @".pdf",
                                @"application/postscript",                  @".ps",
                                @"application/postscript",                  @".ai",		
                                @"application/postscript",                  @".eps",		
                                @"application/zip",                         @".zip",		
                                @"application/x-compressed",                @".tar.gz",	
                                @"application/x-compressed",                @".tgz",		
                                @"application/x-gzip",                      @".gz",		
                                @"application/x-gzip",                      @".gzip",	
                                @"application/x-bzip2",                     @".bz2",		
                                @"application/x-stuffit",                   @".sit",		
                                @"application/x-stuffit",                   @".sea",		
                                @"application/mac-binhex40",                @".hqx",		
                                @"application/octet-stream",                @".bin",		
                                @"application/octet-stream",                @".uu",		
                                @"application/octet-stream",                @".exe",		
                                @"application/vnd.sun.xml.writer",          @".sxw",		
                                @"application/vnd.sun.xml.writer",          @".sxg",		
                                @"application/vnd.sun.xml.writer.template", @".sxw",		
                                @"application/vnd.sun.xml.calc",            @".sxc",		
                                @"application/vnd.sun.xml.calc.template",   @".stc",		
                                @"application/vnd.sun.xml.draw",            @".sxd",		
                                @"application/vnd.sun.xml.draw",            @".std",		
                                @"application/vnd.sun.xml.impress",         @".sxi",		
                                @"application/vnd.sun.xml.impress",			@".sti",		
                                @"application/vnd.stardivision.writer",     @".sdw",		
                                @"application/vnd.stardivision.writer",     @".sgl",		
                                @"application/vnd.stardivision.calc",       @".sdc",		
                                @"image/svg+xml",                           @".svg",
                                nil];	
}

@end

