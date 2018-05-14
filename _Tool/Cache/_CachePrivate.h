//
//  _cache_private.h
//  consumer
//
//  Created by fallen.ink on 6/20/16.
//
//

@interface _Cache ()

// ----------------------------------
// Asynchronize methods
// ----------------------------------

/**
 Removes the object for the specified key. This method returns immediately and executes the passed
 block after the object has been removed, potentially in parallel with other blocks on the <queue>.
 
 @param key The key associated with the object to be removed.
 @param block A block to be executed concurrently after the object has been removed, or nil.
 */
- (void)removeObjectForKey:(NSString *)key block:(TMCacheObjectBlock)block;

/**
 Removes all objects from the cache that have not been used since the specified date. This method returns immediately and
 executes the passed block after the cache has been trimmed, potentially in parallel with other blocks on the <queue>.
 
 @param date Objects that haven't been accessed since this date are removed from the cache.
 @param block A block to be executed concurrently after the cache has been trimmed, or nil.
 */
- (void)trimToDate:(NSDate *)date block:(TMCacheBlock)block;

/**
 Removes all objects from the cache.This method returns immediately and executes the passed block after the
 cache has been cleared, potentially in parallel with other blocks on the <queue>.
 
 @param block A block to be executed concurrently after the cache has been cleared, or nil.
 */
- (void)removeAllObjects:(TMCacheBlock)block;

// ----------------------------------
// Synchronize methods
// ----------------------------------

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
 Removes all objects from the cache. This method blocks the calling thread until the cache has been cleared.
 */
- (void)removeAllObjects;

@end
