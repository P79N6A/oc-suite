/**
 * 线程安全 数组
 *
 * 注意：使用串行队列实现, 异步写入/同步读取
 */

// MARK: - _SerialQueuedDictionary

#import "_ThreadSafeDictionary.h"

@interface _SerialQueuedDictionary ()

@property (strong,nonatomic) NSMutableDictionary *internalDictionary;
@property (nonatomic) dispatch_queue_t tsQueue;

@end

@implementation _SerialQueuedDictionary

- (instancetype)init {
    
    self = [super init];
    
    _internalDictionary = [[NSMutableDictionary alloc]init];
    _tsQueue = dispatch_queue_create("com.xxx._MutableDictionary", NULL);
    
    return self;
}

- (id)objectForKeyedSubscript:(id)key {
    
    NSObject *__block result;
    dispatch_sync(_tsQueue, ^{
        result = self->_internalDictionary[key];
    });
    
    return result;
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    
    dispatch_async(_tsQueue, ^{
        self->_internalDictionary[key] = obj;
    });
}

- (NSDictionary *)toNSDictionary {
    
    NSDictionary *__block result;
    dispatch_sync(_tsQueue, ^{
        result = self->_internalDictionary;
    });
    
    return result;
}

- (void)removeObjectForkey:(NSString *)key {
    
    dispatch_async(_tsQueue, ^{
        [self->_internalDictionary removeObjectForKey:key];
    });
}

- (void)removeAllObjects {
    
    dispatch_async(_tsQueue, ^{
        [self->_internalDictionary removeAllObjects];
    });
}

@end

// MARK: - _MutexDictionary

#import <pthread.h>

static const NSUInteger kDefaultCapacity = 5;

@implementation _MutexDictionary {
    pthread_mutex_t _lock;
    CFMutableDictionaryRef _dictionary;
}

- (void)dealloc {
    if (&_lock) {
        pthread_mutex_destroy(&_lock);
    }
    if (_dictionary) {
        CFRelease(_dictionary);
        _dictionary = NULL;
    }
}

#pragma mark - Init
+ (instancetype)dictionary {
    return [[self alloc] init];
}

+ (instancetype)dictionaryWithCapacity:(NSUInteger)num {
    return [[self alloc] initWithCapacity:num];
}

+ (instancetype)dictionaryWithDictionary:(NSDictionary *)otherDictionary {
    _MutexDictionary *dictionary = [[self alloc] init];
    [dictionary addEntriesFromDictionary:otherDictionary];
    return dictionary;
}

+ (instancetype)dictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey {
    _MutexDictionary *dictionary = [[self alloc] init];
    [dictionary setObject:anObject forKey:aKey];
    return dictionary;
}

- (instancetype)init {
    return [self initWithCapacity:kDefaultCapacity];
}

- (instancetype)initWithCapacity:(NSUInteger)num {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        _dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, num,
                                                &kCFTypeDictionaryKeyCallBacks,
                                                &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

#pragma mark - Copy
- (id)copyWithZone:(NSZone *)zone {
    NSDictionary *dictionary = nil;
    
    pthread_mutex_lock(&_lock);
    CFDictionaryRef dictionaryRef = CFDictionaryCreateCopy(kCFAllocatorDefault, _dictionary);
    if (dictionaryRef) {
        dictionary = CFBridgingRelease(dictionaryRef);
    }
    pthread_mutex_unlock(&_lock);
    
    return dictionary;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSMutableDictionary *mutableDictionary = nil;
    
    pthread_mutex_lock(&_lock);
    CFMutableDictionaryRef mutableDictionaryRef = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, CFDictionaryGetCount(_dictionary), _dictionary);
    if (mutableDictionaryRef) {
        mutableDictionary = CFBridgingRelease(mutableDictionaryRef);
    }
    pthread_mutex_unlock(&_lock);
    
    return mutableDictionary;
}
#pragma mark - Add
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!anObject || !aKey) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    CFDictionarySetValue(_dictionary, (__bridge const void *)aKey, (__bridge const void *)anObject);
    pthread_mutex_unlock(&_lock);
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey {
    [self setObject:object forKey:aKey];
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    if (!([otherDictionary isKindOfClass:[NSDictionary class]] && (otherDictionary.count > 0))) {
        return;
    }
    
    //Ensure is NSDictionary
    NSDictionary *copiedDictionary = [otherDictionary copy];
    
    pthread_mutex_lock(&_lock);
    [copiedDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        CFDictionarySetValue(self->_dictionary, (__bridge const void *)key, (__bridge const void *)obj);
    }];
    pthread_mutex_unlock(&_lock);
}

#pragma mark - Remove
- (void)removeObjectForKey:(id)aKey {
    if (!aKey) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    CFDictionaryRemoveValue(_dictionary, (__bridge const void *)aKey);
    pthread_mutex_unlock(&_lock);
}

- (void)removeAllObjects {
    pthread_mutex_lock(&_lock);
    CFDictionaryRemoveAllValues(_dictionary);
    pthread_mutex_unlock(&_lock);
}

#pragma mark - Query
- (NSUInteger)count {
    pthread_mutex_lock(&_lock);
    NSUInteger count = CFDictionaryGetCount(_dictionary);
    pthread_mutex_unlock(&_lock);
    
    return count;
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (id)objectForKey:(id)aKey {
    if (!aKey) {
        return nil;
    }
    
    pthread_mutex_lock(&_lock);
    id result = CFDictionaryGetValue(_dictionary, (__bridge const void *)(aKey));
    pthread_mutex_unlock(&_lock);
    
    return result;
}

#pragma mark - Enumerate
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    if (!block) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    NSUInteger count = CFDictionaryGetCount(_dictionary);
    if (count > 0) {
        CFTypeRef *keys = malloc(count * sizeof(CFTypeRef));
        CFTypeRef *values = malloc(count * sizeof(CFTypeRef));
        
        CFDictionaryGetKeysAndValues(_dictionary, (const void **) keys, (const void **) values);
        
        BOOL stop = NO;
        for (NSUInteger index = 0; index < count; index++) {
            if (stop) {
                break;
            }
            
            id key = (__bridge id)(keys[index]);
            id obj = (__bridge id)(values[index]);
            block(key, obj, &stop);
        }
        
        free(keys);
        free(values);
    }
    pthread_mutex_unlock(&_lock);
}

@end
