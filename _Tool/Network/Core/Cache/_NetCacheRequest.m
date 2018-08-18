//
//  _net_cache_request.m
//  consumer
//
//  Created by fallen.ink on 9/21/16.
//
//

#import "_net_cache_request.h"
#import "_net_cache.h"
#import "_net_cache_private.h"
#import "_net_cache_request_info.h"
#import "_net_date_parser.h"

@interface _NetCacheRequest ()

@property NSMutableArray *completionBlocks;
@property NSMutableArray *failBlocks;
@property NSMutableArray *progressBlocks;
@property BOOL hasReturnedCachedItemBeforeRevalidation;

@end

@implementation _NetCacheRequest

@def_prop_singleton( _NetCache, cache)

- (instancetype)init {
    self = [super init];
    if (self) {
        _data = nil;
        _canMapData = YES;
        _cacheStatus = NetCacheStatusNew;
        _info = [[_NetCacheRequestInfo alloc] init];
        _IMSRequest = nil;
        _URLInternallyRewritten = NO;
        
        _completionBlocks = [NSMutableArray array];
        _failBlocks = [NSMutableArray array];
        _progressBlocks = [NSMutableArray array];
    }
    return self;
}

- (_NetCacheRequest *)initWithURL:(NSURL *)URL
                     lastModified:(NSDate *)lastModified
                       expireDate:(NSDate *)expireDate
                      contentType:(NSString *)contentType
{
    self = [self init];
    if (self) {
        _info = [[_NetCacheRequestInfo alloc] init];
        _info.lastModified = lastModified;
        _info.expireDate = expireDate;
        _info.mimeType = contentType;
        _url = URL;
        _cacheStatus = NetCacheStatusFresh;
        _validUntil = _info.expireDate;
        self.cache = [_NetCache sharedInstance];
    }
    return self;
}

- (_NetCacheRequest *)initWithURL:(NSURL *)URL
                   lastModified:(NSDate *)lastModified
                     expireDate:(NSDate *)expireDate {
    return [self initWithURL:URL lastModified:lastModified expireDate:expireDate contentType:nil];
}

- (void)addCompletionBlock:(NetCacheRequestBlock)completionBlock
                 failBlock:(NetCacheRequestBlock)failBlock
             progressBlock:(NetCacheRequestBlock)progressBlock {
    @synchronized (self) {
        if (completionBlock) {
            [self.completionBlocks addObject:completionBlock];
        }
        if (failBlock) {
            [self.failBlocks addObject:failBlock];
        }
        if (progressBlock) {
            [self.progressBlocks addObject:progressBlock];
        }
        
    }
}

- (void)removeBlocks {
    @synchronized (self) {
        [self.completionBlocks removeAllObjects];
        [self.failBlocks removeAllObjects];
        [self.progressBlocks removeAllObjects];
    }
}

- (void)performBlocks:(NSArray*)blocks {
    @synchronized (self) {
        blocks = [blocks copy];
    }
    for (NetCacheRequestBlock block in blocks) {
        block(self);
    }
}

- (NSData*)data {
    if (!_data) {
        
        if (!self.cache.skipValidContentLengthCheck && ![self hasValidContentLength]) {
            return nil;
        }
        
        NSString* filePath = [self.cache fullPathForCacheableItem:self];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return nil;
        }
        
        NSError* error = nil;
        _data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
        if (!_data) {
            LOG(@"Error: Could not map file %@ because of error: %@", filePath, error);
        }
        _canMapData = (_data != nil);
    }
    
    return _data;
}

- (void)sendFailSignalToClientItems {
    if (self.isPackageArchive) {
        // TODO: Setting a status does not conform to method's name
        self.info.packageArchiveStatus = NetCachePackageArchiveStatusLoadingFailed;
    }
    
    [self performBlocks:self.failBlocks];
}

- (void)sendSuccessSignalToClientItems {
    if (self.isPackageArchive) {
        // TODO: Setting a status does not conform to method's name
        if (self.info.packageArchiveStatus == NetCachePackageArchiveStatusUnknown) {
            self.info.packageArchiveStatus = NetCachePackageArchiveStatusLoaded;
        }
    }
    [self performBlocks:self.completionBlocks];
}

- (void)sendProgressSignalToClientItems {
    [self performBlocks:self.progressBlocks];
}

/*
 * calculate freshness of object according to algorithm in rfc2616
 * http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html
 *
 * age_value
 *      is the value of Age: header received by the cache with this response.
 * date_value
 *      is the value of the origin server's Date: header
 * request_time
 *      is the (local) time when the cache made the request that resulted in this cached response
 * response_time
 *      is the (local) time when the cache received the response
 * now
 *      is the current (local) time
 */

- (BOOL)isFresh {
    NSTimeInterval apparent_age = fmax(0, self.info.responseTimestamp - [self.info.serverDate timeIntervalSinceReferenceDate]);
    NSTimeInterval corrected_received_age = fmax(apparent_age, self.info.age);
    NSTimeInterval response_delay = (self.info.responseTimestamp>0)?self.info.responseTimestamp - self.info.requestTimestamp:0;
    
    // A zero (or negative) response delay indicates a transfer or connection error.
    // This happened when the archiever started between request start and response.
    if (response_delay < 0) {
        NSLog(@"WARNING: response_delay must never be negative!");
        return NO;
    }
    
    NSTimeInterval corrected_initial_age = corrected_received_age + response_delay;
    NSTimeInterval resident_time = [NSDate timeIntervalSinceReferenceDate] - self.info.responseTimestamp;
    NSTimeInterval current_age = corrected_initial_age + resident_time;
    
    NSTimeInterval freshness_lifetime = 0;
    
    if (self.info.expireDate) {
        freshness_lifetime = [self.info.expireDate timeIntervalSinceReferenceDate] - [self.info.serverDate timeIntervalSinceReferenceDate];
    }
    
    // The max-age directive takes priority over Expires! Thanks, Serge ;)
    if (self.info.maxAge) {
        freshness_lifetime = [self.info.maxAge doubleValue];
    }
    
    // Note:
    // If none of Expires, Cache-Control: max-age, or Cache-Control: s- maxage (see section 14.9.3) appears in the response,
    // and the response does not include other restrictions on caching, the cache MAY compute a freshness lifetime using a heuristic.
    // The cache MUST attach Warning 113 to any response whose age is more than 24 hours if such warning has not already been added.
    
    BOOL fresh = (freshness_lifetime > current_age);
    LOG(@"freshness_lifetime: %@", [NSDate dateWithTimeIntervalSinceReferenceDate: freshness_lifetime]);
    LOG(@"current_age: %@", [NSDate dateWithTimeIntervalSinceReferenceDate: current_age]);
    
    return fresh;
}

- (BOOL)hasValidContentLength {
    NSString *filePath = [self.cache fullPathForCacheableItem:self];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return NO;
    }
    
    NSError *err = nil;
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&err];
    if (!attr) {
        LOG(@"Error getting file attributes: %@", err);
        return NO;
    }
    
    uint64_t fileSize = [attr fileSize];
    if (self.info.contentLength == 0 || fileSize != self.info.contentLength) {
        uint64_t realContentLength = [self getContentLengthFromFile];
        if (realContentLength == 0 || realContentLength != fileSize) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)isQueuedOrDownloading {
    return [self.cache isQueuedOrDownloadingURL:self.url];
}

- (NSString *)asString {
    if (!self.data) return nil;
    return [[NSString alloc] initWithData: self.data encoding: NSUTF8StringEncoding];
}

- (NSString*)description {
    NSMutableString *s = [NSMutableString stringWithString:@"URL: "];
    [s appendString:[self.url absoluteString]];
    [s appendString:@", "];
    [s appendFormat:@"tag: %d", self.tag];
    [s appendString:@", "];
    [s appendFormat:@"cacheStatus: %lu", (unsigned long)self.cacheStatus];
    [s appendString:@", "];
    [s appendFormat:@"body content size: %ld\n", (long)[self.data length]];
    [s appendString:[self.info description]];
    [s appendString:@"\n"];
    
    return s;
}

- (BOOL)isCachedOnDisk {
    return [self.cache.cachedItemInfos objectForKey: [self.url absoluteString]] != nil;
}

- (NSString *)guessContentType {
    NSString *extension = [self.url lastPathComponent];
    return [self.cache.suffixToMimeTypeMap valueForKey:extension];
}

- (BOOL)isComplete {
    //[[NSString alloc] initWithFormat:@"Item %@ has %lld of %lld data loaded, complete ? %d", self.info.filename, self.info.actualLength, self.info.contentLength,(self.currentContentLength >= self.info.contentLength)];
    //assumed complete if there is data and the actual data length is at least as big as the expected content length. (should be exactly the expected content length but sometimes there is no expected content lenght present; self.info.contentLength = 0)
    return [self isDataLoaded] && (self.info.actualLength >= self.info.contentLength);
}

- (BOOL)isDataLoaded {
    return self.info.actualLength > 0;
}

- (uint64_t)currentContentLength {
    return self.info.actualLength;
}

- (void)setCurrentContentLength:(uint64_t)contentLength {
    self.info.actualLength = contentLength;
}

- (BOOL)isDownloading {
    return [self.cache isDownloadingURL: self.url];
}

@end

#pragma mark -

@implementation _NetCacheRequest (Packaging)

- (NSString *)metaJSON {
    _NetDateParser *dateParser = [[_NetDateParser alloc] init];
    NSString *filename = self.info.filename;
//    _NetDateParser *parser = [[_NetDateParser alloc] init];
    NSMutableString *metaDescription = [NSMutableString stringWithFormat:@"{\"url\": \"%@\",\n\"file\": \"%@\",\n\"last-modified\": \"%@\", valid until: %@",
                                        self.url,
                                        filename,
                                        [dateParser formatHTTPDate:self.info.lastModified],
                                        [dateParser formatHTTPDate:self.validUntil]];
    if (self.validUntil) {
        [metaDescription appendFormat:@",\n\"expires\": \"%@\"", self.validUntil];
    }
    [metaDescription appendFormat:@"\n}"];
    return metaDescription;
}

- (NSString*)metaDescription {
    _NetDateParser* dateParser = [[_NetDateParser alloc] init];
    if (self.validUntil) {
        // TODO: A getter is not supposed to modify internal states. This is unexpected.
        self.validUntil = self.info.lastModified;
    }
    NSMutableString *metaDescription = [NSMutableString stringWithFormat:@"%@ ; %@ ; %@ ; %@ ; %@",
                                        self.url,
                                        [dateParser formatHTTPDate:self.info.lastModified],
                                        self.validUntil?[dateParser formatHTTPDate:self.validUntil]:@"NULL",
                                        self.info.mimeType?:@"NULL",
                                        self.info.filename];
    [metaDescription appendString:@"\n"];
    return metaDescription;
}

+ (NSString *)urlEncodeValue:(NSString *)str
{
    CFStringRef preprocessedString =CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)str, CFSTR(""), kCFStringEncodingUTF8);
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, preprocessedString, NULL, NULL, kCFStringEncodingUTF8);
    CFRelease(preprocessedString);
    return (__bridge NSString*)urlString;
}

- (void)setDataAndFile:(NSData*)data {
    self.data = data;
    self.info.contentLength = [data length];
    
    // Store data into file
    NSOutputStream *outputStream = [self.cache createOutputStreamForItem:self];
    if (outputStream.hasSpaceAvailable) {
        NSInteger bytesWritten = [outputStream write:data.bytes maxLength:data.length];
        if (bytesWritten != data.length) {
            if ([self.delegate respondsToSelector:@selector(cannotWriteDataForItem:)]) {
                [self.delegate cannotWriteDataForItem:self];
            }
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(cannotWriteDataForItem:)]) {
            [self.delegate cannotWriteDataForItem:self];
        }
    }
    [outputStream close];
    
    [self flagAsDownloadFinishedWithContentLength:data.length];
}

@end

#pragma mark - 

#include <sys/xattr.h>

const char *kAFCacheContentLengthFileAttribute = "de.artifacts.contentLength";
const char *kAFCacheDownloadingFileAttribute = "de.artifacts.downloading";

@implementation _NetCacheRequest ( FileAttributes )

- (BOOL)hasDownloadFileAttribute {
    unsigned int downloading = 0;
    NSString *filePath = [self.cache fullPathForCacheableItem:self];
    return sizeof(downloading) == getxattr([filePath fileSystemRepresentation], kAFCacheDownloadingFileAttribute, &downloading, sizeof(downloading), 0, 0);
}

- (void)flagAsDownloadStartedWithContentLength:(uint64_t)contentLength {
    NSString *filePath = [self.cache fullPathForCacheableItem:self];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    if (0 != setxattr(filePath.fileSystemRepresentation, kAFCacheContentLengthFileAttribute, &contentLength, sizeof(uint64_t), 0, 0)) {
        LOG(@"Could not set contentLength attribute on %@", self);
    }
    unsigned int downloading = 1;
    if (0 != setxattr(filePath.fileSystemRepresentation, kAFCacheDownloadingFileAttribute, &downloading, sizeof(downloading), 0, 0)) {
        LOG(@"Could not set downloading attribute on %@", self);
    }
}

- (void)flagAsDownloadFinishedWithContentLength:(uint64_t)contentLength {
    NSString *filePath = [self.cache fullPathForCacheableItem:self];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    if (0 != setxattr(filePath.fileSystemRepresentation, kAFCacheContentLengthFileAttribute, &contentLength, sizeof(uint64_t), 0, 0)) {
        LOG(@"Could not set contentLength attribute on %@, errno = %ld", self, (long)errno );
    }
    if (0 != removexattr(filePath.fileSystemRepresentation, kAFCacheDownloadingFileAttribute, 0)) {
        LOG(@"Could not remove downloading attribute on %@, errno = %ld", self, (long)errno );
    }
}

- (uint64_t)getContentLengthFromFile {
    if ([self isQueuedOrDownloading]) {
        return 0LL;
    }
    
    NSString *filePath = [self.cache fullPathForCacheableItem:self];
    
    uint64_t realContentLength = 0LL;
    ssize_t const size = getxattr([filePath fileSystemRepresentation],
                                  kAFCacheContentLengthFileAttribute,
                                  &realContentLength,
                                  sizeof(realContentLength),
                                  0, 0);
    if (sizeof(realContentLength) != size) {
        LOG(@"Could not get content length attribute from file %@. This may be bad (errno = %ld", filePath, (long)errno);
        return 0LL;
    }
    return realContentLength;
}

@end
