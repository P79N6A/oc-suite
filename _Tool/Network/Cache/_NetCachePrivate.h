//
//  _net_cache_private.h
//  consumer
//
//  Created by fallen.ink on 9/22/16.
//
//

#import "_net_cache.h"

@interface _NetCache ( Private )

- (void)updateModificationDataAndTriggerArchiving:(_NetCacheRequest *)obj;

- (void)setConnectedToNetwork:(BOOL)connected;
- (void)reinitialize;
- (void)removeCacheEntryWithFilePath:(NSString *)filePath fileOnly:(BOOL)fileOnly;

- (NSOutputStream *)createOutputStreamForItem:(_NetCacheRequest *)cacheableItem;
- (void)addItemToDownloadQueue:(_NetCacheRequest *)item;
- (BOOL)isQueuedURL:(NSURL *)url;
- (BOOL)_fileExistsOrPendingForCacheableItem:(_NetCacheRequest *)item;
- (void)removeCacheEntry:(_NetCacheRequestInfo *)info fileOnly:(BOOL) fileOnly;
- (void)removeCacheEntry:(_NetCacheRequestInfo *)info fileOnly:(BOOL) fileOnly fallbackURL:(NSURL *)fallbackURL;

// TODO: This getter to its property is necessary as the category "Packaging" needs to access the private property. This is due to Packaging not being a real category
- (NSOperationQueue *) packageArchiveQueue;

@end

#pragma mark - 

@interface _NetCacheRequest ( Private )

- (BOOL)isQueuedOrDownloading;
- (BOOL)hasValidContentLength;

// Making synthesized getter and setter for private property public for private API
- (void)setHasReturnedCachedItemBeforeRevalidation:(BOOL)value;
- (BOOL)hasReturnedCachedItemBeforeRevalidation;

@end

@interface _NetCacheRequestInfo ( Private )

- (NSString *)newUniqueFilename;

@end

