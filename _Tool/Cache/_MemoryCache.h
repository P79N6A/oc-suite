//
//  _memory_cache.h
//  consumer
//
//  Created by fallen.ink on 6/20/16.
//
//

#import "_greats.h"
#import "_cache_object_subscripting.h"

@class _MemoryCache;

/**
 * A callback block which provides only the cache as an argument
 */
typedef void (^ MemoryCacheBlock)(_MemoryCache *cache);

/**
 * A callback block which provides the cache, key and object as arguments
 */
typedef void (^ MemoryCacheObjectBlock)(_MemoryCache *cache, NSString *key, id object);

/**
 * A callback block which provides a BOOL value as argument
 */
typedef void (^ MemoryCacheContainmentBlock)(BOOL containsObject);

/**
 `_MemoryCache` is a fast, thread safe key/value store similar to `NSCache`. On iOS it will clear itself
 automatically to reduce memory usage when the app receives a memory warning or goes into the background.
 
 Access is natively synchronous. Asynchronous variations are provided. Every asynchronous method accepts a
 callback block that runs on a concurrent <concurrentQueue>, with cache reads and writes protected by an semaphore.
 
 All access to the cache is dated so the that the least-used objects can be trimmed first. Setting an
 optional <ageLimit> will trigger a GCD timer to periodically to trim the cache to that age.
 
 Objects can optionally be set with a "cost", which could be a byte count or any other meaningful integer.
 Setting a <costLimit> will automatically keep the cache below that value with <trimToCostByDate:>.
 
 Values will not persist after application relaunch or returning from the background. See <_Cache> for
 a memory cache backed by a disk cache.
 */

@interface _MemoryCache : NSObject <CacheObjectSubscripting>

@singleton(_MemoryCache )

#pragma mark -

/**
 A concurrent queue on which all work is done. It is exposed here so that it can be set to target some
 other queue, such as a global concurrent queue with a priority other than the default.
 */
@property (nonatomic, strong, readonly) dispatch_queue_t concurrentQueue;

/**
 The total accumulated cost.
 */
@property (nonatomic, assign, readonly) NSUInteger totalCost;

/**
 The maximum cost allowed to accumulate before objects begin to be removed with <trimToCostByDate:>.
 */
@property (nonatomic, assign) NSUInteger costLimit;

/**
 The maximum number of seconds an object is allowed to exist in the cache. Setting this to a value
 greater than `0.0` will start a recurring GCD timer with the same period that calls <trimToDate:>.
 Setting it back to `0.0` will stop the timer. Defaults to `0.0`.
 */
@property (nonatomic, assign) NSTimeInterval ageLimit;

/**
 If ttlCache(Time to live.) is YES, the cache behaves like a ttlCache. This means that once an object enters the
 cache, it only lives as long as self.ageLimit. This has the following implications:
 - Accessing an object in the cache does not extend that object's lifetime in the cache
 - When attempting to access an object in the cache that has lived longer than self.ageLimit,
 the cache will behave as if the object does not exist
 
 */
@property (nonatomic, assign, getter=isTTLCache) BOOL ttlCache;

/**
 When `YES` on iOS the cache will remove all objects when the app receives a memory warning.
 Defaults to `YES`.
 */
@property (nonatomic, assign) BOOL removeAllObjectsOnMemoryWarning;

/**
 When `YES` on iOS the cache will remove all objects when the app enters the background.
 Defaults to `YES`.
 */
@property (nonatomic, assign) BOOL removeAllObjectsOnEnteringBackground;

#pragma mark -
/// @name Event Blocks

/**
 A block to be executed just before an object is added to the cache. This block will be excuted within
 a barrier, i.e. all reads and writes are suspended for the duration of the block.
 */
@property (nonatomic, copy) MemoryCacheObjectBlock willAddObjectBlock; // 实现中已经提供了多线程支持

/**
 A block to be executed just before an object is removed from the cache. This block will be excuted
 within a barrier, i.e. all reads and writes are suspended for the duration of the block.
 */
@property (nonatomic, copy) MemoryCacheObjectBlock willRemoveObjectBlock;

/**
 A block to be executed just before all objects are removed from the cache as a result of <removeAllObjects:>.
 This block will be excuted within a barrier, i.e. all reads and writes are suspended for the duration of the block.
 */
@property (nonatomic, copy) MemoryCacheBlock willRemoveAllObjectsBlock;

/**
 A block to be executed just after an object is added to the cache. This block will be excuted within
 a barrier, i.e. all reads and writes are suspended for the duration of the block.
 */
@property (nonatomic, copy) MemoryCacheObjectBlock didAddObjectBlock;

/**
 A block to be executed just after an object is removed from the cache. This block will be excuted
 within a barrier, i.e. all reads and writes are suspended for the duration of the block.
 */
@property (nonatomic, copy) MemoryCacheObjectBlock didRemoveObjectBlock;

/**
 A block to be executed just after all objects are removed from the cache as a result of <removeAllObjects:>.
 This block will be excuted within a barrier, i.e. all reads and writes are suspended for the duration of the block.
 */
@property (nonatomic, copy) MemoryCacheBlock didRemoveAllObjectsBlock;

/**
 A block to be executed upon receiving a memory warning (iOS only) potentially in parallel with other blocks on the <queue>.
 This block will be executed regardless of the value of <removeAllObjectsOnMemoryWarning>. Defaults to `nil`.
 */
@property (nonatomic, copy) MemoryCacheBlock didReceiveMemoryWarningBlock;

/**
 A block to be executed when the app enters the background (iOS only) potentially in parallel with other blocks on the <queue>.
 This block will be executed regardless of the value of <removeAllObjectsOnEnteringBackground>. Defaults to `nil`.
 */
@property (nonatomic, copy) MemoryCacheBlock didEnterBackgroundBlock;

#pragma mark - Asynchronous Methods

/**
 This method determines whether an object is present for the given key in the cache. This method returns immediately
 and executes the passed block after the object is available, potentially in parallel with other blocks on the
 <concurrentQueue>.
 
 @see containsObjectForKey:
 @param key The key associated with the object.
 @param block A block to be executed concurrently after the containment check happened
 */
- (void)containsObjectForKey:(NSString *)key block:(MemoryCacheContainmentBlock)block;

/**
 Retrieves the object for the specified key. This method returns immediately and executes the passed
 block after the object is available, potentially in parallel with other blocks on the <queue>.
 
 @param key The key associated with the requested object.
 @param block A block to be executed concurrently when the object is available.
 */
- (void)objectForKey:(NSString *)key block:(MemoryCacheObjectBlock)block;

/**
 Stores an object in the cache for the specified key. This method returns immediately and executes the
 passed block after the object has been stored, potentially in parallel with other blocks on the <queue>.
 
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 @param block A block to be executed concurrently after the object has been stored, or nil.
 */
- (void)setObject:(id)object forKey:(NSString *)key block:(MemoryCacheObjectBlock)block;

/**
 Stores an object in the cache for the specified key and the specified cost. If the cost causes the total
 to go over the <costLimit> the cache is trimmed (oldest objects first). This method returns immediately
 and executes the passed block after the object has been stored, potentially in parallel with other blocks
 on the <queue>.
 
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 @param cost An amount to add to the <totalCost>.
 @param block A block to be executed concurrently after the object has been stored, or nil.
 */
- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost block:(MemoryCacheObjectBlock)block;

/**
 Removes the object for the specified key. This method returns immediately and executes the passed
 block after the object has been removed, potentially in parallel with other blocks on the <queue>.
 
 @param key The key associated with the object to be removed.
 @param block A block to be executed concurrently after the object has been removed, or nil.
 */
- (void)removeObjectForKey:(NSString *)key block:(MemoryCacheObjectBlock)block;

/**
 Removes all objects from the cache that have not been used since the specified date.
 This method returns immediately and executes the passed block after the cache has been trimmed,
 potentially in parallel with other blocks on the <queue>.
 
 @param date Objects that haven't been accessed since this date are removed from the cache.
 @param block A block to be executed concurrently after the cache has been trimmed, or nil.
 */
- (void)trimToDate:(NSDate *)date block:(MemoryCacheBlock)block;

/**
 Removes objects from the cache, costliest objects first, until the <totalCost> is below the specified
 value. This method returns immediately and executes the passed block after the cache has been trimmed,
 potentially in parallel with other blocks on the <queue>.
 
 @param cost The total accumulation allowed to remain after the cache has been trimmed.
 @param block A block to be executed concurrently after the cache has been trimmed, or nil.
 */
- (void)trimToCost:(NSUInteger)cost block:(MemoryCacheBlock)block;

/**
 Removes objects from the cache, ordered by date (least recently used first), until the <totalCost> is below
 the specified value. This method returns immediately and executes the passed block after the cache has been
 trimmed, potentially in parallel with other blocks on the <queue>.
 
 @param cost The total accumulation allowed to remain after the cache has been trimmed.
 @param block A block to be executed concurrently after the cache has been trimmed, or nil.
 */
- (void)trimToCostByDate:(NSUInteger)cost block:(MemoryCacheBlock)block;

/**
 Removes all objects from the cache. This method returns immediately and executes the passed block after
 the cache has been cleared, potentially in parallel with other blocks on the <queue>.
 
 @param block A block to be executed concurrently after the cache has been cleared, or nil.
 */
- (void)removeAllObjects:(MemoryCacheBlock)block;

/**
 Loops through all objects in the cache within a memory barrier (reads and writes are suspended during the enumeration).
 This method returns immediately.
 
 @param block A block to be executed for every object in the cache.
 @param completionBlock An optional block to be executed concurrently when the enumeration is complete.
 */
- (void)enumerateObjectsWithBlock:(MemoryCacheObjectBlock)block completionBlock:(MemoryCacheBlock)completionBlock;

#pragma mark - Synchronize methods

/**
 This method determines whether an object is present for the given key in the cache.
 
 @see containsObjectForKey:block:
 @param key The key associated with the object.
 @result YES if an object is present for the given key in the cache, otherwise NO.
 */
- (BOOL)containsObjectForKey:(NSString *)key;

- (id)objectForKey:(NSString *)key;

- (void)setObject:(id)object forKey:(NSString *)key;

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost;

- (void)removeObjectForKey:(NSString *)key;

- (void)trimToDate:(NSDate *)date;

- (void)trimToCost:(NSUInteger)cost;

- (void)trimToCostByDate:(NSUInteger)cost;

- (void)removeAllObjects;

- (void)enumerateObjectsWithBlock:(MemoryCacheObjectBlock)block;

@end
