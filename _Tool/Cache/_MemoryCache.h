#import "_Foundation.h"
#import "_CacheObjectSubscripting.h"

@class _MemoryCache;

typedef void (^ MemoryCacheBlock)(_MemoryCache *cache);
typedef void (^ MemoryCacheObjectBlock)(_MemoryCache *cache, NSString *key, id object);
typedef void (^ MemoryCacheContainmentBlock)(BOOL containsObject);

/**
 * 接口类似：NSCache
 * 多线程下，QPS 不会高于单线程，但会降低多少要看具体情况。由于 cache 内部是用锁来保证线程安全的，所以线程数越多、访问竞争越激烈、CPU 资源就消耗越大，QPS 也就越低。在 App 开发里，一般使用时倒不会遇到这种极端情况
 */

@interface _MemoryCache : NSObject <CacheObjectSubscripting>

@singleton(_MemoryCache )

#pragma mark -

@property (nonatomic, assign, readonly) NSUInteger totalCount;
@property (nonatomic, assign, readonly) NSUInteger totalCost;

@property (nonatomic, assign) NSUInteger countLimit;
@property (nonatomic, assign) NSUInteger costLimit;
/**
 If ttlCache(Time to live.) is YES, the cache behaves like a ttlCache. This means that once an object enters the
 cache, it only lives as long as self.ageLimit. This has the following implications:
 - Accessing an object in the cache does not extend that object's lifetime in the cache
 - When attempting to access an object in the cache that has lived longer than self.ageLimit,
 the cache will behave as if the object does not exist
 
 */
@property (nonatomic, assign) NSTimeInterval ageLimit; // 访问、存放时不触发，只依赖定时器触发

@property NSTimeInterval autoTrimInterval;

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

@property (nonatomic, copy) MemoryCacheObjectBlock willAddObjectBlock;
@property (nonatomic, copy) MemoryCacheObjectBlock willRemoveObjectBlock;
@property (nonatomic, copy) MemoryCacheBlock willRemoveAllObjectsBlock;
@property (nonatomic, copy) MemoryCacheObjectBlock didAddObjectBlock;
@property (nonatomic, copy) MemoryCacheObjectBlock didRemoveObjectBlock;
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

/**
 If `YES`, the key-value pair will be released on main thread, otherwise on
 background thread. Default is NO.
 
 @discussion You may set this value to `YES` if the key-value object contains
 the instance which should be released in main thread (such as UIView/CALayer).
 */
@property (nonatomic, assign) BOOL releaseOnMainThread;

/**
 If `YES`, the key-value pair will be released asynchronously to avoid blocking
 the access methods, otherwise it will be released in the access method
 (such as removeObjectForKey:). Default is YES.
 */
@property (nonatomic, assign) BOOL releaseAsynchronously;

#pragma mark - Asynchronous Methods

- (void)containsObjectForKey:(NSString *)key block:(MemoryCacheContainmentBlock)block;
- (void)objectForKey:(NSString *)key block:(MemoryCacheObjectBlock)block;
- (void)setObject:(id)object forKey:(NSString *)key block:(MemoryCacheObjectBlock)block;
- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost block:(MemoryCacheObjectBlock)block;
- (void)removeObjectForKey:(NSString *)key block:(MemoryCacheObjectBlock)block;
- (void)removeAllObjects:(MemoryCacheBlock)block;

- (void)enumerateObjectsWithBlock:(MemoryCacheObjectBlock)block completionBlock:(MemoryCacheBlock)completionBlock;

#pragma mark - Synchronize methods

- (BOOL)containsObjectForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost;
- (void)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects;

- (void)enumerateObjectsWithBlock:(MemoryCacheObjectBlock)block;

#pragma mark - LRU

- (void)trimToCount:(NSUInteger)count;
- (void)trimToCost:(NSUInteger)cost;
- (void)trimToAge:(NSTimeInterval)age;

- (void)trimToAge:(NSTimeInterval)age block:(MemoryCacheBlock)block;
- (void)trimToCost:(NSUInteger)cost block:(MemoryCacheBlock)block;
- (void)trimToCount:(NSUInteger)cost block:(MemoryCacheBlock)block;

@end
