//
//  _net_cache_request.h
//  consumer
//
//  Created by fallen.ink on 9/21/16.
//
//

#import "_greats.h"
#import "_net_cache_request_info.h"

@class _NetCache;
@class _NetCacheRequest;
@class _NetCacheRequestInfo;
@protocol _NetCacheRequestDelegate;

#pragma mark -

typedef enum : NSUInteger {
    NetCacheStatusNew = 0,
    NetCacheStatusFresh = 1, // written into cacheableitem when item is fresh, either after fetching it for the first time or by revalidation.
    NetCacheStatusModified = 2, // if ims request returns status 200
    NetCacheStatusNotModified = 4,
    NetCacheStatusRevalidationPending = 5,
    NetCacheStatusStale = 6,
} NetCacheStatus;

typedef void (^ NetCacheRequestBlock)(_NetCacheRequest *request);

#pragma mark -

@interface _NetCacheRequest : NSObject

@prop_singleton( _NetCache, cache)

/**
 *  request's url
 */
@property (nonatomic, strong) NSURL *url;
/**
 *  response's data
 */
@property (nonatomic, strong) NSData *data;

@property (nonatomic, weak) id <_NetCacheRequestDelegate> delegate;

@property (nonatomic, strong) NSError *error;

/*
 validUntil holds the calculated expire date of the cached object.
	It is either equal to Expires (if Expires header is set), or the date
	based on the request time + max-age (if max-age header is set).
	If neither Expires nor max-age is given or if the resource must not
	be cached valitUntil is nil.
 */
@property (nonatomic, strong) NSDate *validUntil;
@property (nonatomic, assign) BOOL justFetchHTTPHeader;
@property (nonatomic, assign) NetCacheStatus cacheStatus;
@property (nonatomic, strong) _NetCacheRequestInfo *info;
@property (nonatomic, weak) id userData;
@property (nonatomic, assign) BOOL isPackageArchive;
@property (nonatomic, assign) uint64_t currentContentLength;
/*
 Data for URL authentication
 */
@property (nonatomic, strong) NSURLCredential *urlCredential;

@property (nonatomic, assign) BOOL isRevalidating;
@property (nonatomic, readonly) BOOL canMapData;

@property (nonatomic, strong) NSURLRequest *IMSRequest;
@property (nonatomic, assign) BOOL servedFromCache;
@property (nonatomic, assign) BOOL URLInternallyRewritten;

// for debugging and testing purposes
@property (nonatomic, assign) int tag;

- (_NetCacheRequest *)initWithURL:(NSURL *)URL
                    lastModified:(NSDate *)lastModified
                      expireDate:(NSDate *)expireDate
                     contentType:(NSString *)contentType;

- (_NetCacheRequest *)initWithURL:(NSURL *)URL
                    lastModified:(NSDate *)lastModified
                      expireDate:(NSDate *)expireDate;

// TODO: Move completionBlocks to AFDownloadOperation
- (void)addCompletionBlock:(NetCacheRequestBlock)completionBlock
                 failBlock:(NetCacheRequestBlock)failBlock
             progressBlock:(NetCacheRequestBlock)progressBlock;

- (void)removeBlocks;

- (void)sendFailSignalToClientItems;
- (void)sendSuccessSignalToClientItems;
- (void)sendProgressSignalToClientItems;

- (BOOL)isDownloading;
- (BOOL)isFresh;
- (BOOL)isCachedOnDisk;
- (NSString *)guessContentType;
- (uint64_t)currentContentLength;
- (BOOL)isComplete;
- (BOOL)isDataLoaded;

- (NSString *)asString;

@end

// TODO: AF(Debug)HTTPURLProtocol uses this delegate, but delegate methods are currently not called (any more). Elaborate on this.
@protocol _NetCacheRequestDelegate < NSObject >

@optional
- (void)connectionDidFail:(_NetCacheRequest *)request;
- (void)connectionDidFinish:(_NetCacheRequest *)request;
- (void)connectionHasBeenRedirected:(_NetCacheRequest *)request;

- (void)packageArchiveDidReceiveData:(_NetCacheRequest *)request;
- (void)packageArchiveDidFinishLoading:(_NetCacheRequest *)request;
- (void)packageArchiveDidFinishExtracting:(_NetCacheRequest *)request;
- (void)packageArchiveDidFailExtracting:(_NetCacheRequest *)request;
- (void)packageArchiveDidFailLoading:(_NetCacheRequest *)request;

- (void) cacheableItemDidReceiveData:(_NetCacheRequest *)request;
- (void) cannotWriteDataForItem:(_NetCacheRequest *)request;

@end

#pragma mark - 

@interface _NetCacheRequest ( Packaging )

- (NSString*)metaDescription;
- (NSString*)metaJSON;

+ (NSString *)urlEncodeValue:(NSString *)str;
- (void)setDataAndFile:(NSData*)data;

@end

#pragma mark -

extern const char *kAFCacheContentLengthFileAttribute;
extern const char *kAFCacheDownloadingFileAttribute;

@interface _NetCacheRequest (FileAttributes)

- (BOOL)hasDownloadFileAttribute;
- (void)flagAsDownloadStartedWithContentLength:(uint64_t)contentLength;
- (void)flagAsDownloadFinishedWithContentLength:(uint64_t)contentLength;
- (uint64_t)getContentLengthFromFile;

@end

