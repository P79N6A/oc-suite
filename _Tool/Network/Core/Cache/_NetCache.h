//
//  _net_cache.h
//  consumer
//
//  Created by fallen.ink on 9/15/16.
//
//

#import "_greats.h"
#import "_net_cache_request.h"
#import "_net_cache_request_configuration.h"
#import "_net_package_info.h"

#pragma mark -

#define kAFCacheExpireInfoDictionaryFilename @"kAFCacheExpireInfoDictionary"
#define kAFCacheRedirectInfoDictionaryFilename @"kAFCacheRedirectInfoDictionary"
#define kAFCachePackageInfoDictionaryFilename @"afcache_packageInfos"
#define kAFCacheMetadataFilename @"afcache_metaData"

#define kAFCacheInfoStoreCachedObjectsKey @"cachedObjects"
#define kAFCacheInfoStoreRedirectsKey @"redirects"
#define kAFCacheInfoStorePackageInfosKey @"packageInfos"
#define kAFCacheVersionKey @"afcacheVersion"

#define LOG_AFCACHE(m) NSLog(m);

#define kAFCacheUserDataFolder @".userdata"

// max cache item size in bytes
#define kAFCacheDefaultMaxFileSize 1000000

// max number of concurrent connections
#define kAFCacheDefaultConcurrentConnections 5

#define kHTTPHeaderIfModifiedSince @"If-Modified-Since"
#define kHTTPHeaderIfNoneMatch @"If-None-Match"

//do housekeeping every nth time archive is called (per session)
#define kHousekeepingInterval 10

#define kDefaultDiskCacheDisplacementTresholdSize 100000000

#define kDefaultNetworkTimeoutIntervalIMSRequest 45
#define kDefaultNetworkTimeoutIntervalGETRequest 100
#define kDefaultNetworkTimeoutIntervalPackageRequest 100

#define kAFCacheNSErrorDomain @"AFCache"
#define USE_ASSERTS true

#define AFCachingURLHeader @"X-AFCache"
#define AFCacheInternalRequestHeader @"X-AFCache-IntReq"

extern const double kAFCacheInfiniteFileSize;

enum {
    kAFCacheInvalidateEntry         = 1 << 9,
    /* Returns cached file (if any) and then performs an IMS request (if file was already cached) or requests file for the first time (if not already cached).
     Option is ignored if kAFCacheNeverRevalidate is set. */
    kAFCacheReturnFileBeforeRevalidation = 1 << 10,
    kAFIgnoreError                  = 1 << 11,
    kAFCacheIsPackageArchive        = 1 << 12,
    kAFCacheRevalidateEntry         = 1 << 13, // revalidate even when cache is running in offline mode
    kAFCacheNeverRevalidate         = 1 << 14,
    kAFCacheJustFetchHTTPHeader     = 1 << 15, // just fetch the http header
};

typedef struct NetworkTimeoutIntervals {
    NSTimeInterval IMSRequest;
    NSTimeInterval GETRequest;
    NSTimeInterval PackageRequest;
} NetworkTimeoutIntervals;

#pragma mark -

@interface _NetCache : NSObject

@singleton( _NetCache )

/*
 * YES if offline mode is enabled (no files will be downloaded) or NO if disabled (default).
 */
/**
 * NOTE: "offline mode" means: Dear AFCache, please serve everything from cache without making any connections.
 * It does NOT mean that there's no internet connectivity. You may check this by calling "isConnectedToNetwork"]
 */
@property (nonatomic, assign) BOOL offlineMode;

/**
 * Maps from URL-String to AFCacheableItemInfo
 */
@property (nonatomic, strong) NSMutableDictionary *cachedItemInfos;
/**
 * Maps from URL-String to its redirected URL-String
 */
@property (nonatomic, strong) NSMutableDictionary *urlRedirects;

// TODO: "packageInfos" is not a good descriptive name. What means "info"?
@property (nonatomic, strong) NSMutableDictionary *packageInfos;

// holds CacheableItem objects (former NSURLConnection, changed 2013/03/26 by mic)
@property (nonatomic, readonly) int totalRequestsForSession;

@property (nonatomic, strong) NSDictionary *suffixToMimeTypeMap;
@property (nonatomic, assign) double maxItemFileSize;
@property (nonatomic, assign) double diskCacheDisplacementTresholdSize;
@property (nonatomic, assign) NetworkTimeoutIntervals networkTimeoutIntervals;
@property (nonatomic, assign) NSTimeInterval archiveInterval;
/**
 *  Skip check if data on disk is equal to byte size in cache info store. Might be helpful for debugging purposes.
 *
 *  @since 0.9.2
 */
@property (nonatomic, assign) BOOL skipValidContentLengthCheck;

/*
 * change your user agent - do not abuse it
 */
@property (nonatomic, strong) NSString *userAgent;


/*
 * set the path for your cachestore
 */
@property (nonatomic, copy) NSString *dataPath;

/*
 * set the number of maximum concurrent downloadable items
 * Default is 5
 */
// TODO: Rename to maxConcurrentConnections and introduce forward property with old name in DeprecatedAPI category
@property (nonatomic, assign, getter=concurrentConnections, setter=setConcurrentConnections:) int concurrentConnections;

/*
 * the download fails if HTTP error is above 400
 * Default is YES
 */
@property (nonatomic, assign) BOOL failOnStatusCodeAbove400;


/*
 * the items will be cached in the cachestore with a hashed filename instead of the URL path
 * Default is YES
 */
@property (nonatomic, assign) BOOL cacheWithHashname;


/*
 * the items will be cached in the cachestore without any URL parameter
 * Default is NO
 */
@property (nonatomic, assign) BOOL cacheWithoutUrlParameter;

/*
 * the items will be cached in the cachestore without the hostname
 * Default is NO
 */
@property (nonatomic, assign) BOOL cacheWithoutHostname;

/*
 * pause the downloads. cancels any running downloads and puts them back into the queue
 */
@property (nonatomic, assign, getter=suspended, setter=setSuspended:) BOOL suspended;

/*
 * check if we have an internet connection. can be observed
 */
@property (nonatomic, readonly) BOOL isConnectedToNetwork;

/*
 * ignore any invalid SSL certificates
 * be careful with invalid SSL certificates! use only for testing or debugging
 * Default is NO
 */
@property (nonatomic, assign) BOOL disableSSLCertificateValidation;

#pragma mark - 

+ (_NetCache *)cacheForContext:(NSString *)context;

- (NSString *)filenameForURL: (NSURL *) url;
- (NSString *)filenameForURLString: (NSString *) URLString;
- (NSString *)filePath: (NSString *) filename;
- (NSString *)filePathForURL: (NSURL *) url;
- (NSString *)fullPathForCacheableItem:(_NetCacheRequest *)item;

- (_NetCacheRequest *)cachedObjectForURLSynchronous: (NSURL *) url;
- (_NetCacheRequest *)cachedObjectForURLSynchronous:(NSURL *)url options: (int)options;

- (BOOL)isQueuedOrDownloadingURL:(NSURL *)url;
- (BOOL)isDownloadingURL:(NSURL *)url;

- (void)invalidateAll;
- (void)archive;

/**
 * Starts the archiving Thread without a delay.
 */
- (void)archiveNow;

- (int)totalRequestsForSession;
- (void)doHousekeeping;
- (void)doHousekeepingWithRequiredCacheItemURLs:(NSSet*)requiredURLs;

- (unsigned long)diskCacheSize;

/*
 * Cancel any asynchronous operations and downloads
 */
- (void)cancelAllRequestsForURL:(NSURL *)url;
- (void)cancelAsynchronousOperationsForURL:(NSURL *)url itemDelegate:(id)itemDelegate;
- (void)cancelAsynchronousOperationsForDelegate:(id)itemDelegate;

/*
 * Prioritize the URL or item in the queue
 */
- (void)prioritizeURL:(NSURL*)url;

/*
 * Flush and start loading all items in the  queue
 */
- (void)flushDownloadQueue;

#pragma mark - Query

- (BOOL)hasCachedRequestForURL:(NSURL *)url;
- (_NetCacheRequest *)cacheableRequestFromCacheStore:(NSURL *)url;

/*
 * Get a cached request from cache.
 *
 * @param url the requested url
 * @param urlCredential the credential for requested url
 * @param completionBlock
 * @param failBlock
 */
- (_NetCacheRequest *)cachedRequestForURL:(NSURL *)url
                            urlCredential:(NSURLCredential *)urlCredential
                          completionBlock:(NetCacheRequestBlock)completionBlock
                                failBlock:(NetCacheRequestBlock)failBlock;

/*
 * Get a cached request from cache.
 *
 * @param url the requested url
 * @param urlCredential the credential for requested url
 * @param completionBlock
 * @param failBlock
 * @param progressBlock
 */
- (_NetCacheRequest *)cachedRequestForURL:(NSURL *)url
                            urlCredential:(NSURLCredential *)urlCredential
                          completionBlock:(NetCacheRequestBlock)completionBlock
                                failBlock:(NetCacheRequestBlock)failBlock
                            progressBlock:(NetCacheRequestBlock)progressBlock;

/*
 * Get a cached request from cache.
 *
 * @param url the requested url
 * @param urlCredential the credential for requested url
 * @param completionBlock
 * @param failBlock
 * @param progressBlock
 * @param requestConfiguration
 */
- (_NetCacheRequest *)cachedRequestForURL:(NSURL *)url
                            urlCredential:(NSURLCredential *)urlCredential
                          completionBlock:(NetCacheRequestBlock)completionBlock
                                failBlock:(NetCacheRequestBlock)failBlock
                            progressBlock:(NetCacheRequestBlock)progressBlock
                     requestConfiguration:(_NetCacheRequestConfiguration *)requestConfiguration;

@end

#pragma mark -

@interface _NetCache ( Packaging )

- (BOOL)cacheRequest:(_NetCacheRequest *)request withData:(NSData *)theData;
- (BOOL)cacheRequest:(_NetCacheRequest *)request dataWithFileAtURL:(NSURL *)URL;
- (_NetCacheRequest *)importObjectForURL:(NSURL *)url data:(NSData *)data;
- (_NetCacheRequest *)importObjectForURL:(NSURL *)url dataWithFileAtURL:(NSURL *)URL;

//- (_NetCacheRequest *)requestPackageArchive:(NSURL *)url delegate:(id)aDelegate;
//- (_NetCacheRequest *)requestPackageArchive:(NSURL *)url delegate:(id)aDelegate username:(NSString *)username password:(NSString *)password;

- (void)packageArchiveDidFinishLoading:(_NetCacheRequest *) cacheableItem;
- (NSString *)userDataPathForPackageArchiveKey:(NSString *)archiveKey;
- (_NetPackageInfo *)packageInfoForURL:(NSURL *)url;

// wipe out a cachable item completely
- (void)purgeCacheableItemForURL:(NSURL *)url;

// remove an imported package zip
- (void)purgePackageArchiveForURL:(NSURL *)url;

// announce files residing in the urlcachestore folder by reading the cache manifest file
// this method assumes that the files already have been extracted into the urlcachestore folder
- (_NetPackageInfo *)newPackageInfoByImportingCacheManifestAtPath:(NSString *)manifestPath intoCacheStoreWithPath:(NSString *)urlCacheStorePath withPackageURL:(NSURL *)packageURL;
- (void)storeCacheInfo:(NSDictionary *)dictionary;

@end

#pragma mark - 

@interface _NetCache ( FileAttributes )

- (uint64_t)setContentLengthForFileAtPath:(NSString*)filePath;

@end

#pragma mark - 

@interface _NetCache ( MimeType )

- (void)initMimeTypes;

@end


