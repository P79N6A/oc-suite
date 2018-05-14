//
//  _cache.h
//  component
//
//  Created by fallen.ink on 4/18/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_greats.h"
#import "_cache_object_subscripting.h"
#import "_cache_manager.h"
#import "_memory_cache.h"
#import "_disk_cache.h"

/// TODO: 对特定的字段，事件通知，CacheEventValueChanged

NS_ASSUME_NONNULL_BEGIN

@class _Cache;

/**
 * A callback block which provides only the cache as an argument
 */
typedef void (^ CacheBlock)(_Cache *cache);
/**
 * A callback block which provides the cache, key and object as arguments
 */
typedef void (^ CacheObjectBlock)(_Cache *cache, NSString *key, __nullable id object);
/**
 * A callback block which provides a BOOL value as argument
 */
typedef void (^ CacheObjectContainmentBlock)(BOOL containsObject);
/**
 * A callback block which provides a int, int 2 as arguments
 */
typedef void (^ CacheProgressBlock)(int removedCount, int totalCount);
/**
 * A callback block which provides a bool value as argument
 */
typedef void (^ CacheEndBlock)(BOOL end);

/** inspired by PINCache
 `_Cache` is a thread safe key/value store designed for persisting temporary objects that are expensive to
 reproduce, such as downloaded data or the results of slow processing. It is comprised of two self-similar
 stores, one in memory (<MemoryCache>) and one on disk (<DiskCache>).
 
 `Cache` itself actually does very little; its main function is providing a front end for a common use case:
 a small, fast memory cache that asynchronously persists itself to a large, slow disk cache. When objects are
 removed from the memory cache in response to an "apocalyptic" event they remain in the disk cache and are
 repopulated in memory the next time they are accessed. `PINCache` also does the tedious work of creating a
 dispatch group to wait for both caches to finish their operations without blocking each other.
 
 The parallel caches are accessible as public properties (<memoryCache> and <diskCache>) and can be manipulated
 separately if necessary. See the docs for <MemoryCache> and <DiskCache> for more details.
 
 @warning when using in extension or watch extension, define PIN_APP_EXTENSIONS=1
 */

@interface _Cache : NSObject <CacheObjectSubscripting>

@singleton( _Cache )

/**
 *  @desc
 *  1. 缓存使用量遍历
 *  2. Memory cache 使用量
 *  3. Disk cache 使用量
 *  4. 更新通知？
 */
@prop_singleton( _CacheManager, manager )

/**
 *  内存缓存
 */
@prop_singleton( _MemoryCache, memoryCache )

/**
 *  磁盘混存
 */
@prop_singleton( _DiskCache, diskCache )

// ----------------------------------
// Properties
// ----------------------------------

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) dispatch_queue_t concurrentQueue;

// ----------------------------------
// Asynchronize methods
// ----------------------------------

/**
 *  @desc This method determines whether an object is present for the given key in the cache. This method returns immediately
 and executes the passed block after the object is available, potentially in parallel with other blocks on the
 <concurrentQueue>.
 
 *  @see containsObjectForKey:
 *  @param key The key associated with the object.
 *  @param block A block to be executed concurrently after the containment check happened
 */
- (void)containsObjectForKey:(NSString *)key block:(nullable CacheObjectContainmentBlock)block;

/**
 *  @param key   The key associated with the requested object.
 *  @param block block A block to be executed concurrently when the object is available.
 */
- (void)objectForKey:(NSString *)key block:(nullable CacheObjectBlock)block;

/**
 *  @param object An object to store in the cache.
 *  @param key    A key to associate with the object. This string will be copied.
 *  @param block  A block to be executed concurrently after the object has been stored, or nil.
 */
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(nullable CacheObjectBlock)block;

/**
 *  @param key   The key associated with the object to be removed.
 *  @param block A block to be executed concurrently after the object has been removed, or nil.
 */
- (void)removeObjectForKey:(NSString *)key block:(nullable CacheObjectBlock)block;

/**
 *  Removes all objects from the cache that have not been used since the specified date.
 *
 *  @param date  Objects that haven't been accessed since this date are removed from the cache.
 *  @param block A block to be executed concurrently after the cache has been trimmed, or nil.
 */
- (void)trimToDate:(NSDate *)date block:(nullable CacheBlock)block;

/**
 *  @param block A block to be executed concurrently after the cache has been cleared, or nil.
 */
- (void)removeAllObjects:(nullable CacheBlock)block;

/**
 *  Empties the cache with block.
 *  This method returns immediately and executes the clear operation with block in background.
 
 *  @warning You should not send message to this instance in these blocks.
 *  @param progress This block will be invoked during removing, pass nil to ignore.
 *  @param end      This block will be invoked at the end, pass nil to ignore.
 */
- (void)removeAllObjectsWithProgressBlock:(nullable CacheProgressBlock)progress
                                 endBlock:(nullable CacheEndBlock)end;

// ----------------------------------
// Synchronize methods
// ----------------------------------

/**
 *  @desc This method determines whether an object is present for the given key in the cache.
 
 *  @see containsObjectForKey:block:
 *  @param key The key associated with the object.
 *  @result YES if an object is present for the given key in the cache, otherwise NO.
 */
- (BOOL)containsObjectForKey:(NSString *)key;

- (nullable id)objectForKey:(NSString *)key;

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)trimToDate:(NSDate *)date;

- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END

// ----------------------------------
// 便捷属性, 必须是对象类型
// ----------------------------------
#undef  prop_cache
#define prop_cache(type, name)    property (nonatomic, strong) type name;

#undef  def_prop_cache
#define def_prop_cache(type, name, setter) \
        dynamic name; \
        - (type)name { \
            return _cache_[@#name]; \
        } \
        - (void)setter:(type)name { \
            _cache_[@#name] = name; \
        } \

// ----------------------------------
// 同步方法，推荐用下标 cache['']
// ----------------------------------
#define _cache_ [_Cache sharedInstance] // Specially
#define memory_cache [_MemoryCache sharedInstance]
#define disk_cache [_DiskCache sharedInstance]
