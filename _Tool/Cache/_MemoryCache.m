//
//  _memory_cache.m
//  consumer
//
//  Created by fallen.ink on 6/20/16.
//
//

#import "_memory_cache.h"

NSString * const MemoryCachePrefix = @"com.fallenink.MemoryCache";

@interface _MemoryCache ()

@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@property (nonatomic, strong) dispatch_semaphore_t lockSemaphore;

@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) NSMutableDictionary *dates;
@property (nonatomic, strong) NSMutableDictionary *costs;

@end

@implementation _MemoryCache

@synthesize ageLimit = _ageLimit;
@synthesize costLimit = _costLimit;
@synthesize totalCost = _totalCost;
@synthesize ttlCache = _ttlCache;
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
    _lockSemaphore = dispatch_semaphore_create(1);
    NSString *queueName = [[NSString alloc] initWithFormat:@"%@.%p", MemoryCachePrefix, (void *)self];
    _concurrentQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
    
    _dictionary = [[NSMutableDictionary alloc] init];
    _dates = [[NSMutableDictionary alloc] init];
    _costs = [[NSMutableDictionary alloc] init];
    
    _willAddObjectBlock = nil;
    _willRemoveObjectBlock = nil;
    _willRemoveAllObjectsBlock = nil;
    
    _didAddObjectBlock = nil;
    _didRemoveObjectBlock = nil;
    _didRemoveAllObjectsBlock = nil;
    
    _didReceiveMemoryWarningBlock = nil;
    _didEnterBackgroundBlock = nil;
    
    _ageLimit = 0.0;
    _costLimit = 0;
    _totalCost = 0;
    
    _removeAllObjectsOnMemoryWarning = YES;
    _removeAllObjectsOnEnteringBackground = YES;
}

- (void)initObserver {
    [self observeNotification:UIApplicationDidReceiveMemoryWarningNotification];
    [self observeNotification:UIApplicationDidEnterBackgroundNotification];
}

- (void)dealloc {
    [self unobserveAllNotifications];
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
        
        @strongify(self);

        if (!self) {
            return;
        }
        
        [self lock];
        MemoryCacheBlock didReceiveMemoryWarningBlock = self->_didReceiveMemoryWarningBlock;
        [self unlock];
        
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
        
        [self lock];
        MemoryCacheBlock didEnterBackgroundBlock = self->_didEnterBackgroundBlock;
        [self unlock];
        
        if (didEnterBackgroundBlock)
            didEnterBackgroundBlock(self);
    });
}

#pragma mark -

- (void)removeObjectAndExecuteBlocksForKey:(NSString *)key {
    [self lock];
    
    id object = _dictionary[key];
    NSNumber *cost = _costs[key];
    MemoryCacheObjectBlock willRemoveObjectBlock = _willRemoveObjectBlock;
    MemoryCacheObjectBlock didRemoveObjectBlock = _didRemoveObjectBlock;
    [self unlock];
    
    if (willRemoveObjectBlock)
        willRemoveObjectBlock(self, key, object);
    
    [self lock];
    if (cost)
        _totalCost -= [cost unsignedIntegerValue];
    
    [_dictionary removeObjectForKey:key];
    [_dates removeObjectForKey:key];
    [_costs removeObjectForKey:key];
    [self unlock];
    
    if (didRemoveObjectBlock)
        didRemoveObjectBlock(self, key, nil);
}

- (void)trimMemoryToDate:(NSDate *)trimDate {
    [self lock];
    NSArray *keysSortedByDate = [_dates keysSortedByValueUsingSelector:@selector(compare:)];
    NSDictionary *dates = [_dates copy];
    [self unlock];
    
    for (NSString *key in keysSortedByDate) { // oldest objects first
        NSDate *accessDate = dates[key];
        if (!accessDate)
            continue;
        
        if ([accessDate compare:trimDate] == NSOrderedAscending) { // older than trim date
            [self removeObjectAndExecuteBlocksForKey:key];
        } else {
            break;
        }
    }
}

- (void)trimToCostLimit:(NSUInteger)limit {
    NSUInteger totalCost = 0;
    
    [self lock];
    totalCost = _totalCost;
    NSArray *keysSortedByCost = [_costs keysSortedByValueUsingSelector:@selector(compare:)];
    [self unlock];
    
    if (totalCost <= limit) {
        return;
    }
    
    for (NSString *key in [keysSortedByCost reverseObjectEnumerator]) { // costliest objects first
        [self removeObjectAndExecuteBlocksForKey:key];
        
        [self lock];
        totalCost = _totalCost;
        [self unlock];
        
        if (totalCost <= limit)
            break;
    }
}

- (void)trimToCostLimitByDate:(NSUInteger)limit {
    NSUInteger totalCost = 0;
    
    [self lock];
    totalCost = _totalCost;
    NSArray *keysSortedByDate = [_dates keysSortedByValueUsingSelector:@selector(compare:)];
    [self unlock];
    
    if (totalCost <= limit)
        return;
    
    for (NSString *key in keysSortedByDate) { // oldest objects first
        [self removeObjectAndExecuteBlocksForKey:key];
        
        [self lock];
        totalCost = _totalCost;
        [self unlock];
        if (totalCost <= limit)
            break;
    }
}

- (void)trimToAgeLimitRecursively {
    [self lock];
    NSTimeInterval ageLimit = _ageLimit;
    [self unlock];
    
    if (ageLimit == 0.0)
        return;
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-ageLimit];
    
    [self trimMemoryToDate:date];
    
    @weakify(self)
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ageLimit * NSEC_PER_SEC));
    dispatch_after(time, _concurrentQueue, ^(void){
        
        @strongify(self);
        
        [self trimToAgeLimitRecursively];
    });
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

- (void)trimToDate:(NSDate *)trimDate block:(MemoryCacheBlock)block {
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        [self trimToDate:trimDate];
        
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

- (void)trimToCostByDate:(NSUInteger)cost block:(MemoryCacheBlock)block {
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        [self trimToCostByDate:cost];
        
        if (block)
            block(self);
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
    
    [self lock];
    BOOL containsObject = (_dictionary[key] != nil);
    [self unlock];
    return containsObject;
}

- (id)objectForKey:(NSString *)key {
    if (!key)
        return nil;
    
    NSDate *now = [[NSDate alloc] init];
    [self lock];
    id object = nil;
    // If the cache should behave like a TTL cache, then only fetch the object if there's a valid ageLimit and  the object is still alive
    if (!self->_ttlCache || self->_ageLimit <= 0 || fabs([[_dates objectForKey:key] timeIntervalSinceDate:now]) < self->_ageLimit) {
        object = _dictionary[key];
    }
    [self unlock];
    
    if (object) {
        [self lock];
        _dates[key] = now;
        [self unlock];
    }
    
    return object;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost {
    if (!key || !object)
        return;
    
    [self lock];
    MemoryCacheObjectBlock willAddObjectBlock = _willAddObjectBlock;
    MemoryCacheObjectBlock didAddObjectBlock = _didAddObjectBlock;
    NSUInteger costLimit = _costLimit;
    [self unlock];
    
    if (willAddObjectBlock)
        willAddObjectBlock(self, key, object);
    
    [self lock];
    _dictionary[key] = object;
    _dates[key] = [[NSDate alloc] init];
    _costs[key] = @(cost);
    
    _totalCost += cost;
    [self unlock];
    
    if (didAddObjectBlock)
        didAddObjectBlock(self, key, object);
    
    if (costLimit > 0)
        [self trimToCostByDate:costLimit];
}

- (void)removeObjectForKey:(NSString *)key {
    if (!key)
        return;
    
    [self removeObjectAndExecuteBlocksForKey:key];
}

- (void)trimToDate:(NSDate *)trimDate {
    if (!trimDate)
        return;
    
    if ([trimDate isEqualToDate:[NSDate distantPast]]) {
        [self removeAllObjects];
        return;
    }
    
    [self trimMemoryToDate:trimDate];
}

- (void)trimToCost:(NSUInteger)cost {
    [self trimToCostLimit:cost];
}

- (void)trimToCostByDate:(NSUInteger)cost {
    [self trimToCostLimitByDate:cost];
}

- (void)removeAllObjects {
    [self lock];
    MemoryCacheBlock willRemoveAllObjectsBlock = _willRemoveAllObjectsBlock;
    MemoryCacheBlock didRemoveAllObjectsBlock = _didRemoveAllObjectsBlock;
    [self unlock];
    
    if (willRemoveAllObjectsBlock)
        willRemoveAllObjectsBlock(self);
    
    [self lock];
    [_dictionary removeAllObjects];
    [_dates removeAllObjects];
    [_costs removeAllObjects];
    
    _totalCost = 0;
    [self unlock];
    
    if (didRemoveAllObjectsBlock)
        didRemoveAllObjectsBlock(self);
}

- (void)enumerateObjectsWithBlock:(MemoryCacheObjectBlock)block {
    if (!block)
        return;
    
    [self lock];
    NSDate *now = [[NSDate alloc] init];
    NSArray *keysSortedByDate = [_dates keysSortedByValueUsingSelector:@selector(compare:)];
    
    for (NSString *key in keysSortedByDate) {
        // If the cache should behave like a TTL cache, then only fetch the object if there's a valid ageLimit and  the object is still alive
        if (!self->_ttlCache || self->_ageLimit <= 0 || fabs([[_dates objectForKey:key] timeIntervalSinceDate:now]) < self->_ageLimit) {
            block(self, key, _dictionary[key]);
        }
    }
    [self unlock];
}

#pragma mark - Public Thread Safe Accessors -

- (MemoryCacheObjectBlock)willAddObjectBlock {
    [self lock];
    MemoryCacheObjectBlock block = _willAddObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setWillAddObjectBlock:(MemoryCacheObjectBlock)block {
    [self lock];
    _willAddObjectBlock = [block copy];
    [self unlock];
}

- (MemoryCacheObjectBlock)willRemoveObjectBlock {
    [self lock];
    MemoryCacheObjectBlock block = _willRemoveObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setWillRemoveObjectBlock:(MemoryCacheObjectBlock)block {
    [self lock];
    _willRemoveObjectBlock = [block copy];
    [self unlock];
}

- (MemoryCacheBlock)willRemoveAllObjectsBlock {
    [self lock];
    MemoryCacheBlock block = _willRemoveAllObjectsBlock;
    [self unlock];
    
    return block;
}

- (void)setWillRemoveAllObjectsBlock:(MemoryCacheBlock)block {
    [self lock];
    _willRemoveAllObjectsBlock = [block copy];
    [self unlock];
}

- (MemoryCacheObjectBlock)didAddObjectBlock {
    [self lock];
    MemoryCacheObjectBlock block = _didAddObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setDidAddObjectBlock:(MemoryCacheObjectBlock)block {
    [self lock];
    _didAddObjectBlock = [block copy];
    [self unlock];
}

- (MemoryCacheObjectBlock)didRemoveObjectBlock {
    [self lock];
    MemoryCacheObjectBlock block = _didRemoveObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setDidRemoveObjectBlock:(MemoryCacheObjectBlock)block {
    [self lock];
    _didRemoveObjectBlock = [block copy];
    [self unlock];
}

- (MemoryCacheBlock)didRemoveAllObjectsBlock {
    [self lock];
    MemoryCacheBlock block = _didRemoveAllObjectsBlock;
    [self unlock];
    
    return block;
}

- (void)setDidRemoveAllObjectsBlock:(MemoryCacheBlock)block {
    [self lock];
    _didRemoveAllObjectsBlock = [block copy];
    [self unlock];
}

- (MemoryCacheBlock)didReceiveMemoryWarningBlock {
    [self lock];
    MemoryCacheBlock block = _didReceiveMemoryWarningBlock;
    [self unlock];
    
    return block;
}

- (void)setDidReceiveMemoryWarningBlock:(MemoryCacheBlock)block {
    [self lock];
    _didReceiveMemoryWarningBlock = [block copy];
    [self unlock];
}

- (MemoryCacheBlock)didEnterBackgroundBlock {
    [self lock];
    MemoryCacheBlock block = _didEnterBackgroundBlock;
    [self unlock];
    
    return block;
}

- (void)setDidEnterBackgroundBlock:(MemoryCacheBlock)block {
    [self lock];
    _didEnterBackgroundBlock = [block copy];
    [self unlock];
}

- (NSTimeInterval)ageLimit {
    [self lock];
    NSTimeInterval ageLimit = _ageLimit;
    [self unlock];
    
    return ageLimit;
}

- (void)setAgeLimit:(NSTimeInterval)ageLimit {
    [self lock];
    _ageLimit = ageLimit;
    [self unlock];
    
    [self trimToAgeLimitRecursively];
}

- (NSUInteger)costLimit {
    [self lock];
    NSUInteger costLimit = _costLimit;
    [self unlock];
    
    return costLimit;
}

- (void)setCostLimit:(NSUInteger)costLimit {
    [self lock];
    _costLimit = costLimit;
    [self unlock];
    
    if (costLimit > 0)
        [self trimToCostLimitByDate:costLimit];
}

- (NSUInteger)totalCost {
    [self lock];
    NSUInteger cost = _totalCost;
    [self unlock];
    
    return cost;
}

- (BOOL)isTTLCache {
    BOOL isTTLCache;
    
    [self lock];
    isTTLCache = _ttlCache;
    [self unlock];
    
    return isTTLCache;
}

- (void)setTtlCache:(BOOL)ttlCache {
    [self lock];
    _ttlCache = ttlCache;
    [self unlock];
}


- (void)lock {
    dispatch_semaphore_wait(_lockSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_lockSemaphore);
}

#pragma mark - CacheObjectSubscripting

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    [self setObject:obj forKey:key];
}

@end
