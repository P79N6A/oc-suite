//
//  _disk_cache.h
//  consumer
//
//  Created by fallen.ink on 6/20/16.
//
//

#import "_greats.h"
#import "_cache_object_subscripting.h"

@class _DiskCache;

/**
 * A callback block which provides only the cache as an argument
 */
typedef void (^ DiskCacheBlock)(_DiskCache *cache);

/**
 * A callback block which provides the cache, key and object as arguments
 */
typedef void (^ DiskCacheObjectBlock)(_DiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL);

/**
 * A callback block which provides a BOOL value as argument
 */
typedef void (^ DiskCacheContainsBlock)(BOOL containsObject);

/**
 `DiskCache` is a thread safe key/value store backed by the file system. It accepts any object conforming
 to the `NSCoding` protocol, which includes the basic Foundation data types and collection classes and also
 many UIKit classes, notably `UIImage`. All work is performed on a serial queue shared by all instances in
 the app, and archiving is handled by `NSKeyedArchiver`. This is a particular advantage for `UIImage` because
 it skips `UIImagePNGRepresentation()` and retains information like scale and orientation.
 
 The designated initializer for `DiskCache` is <initWithName:>. The <name> string is used to create a directory
 under Library/Caches that scopes disk access for this instance. Multiple instances with the same name are *not*
 allowed as they would conflict with each other.
 
 Unless otherwise noted, all properties and methods are safe to access from any thread at any time. All blocks
 will cause the queue to wait, making it safe to access and manipulate the actual cache files on disk for the
 duration of the block.
 
 Because this cache is bound by disk I/O it can be much slower than <PINMemoryCache>, although values stored in
 `PINDiskCache` persist after application relaunch. Using <PINCache> is recommended over using `PINDiskCache`
 by itself, as it adds a fast layer of additional memory caching while still writing to disk.
 
 All access to the cache is dated so the that the least-used objects can be trimmed first. Setting an optional
 <ageLimit> will trigger a GCD timer to periodically to trim the cache with <trimToDate:>.
 */

@interface _DiskCache : NSObject <CacheObjectSubscripting>

@singleton( _DiskCache )

/**
 Empties the trash with `DISPATCH_QUEUE_PRIORITY_BACKGROUND`. Does not use lock.
 */
+ (void)emptyTrash;

@property (nonatomic, strong, readonly) dispatch_queue_t sharedQueue;

/**
 The name of this cache, used to create a directory under Library/Caches and also appearing in stack traces.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 The URL of the directory used by this cache, usually `Library/Caches/com.tumblr.TMDiskCache.(name)`
 
 @warning Do not interact with files under this URL except on the <sharedQueue>.
 */
@property (nonatomic, strong, readonly) NSURL *cacheURL;

/**
 The total number of bytes used on disk, as reported by `NSURLTotalFileAllocatedSizeKey`.
 
 @warning This property is technically safe to access from any thread, but it reflects the value *right now*,
 not taking into account any pending operations. In most cases this value should only be read from a block on the
 <sharedQueue>, which will ensure its accuracy and prevent it from changing during the lifetime of the block.
 
 For example:
 
 // some background thread, not a block already running on the shared queue
 
 dispatch_sync([TMDiskCache sharedQueue], ^{
 NSLog(@"accurate, unchanging byte count: %d", [[TMDiskCache sharedCache] byteCount]);
 });
 */
@property (nonatomic, assign, readonly) NSUInteger byteCount;

/**
 The maximum number of bytes allowed on disk. This value is checked every time an object is set, if the written
 size exceeds the limit a trim call is queued. Defaults to `0.0`, meaning no practical limit.
 
 @warning Do not read this property on the <sharedQueue> (including asynchronous method blocks).
 */
@property (nonatomic, assign) NSUInteger byteLimit;

/**
 The maximum number of seconds an object is allowed to exist in the cache. Setting this to a value
 greater than `0.0` will start a recurring GCD timer with the same period that calls <trimToDate:>.
 Setting it back to `0.0` will stop the timer. Defaults to `0.0`, meaning no limit.
 
 @warning Do not read this property on the <sharedQueue> (including asynchronous method blocks).
 */
@property (nonatomic, assign) NSTimeInterval ageLimit;

/**
 The writing protection option used when writing a file on disk. This value is used every time an object is set.
 NSDataWritingAtomic and NSDataWritingWithoutOverwriting are ignored if set
 Defaults to NSDataWritingFileProtectionNone.
 
 @warning Only new files are affected by the new writing protection. If you need all files to be affected,
 you'll have to purge and set the objects back to the cache
 
 Only available on iOS
 */
#if TARGET_OS_IPHONE
@property (assign) NSDataWritingOptions writingProtectionOption;
#endif

/**
 If ttlCache is YES, the cache behaves like a ttlCache. This means that once an object enters the
 cache, it only lives as long as self.ageLimit. This has the following implications:
 - Accessing an object in the cache does not extend that object's lifetime in the cache
 - When attempting to access an object in the cache that has lived longer than self.ageLimit,
 the cache will behave as if the object does not exist
 
 */
@property (nonatomic, assign, getter=isTTLCache) BOOL ttlCache;

#pragma mark -
/// @name Event Blocks

/**
 A block to be executed just before an object is added to the cache. The queue waits during execution.
 */
@property (copy) DiskCacheObjectBlock willAddObjectBlock;

/**
 A block to be executed just before an object is removed from the cache. The queue waits during execution.
 */
@property (copy) DiskCacheObjectBlock willRemoveObjectBlock;

/**
 A block to be executed just before all objects are removed from the cache as a result of <removeAllObjects:>.
 The queue waits during execution.
 */
@property (copy) DiskCacheBlock willRemoveAllObjectsBlock;

/**
 A block to be executed just after an object is added to the cache. The queue waits during execution.
 */
@property (copy) DiskCacheObjectBlock didAddObjectBlock;

/**
 A block to be executed just after an object is removed from the cache. The queue waits during execution.
 */
@property (copy) DiskCacheObjectBlock didRemoveObjectBlock;

/**
 A block to be executed just after all objects are removed from the cache as a result of <removeAllObjects:>.
 The queue waits during execution.
 */
@property (copy) DiskCacheBlock didRemoveAllObjectsBlock;

// ----------------------------------
// Asynchronize methods
// ----------------------------------

/**
 Locks access to ivars and allows safe interaction with files on disk. This method returns immediately.
 
 @warning Calling synchronous methods on the diskCache inside this block will likely cause a deadlock.
 
 @param block A block to be executed when a lock is available.
 */
- (void)lockFileAccessWhileExecutingBlock:(DiskCacheBlock)block;

/**
 This method determines whether an object is present for the given key in the cache. This method returns immediately
 and executes the passed block after the object is available, potentially in parallel with other blocks on the
 <concurrentQueue>.
 
 @see containsObjectForKey:
 @param key The key associated with the object.
 @param block A block to be executed concurrently after the containment check happened
 */
- (void)containsObjectForKey:(NSString *)key block:(DiskCacheContainsBlock)block;

/**
 Retrieves the object for the specified key. This method returns immediately and executes the passed
 block as soon as the object is available on the serial <sharedQueue>.
 
 @warning The fileURL is only valid for the duration of this block, do not use it after the block ends.
 
 @param key The key associated with the requested object.
 @param block A block to be executed serially when the object is available.
 */
- (void)objectForKey:(NSString *)key block:(DiskCacheObjectBlock)block;

/**
 Retrieves the fileURL for the specified key without actually reading the data from disk. This method
 returns immediately and executes the passed block as soon as the object is available on the serial
 <sharedQueue>.
 
 @warning Access is protected for the duration of the block, but to maintain safe disk access do not
 access this fileURL after the block has ended. Do all work on the <sharedQueue>.
 
 @param key The key associated with the requested object.
 @param block A block to be executed serially when the file URL is available.
 */
- (void)fileURLForKey:(NSString *)key block:(DiskCacheObjectBlock)block;

/**
 Stores an object in the cache for the specified key. This method returns immediately and executes the
 passed block as soon as the object has been stored.
 
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 @param block A block to be executed serially after the object has been stored, or nil.
 */
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(DiskCacheObjectBlock)block;

/**
 Removes the object for the specified key. This method returns immediately and executes the passed block
 as soon as the object has been removed.
 
 @param key The key associated with the object to be removed.
 @param block A block to be executed serially after the object has been removed, or nil.
 */
- (void)removeObjectForKey:(NSString *)key block:(DiskCacheObjectBlock)block;

/**
 Removes all objects from the cache that have not been used since the specified date.
 This method returns immediately and executes the passed block as soon as the cache has been trimmed.
 
 @param date Objects that haven't been accessed since this date are removed from the cache.
 @param block A block to be executed serially after the cache has been trimmed, or nil.
 */
- (void)trimToDate:(NSDate *)date block:(DiskCacheBlock)block;

/**
 Removes objects from the cache, largest first, until the cache is equal to or smaller than the specified byteCount.
 This method returns immediately and executes the passed block as soon as the cache has been trimmed.
 
 @param byteCount The cache will be trimmed equal to or smaller than this size.
 @param block A block to be executed serially after the cache has been trimmed, or nil.
 */
- (void)trimToSize:(NSUInteger)byteCount block:(DiskCacheBlock)block;

/**
 Removes objects from the cache, ordered by date (least recently used first), until the cache is equal to or smaller
 than the specified byteCount. This method returns immediately and executes the passed block as soon as the cache has
 been trimmed.
 
 @param byteCount The cache will be trimmed equal to or smaller than this size.
 @param block A block to be executed serially after the cache has been trimmed, or nil.
 */
- (void)trimToSizeByDate:(NSUInteger)byteCount block:(DiskCacheBlock)block;

/**
 Removes all objects from the cache. This method returns immediately and executes the passed block as soon as the
 cache has been cleared.
 
 @param block A block to be executed serially after the cache has been cleared, or nil.
 */
- (void)removeAllObjects:(DiskCacheBlock)block;

/**
 Loops through all objects in the cache (reads and writes are suspended during the enumeration). Data is not actually
 read from disk, the `object` parameter of the block will be `nil` but the `fileURL` will be available.
 This method returns immediately.
 
 @param block A block to be executed for every object in the cache.
 @param completionBlock An optional block to be executed after the enumeration is complete.
 */
- (void)enumerateObjectsWithBlock:(DiskCacheObjectBlock)block completionBlock:(DiskCacheBlock)completionBlock;

#pragma mark -
/// @name Synchronous Methods

/**
 Locks access to ivars and allows safe interaction with files on disk. This method only returns once the block
 has been run.
 
 @warning Calling synchronous methods on the diskCache inside this block will likely cause a deadlock.
 
 @param block A block to be executed when a lock is available.
 */
- (void)synchronouslyLockFileAccessWhileExecutingBlock:(DiskCacheBlock)block;

/**
 This method determines whether an object is present for the given key in the cache.
 
 @see containsObjectForKey:block:
 @param key The key associated with the object.
 @result YES if an object is present for the given key in the cache, otherwise NO.
 */
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 Retrieves the object for the specified key. This method blocks the calling thread until the
 object is available.
 
 @see objectForKey:block:
 @param key The key associated with the object.
 @result The object for the specified key.
 */
- (id <NSCoding>)objectForKey:(NSString *)key;

/**
 Retrieves the file URL for the specified key. This method blocks the calling thread until the
 url is available. Do not use this URL anywhere but on the <sharedQueue>. This method probably
 shouldn't even exist, just use the asynchronous one.
 
 @see fileURLForKey:block:
 @param key The key associated with the object.
 @result The file URL for the specified key.
 */
- (NSURL *)fileURLForKey:(NSString *)key;

/**
 Stores an object in the cache for the specified key. This method blocks the calling thread until
 the object has been stored.
 
 @see setObject:forKey:block:
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 */
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key;

/**
 Removes the object for the specified key. This method blocks the calling thread until the object
 has been removed.
 
 @param key The key associated with the object to be removed.
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 Removes all objects from the cache that have not been used since the specified date.
 This method blocks the calling thread until the cache has been trimmed.
 
 @param date Objects that haven't been accessed since this date are removed from the cache.
 */
- (void)trimToDate:(NSDate *)date;

/**
 Removes objects from the cache, largest first, until the cache is equal to or smaller than the
 specified byteCount. This method blocks the calling thread until the cache has been trimmed.
 
 @param byteCount The cache will be trimmed equal to or smaller than this size.
 */
- (void)trimToSize:(NSUInteger)byteCount;

/**
 Removes objects from the cache, ordered by date (least recently used first), until the cache is equal to or
 smaller than the specified byteCount. This method blocks the calling thread until the cache has been trimmed.
 
 @param byteCount The cache will be trimmed equal to or smaller than this size.
 */
- (void)trimToSizeByDate:(NSUInteger)byteCount;

/**
 Removes all objects from the cache. This method blocks the calling thread until the cache has been cleared.
 */
- (void)removeAllObjects;

/**
 Loops through all objects in the cache (reads and writes are suspended during the enumeration). Data is not actually
 read from disk, the `object` parameter of the block will be `nil` but the `fileURL` will be available.
 This method blocks the calling thread until all objects have been enumerated.
 
 @param block A block to be executed for every object in the cache.
 
 @warning Do not call this method within the event blocks (<didRemoveObjectBlock>, etc.)
 Instead use the asynchronous version, <enumerateObjectsWithBlock:completionBlock:>.
 */
- (void)enumerateObjectsWithBlock:(DiskCacheObjectBlock)block;

@end
