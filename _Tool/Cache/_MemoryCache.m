#import <pthread.h>
#import "_MemoryCache.h"
#import "_LinkedMap.h"

//@property (nonatomic, strong) dispatch_semaphore_t lockSemaphore;
//    dispatch_semaphore_wait(_lockSemaphore, DISPATCH_TIME_FOREVER);
//    dispatch_semaphore_signal(_lockSemaphore);

#define LOCK \
    pthread_mutex_lock(&self->_lock);

#define UNLOCK \
    pthread_mutex_unlock(&self->_lock);

#define lockable( code ) \
{ \
    pthread_mutex_lock(&self->_lock); \
    code \
    pthread_mutex_unlock(&self->_lock); \
}

#define trylockable( code ) \
if (pthread_mutex_trylock(&self->_lock) == 0) { \
    code \
    pthread_mutex_unlock(&self->_lock); \
}

NSString * const MemoryCachePrefix = @"com.fallenink.MemoryCache";

@interface _MemoryCache ()

@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@property (nonatomic, assign) pthread_mutex_t lock;

/**
 * 如果不使用LinkedMap，则需要三个容器：存放KV、内存消耗、TTL
 */
@property (nonatomic, strong) _LinkedMap *lru;

@end

@implementation _MemoryCache

@synthesize ageLimit = _ageLimit;
@synthesize costLimit = _costLimit;
@synthesize totalCost = _totalCost;
@synthesize willAddObjectBlock = _willAddObjectBlock;
@synthesize willRemoveObjectBlock = _willRemoveObjectBlock;
@synthesize willRemoveAllObjectsBlock = _willRemoveAllObjectsBlock;
@synthesize didAddObjectBlock = _didAddObjectBlock;
@synthesize didRemoveObjectBlock = _didRemoveObjectBlock;
@synthesize didRemoveAllObjectsBlock = _didRemoveAllObjectsBlock;
@synthesize didReceiveMemoryWarningBlock = _didReceiveMemoryWarningBlock;
@synthesize didEnterBackgroundBlock = _didEnterBackgroundBlock;

@def_singleton( _MemoryCache )

#pragma mark - Life cycle

- (instancetype)init {
    if (self = [super init]) {
        [self initDefault];
        
        [self initObserver];
    }
    
    return self;
}

- (void)initDefault {
    pthread_mutex_init(&_lock, NULL);
    
    NSString *queueName = [[NSString alloc] initWithFormat:@"%@.%p", MemoryCachePrefix, (void *)self];
    _concurrentQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
    
    _lru = [_LinkedMap new];
    
    _willAddObjectBlock = nil;
    _willRemoveObjectBlock = nil;
    _willRemoveAllObjectsBlock = nil;
    _didAddObjectBlock = nil;
    _didRemoveObjectBlock = nil;
    _didRemoveAllObjectsBlock = nil;
    
    _didReceiveMemoryWarningBlock = nil;
    _didEnterBackgroundBlock = nil;
    
    _countLimit = NSUIntegerMax;
    _costLimit = NSUIntegerMax;
    _ageLimit = DBL_MAX;
    _autoTrimInterval = 5.0;
    
    _removeAllObjectsOnMemoryWarning = YES;
    _removeAllObjectsOnEnteringBackground = YES;
    
    [self _trimRecursively];
}

- (void)initObserver {
    [self observeNotification:UIApplicationDidReceiveMemoryWarningNotification];
    [self observeNotification:UIApplicationDidEnterBackgroundNotification];
}

- (void)dealloc {
    [self unobserveAllNotifications];
    
    [_lru removeAllObjects];
}

// MARK: - Setter & Getter

- (NSUInteger)totalCount {
    lockable( NSUInteger count = _lru->_totalCount; return count; )
}

- (NSUInteger)totalCost {
    lockable( NSUInteger totalCost = _lru->_totalCost; return totalCost; )
}

- (MemoryCacheObjectBlock)willAddObjectBlock {
    lockable( MemoryCacheObjectBlock block = _willAddObjectBlock; return block; )
}

- (void)setWillAddObjectBlock:(MemoryCacheObjectBlock)block {
    lockable( _willAddObjectBlock = [block copy]; )
}

- (MemoryCacheObjectBlock)willRemoveObjectBlock {
    lockable( MemoryCacheObjectBlock block = _willRemoveObjectBlock; return block; )
}

- (void)setWillRemoveObjectBlock:(MemoryCacheObjectBlock)block {
    lockable( _willRemoveObjectBlock = [block copy]; )
}

- (MemoryCacheBlock)willRemoveAllObjectsBlock {
    lockable( MemoryCacheBlock block = _willRemoveAllObjectsBlock; return block; )
}

- (void)setWillRemoveAllObjectsBlock:(MemoryCacheBlock)block {
    lockable( _willRemoveAllObjectsBlock = [block copy]; )
}

- (MemoryCacheObjectBlock)didAddObjectBlock {
    lockable( MemoryCacheObjectBlock block = _didAddObjectBlock; return block; )
}

- (void)setDidAddObjectBlock:(MemoryCacheObjectBlock)block {
    lockable( _didAddObjectBlock = [block copy]; )
}

- (MemoryCacheObjectBlock)didRemoveObjectBlock {
    lockable( MemoryCacheObjectBlock block = _didRemoveObjectBlock; return block; )
}

- (void)setDidRemoveObjectBlock:(MemoryCacheObjectBlock)block {
    lockable( _didRemoveObjectBlock = [block copy]; )
}

- (MemoryCacheBlock)didRemoveAllObjectsBlock {
    lockable( MemoryCacheBlock block = _didRemoveAllObjectsBlock; return block; )
}

- (void)setDidRemoveAllObjectsBlock:(MemoryCacheBlock)block {
    lockable( _didRemoveAllObjectsBlock = [block copy]; )
}

- (MemoryCacheBlock)didReceiveMemoryWarningBlock {
    lockable( MemoryCacheBlock block = _didReceiveMemoryWarningBlock; return block; )
}

- (void)setDidReceiveMemoryWarningBlock:(MemoryCacheBlock)block {
    lockable( _didReceiveMemoryWarningBlock = [block copy]; )
}

- (MemoryCacheBlock)didEnterBackgroundBlock {
    lockable( MemoryCacheBlock block = _didEnterBackgroundBlock; return block; )
}

- (void)setDidEnterBackgroundBlock:(MemoryCacheBlock)block {
    lockable( _didEnterBackgroundBlock = [block copy]; )
}

#pragma mark - Memory warning handling

- (void)handleNotification:(NSNotification *)notification {
    if ([notification is:UIApplicationDidReceiveMemoryWarningNotification]) {
        [self handleMemoryWarning];
    } else if ([notification is:UIApplicationDidEnterBackgroundNotification]) {
        [self handleApplicationBackgrounding];
    }
}

- (void)handleMemoryWarning {
    if (self.removeAllObjectsOnMemoryWarning)
        [self removeAllObjects:nil];
    
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        
        @strongify(self)

        if (!self) {
            return;
        }
        
        MemoryCacheBlock didReceiveMemoryWarningBlock = nil;
        lockable(
            didReceiveMemoryWarningBlock = self->_didReceiveMemoryWarningBlock;
        )
        
        if (didReceiveMemoryWarningBlock)
            didReceiveMemoryWarningBlock(self);
    });
}

- (void)handleApplicationBackgrounding {
    if (self.removeAllObjectsOnEnteringBackground)
        [self removeAllObjects:nil];
    
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        
        @strongify(self);

        if (!self) {
            return;
        }
        
        LOCK
        MemoryCacheBlock didEnterBackgroundBlock = self->_didEnterBackgroundBlock;
        UNLOCK
        
        if (didEnterBackgroundBlock)
            didEnterBackgroundBlock(self);
    });
}

#pragma mark -

- (void)removeObjectAndExecuteBlocksForKey:(NSString *)key {
    MemoryCacheObjectBlock willRemoveObjectBlock = _willRemoveObjectBlock;
    MemoryCacheObjectBlock didRemoveObjectBlock = _didRemoveObjectBlock;
    
    lockable(
             id obj = [_lru objectForKey:key];
             
             if (willRemoveObjectBlock)
             willRemoveObjectBlock(self, key, obj);
             
             if (obj) {
                 [_lru removeObjectForKey:key];
             }
             
             dispatch_async(_concurrentQueue, ^{
                /**
                 * 不是延迟释放，只是为了提供一个思路：数据资源在子线程释放、视图资源在主线程释放
                 */
                 [obj class]; //hold and release in queue
             });
    )
    
    if (didRemoveObjectBlock)
        didRemoveObjectBlock(self, key, nil);
}


#pragma mark - Asynchronous Methods

- (void)containsObjectForKey:(NSString *)key block:(MemoryCacheContainmentBlock)block {
    if (!key || !block)
        return;
    
    @weakify(self);
    
    dispatch_async(_concurrentQueue, ^{
        
        @strongify(self);

        BOOL containsObject = [self containsObjectForKey:key];
        
        block(containsObject);
    });
}

- (void)objectForKey:(NSString *)key block:(MemoryCacheObjectBlock)block {
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        
        id object = [self objectForKey:key];
        
        if (block)
            block(self, key, object);
    });
}

- (void)setObject:(id)object forKey:(NSString *)key block:(MemoryCacheObjectBlock)block {
    [self setObject:object forKey:key withCost:0 block:block];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost block:(MemoryCacheObjectBlock)block {
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        [self setObject:object forKey:key withCost:cost];
        
        if (block)
            block(self, key, object);
    });
}

- (void)removeObjectForKey:(NSString *)key block:(MemoryCacheObjectBlock)block {
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        [self removeObjectForKey:key];
        
        if (block)
            block(self, key, nil);
    });
}

- (void)removeAllObjects:(MemoryCacheBlock)block {
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        
        [self removeAllObjects];
        
        if (block)
            block(self);
    });
}

- (void)enumerateObjectsWithBlock:(MemoryCacheObjectBlock)block completionBlock:(MemoryCacheBlock)completionBlock {
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        
        [self enumerateObjectsWithBlock:block];
        
        if (completionBlock)
            completionBlock(self);
    });
}


#pragma mark - Synchronize methods

- (BOOL)containsObjectForKey:(NSString *)key {
    if (!key)
        return NO;
    
    LOCK
    id obj = [_lru objectForKey:key];
    UNLOCK
    return !!obj;
}

- (id)objectForKey:(NSString *)key {
    if (!key)
        return nil;
    
    lockable( return [_lru objectForKey:key]; )
}

- (void)setObject:(id)object forKey:(NSString *)key {
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost {
    if (!key)
        return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    
    MemoryCacheObjectBlock willAddObjectBlock = _willAddObjectBlock;
    MemoryCacheObjectBlock didAddObjectBlock = _didAddObjectBlock;

    if (willAddObjectBlock)
        willAddObjectBlock(self, key, object);
    
    // 加锁
    lockable(
             [_lru setObject:object forKey:key withCost:cost];
             
             if ([_lru isObjectCostsOverflow:_costLimit]) { // 总量限制
                 dispatch_async(_concurrentQueue, ^{
                     [self trimToCost:self->_costLimit];
                 });
             }
             
             if ([_lru isObjectCountsOverflow:_countLimit]) { // 总数限制
                 object = [_lru removeObject];
                 
                 dispatch_async(_concurrentQueue, ^{
                     [object class];
                 });
             }
             
    )
    
    if (didAddObjectBlock)
        didAddObjectBlock(self, key, object);
}

- (void)removeObjectForKey:(NSString *)key {
    if (!key)
        return;
    
    [self removeObjectAndExecuteBlocksForKey:key];
}

- (void)removeAllObjects {
    MemoryCacheBlock willRemoveAllObjectsBlock = _willRemoveAllObjectsBlock;
    MemoryCacheBlock didRemoveAllObjectsBlock = _didRemoveAllObjectsBlock;
    
    if (willRemoveAllObjectsBlock)
        willRemoveAllObjectsBlock(self);
    
    lockable( [_lru removeAllObjects]; )
    
    if (didRemoveAllObjectsBlock)
        didRemoveAllObjectsBlock(self);
}

- (void)enumerateObjectsWithBlock:(MemoryCacheObjectBlock)block {
    if (!block)
        return;
    
    LOCK
    weakly(self)
    [_lru enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj) {
        block(_, key, obj);
    }];
    UNLOCK
}

// MARK: - CacheObjectSubscripting

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    [self setObject:obj forKey:key];
}

// MARK: - Trim

- (void)trimToAge:(NSTimeInterval)age block:(MemoryCacheBlock)block {
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        [self trimToAge:age];
        
        if (block)
            block(self);
    });
}

- (void)trimToCost:(NSUInteger)cost block:(MemoryCacheBlock)block {
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        [self trimToCost:cost];
        
        if (block)
            block(self);
    });
}

- (void)trimToCount:(NSUInteger)count block:(MemoryCacheBlock)block {
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        [self trimToCount:count];
        
        if (block)
            block(self);
    });
}

- (void)trimToCount:(NSUInteger)count {
    if (count == 0) {
        [self removeAllObjects];
        return;
    }
    [self _trimToCount:count];
}

- (void)trimToCost:(NSUInteger)cost {
    [self _trimToCost:cost];
}

- (void)trimToAge:(NSTimeInterval)age {
    [self _trimToAge:age];
}

#pragma mark - Private

- (void)_trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        [self _trimInBackground];
        [self _trimRecursively];
    });
}

- (void)_trimInBackground {
    dispatch_async(_concurrentQueue, ^{
        [self _trimToCost:self->_costLimit];
        [self _trimToCount:self->_countLimit];
        [self _trimToAge:self->_ageLimit];
    });
}

- (void)_trimToCost:(NSUInteger)costLimit {
    BOOL finish = NO;

    lockable(
         if (costLimit == 0) {
             [_lru removeAllObjects];
             finish = YES;
         } else if (![_lru isObjectCostsOverflow:costLimit]) {
             finish = YES;
         }
    )
    
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        
        trylockable(
            if (_lru->_totalCost > costLimit) {
                id object = [_lru removeObject];
                if (object) [holder addObject:object];
            } else {
                finish = YES;
            }
        ) else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_async(_concurrentQueue, ^{
            [holder count]; // release in queue
        });
    }
}

- (void)_trimToCount:(NSUInteger)countLimit {
    BOOL finish = NO;
    LOCK
    if (countLimit == 0) {
        [_lru removeAllObjects];
        finish = YES;
    } else if (_lru->_totalCount <= countLimit) {
        finish = YES;
    }
    UNLOCK
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        trylockable(
                    if ([_lru isObjectCountsOverflow:countLimit]) {
                id object = [_lru removeObject];
                if (object) [holder addObject:object];
            } else {
                finish = YES;
            }
        ) else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_async(_concurrentQueue, ^{
            [holder count]; // release in queue
        });
    }
}

- (void)_trimToAge:(NSTimeInterval)ageLimit {
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();

    lockable(
        if (ageLimit <= 0) {
            [_lru removeAllObjects];
            finish = YES;
        } else if (!_lru->_tail || (now - _lru->_tail->_time) <= ageLimit) {
            finish = YES;
        }
    )
    
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        trylockable(
            if (_lru->_tail && (now - _lru->_tail->_time) > ageLimit) {
                id object = [_lru removeObject];
                if (object) [holder addObject:object];
            } else {
                finish = YES;
            }
        ) else {
            usleep(10 * 1000); //10 ms
        }

    }
    if (holder.count) {
        dispatch_async(_concurrentQueue, ^{
            [holder count]; // release in queue
        });
    }
}

@end
