//
//  _cache.m
//  component
//
//  Created by fallen.ink on 4/18/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_cache.h"

static NSString * const CachePrefix = @"com.fallenink.Cache";
static NSString * const CacheSharedName = @"CacheShared";

@interface _Cache () {
    NSString *_name;
}

@property (strong, nonatomic) dispatch_queue_t concurrentQueue;

@end

@implementation _Cache

@def_singleton( _Cache )

@def_prop_singleton( _CacheManager, manager )

@def_prop_singleton( _MemoryCache, memoryCache )

@def_prop_singleton( _DiskCache, diskCache )

- (instancetype)init {
    if (self = [super init]) {
        [self initDefault];
    }
    
    return self;
}

- (void)initDefault {
    _name = CacheSharedName;
    
    NSString *queueName = [[NSString alloc] initWithFormat:@"%@.%p", CachePrefix, self];
    _concurrentQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
}

- (NSString *)description {
    return [[NSString alloc] initWithFormat:@"%@.%@.%p", CachePrefix, _name, self];
}

#pragma mark - Asynchronize methods

- (void)containsObjectForKey:(NSString *)key block:(CacheObjectContainmentBlock)block {
    if (!key || !block) {
        return;
    }
    
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        
        BOOL containsObject = [self containsObjectForKey:key];
        block(containsObject);
    });
}

- (void)objectForKey:(NSString *)key block:(CacheObjectBlock)block {
    if (!key || !block)
        return;
    
    @weakify(self)
    
    dispatch_async(_concurrentQueue, ^{
        @strongify(self)
        if (!self)
            return;
        [self.memoryCache objectForKey:key block:^(_MemoryCache *memoryCache, NSString *memoryCacheKey, id memoryCacheObject) {
            @strongify(self)
            if (!self)
                return;
            
            if (memoryCacheObject) {
                [self.diskCache fileURLForKey:memoryCacheKey block:^(_DiskCache *diskCache, NSString *diskCacheKey, id <NSCoding> diskCacheObject, NSURL *fileURL) {
                    // update the access time on disk
                }];
                dispatch_async(self->_concurrentQueue, ^{
                    @strongify(self)
                    if (self)
                        block(self, memoryCacheKey, memoryCacheObject);
                });
            } else {
                [self.diskCache objectForKey:memoryCacheKey block:^(_DiskCache *diskCache, NSString *diskCacheKey, id <NSCoding> diskCacheObject, NSURL *fileURL) {
                    @strongify(self)
                    if (!self)
                        return;
                    
                    [self.memoryCache setObject:diskCacheObject forKey:diskCacheKey block:nil];
                    
                    
                    dispatch_async(self->_concurrentQueue, ^{
                        @strongify(self)
                        if (self)
                            block(self, diskCacheKey, diskCacheObject);
                    });
                }];
            }
        }];
    });
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(CacheObjectBlock)block {
    if (!key || !object)
        return;
    
    dispatch_group_t group = nil;
    MemoryCacheObjectBlock memBlock = nil;
    DiskCacheObjectBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(_MemoryCache *memoryCache, NSString *memoryCacheKey, id memoryCacheObject) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(_DiskCache *diskCache, NSString *diskCacheKey, id <NSCoding> memoryCacheObject, NSURL *memoryCacheFileURL) {
            dispatch_group_leave(group);
        };
    }
    
    [self.memoryCache setObject:object forKey:key block:memBlock];
    [self.diskCache setObject:object forKey:key block:diskBlock];
    
    if (group) {
        @weakify(self)
        
        dispatch_group_notify(group, _concurrentQueue, ^{
            @strongify(self)
            
            if (self)
                block(self, key, object);
        });
    }
}

- (void)removeObjectForKey:(NSString *)key block:(CacheObjectBlock)block {
    if (!key)
        return;
    
    dispatch_group_t group = nil;
    MemoryCacheObjectBlock memBlock = nil;
    DiskCacheObjectBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(_MemoryCache *memoryCache, NSString *memoryCacheKey, id memoryCacheObject) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(_DiskCache *diskCache, NSString *diskCacheKey, id <NSCoding> memoryCacheObject, NSURL *memoryCacheFileURL) {
            dispatch_group_leave(group);
        };
    }
    
    [self.memoryCache removeObjectForKey:key block:memBlock];
    [self.diskCache removeObjectForKey:key block:diskBlock];
    
    if (group) {
        @weakify(self)
        
        dispatch_group_notify(group, _concurrentQueue, ^{
            @strongify(self)
            
            if (self)
                block(self, key, nil);
        });
    }
}

- (void)removeAllObjects:(CacheBlock)block {
    dispatch_group_t group = nil;
    MemoryCacheBlock memBlock = nil;
    DiskCacheBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(_MemoryCache *cache) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(_DiskCache *cache) {
            dispatch_group_leave(group);
        };
    }
    
    [self.memoryCache removeAllObjects:memBlock];
    [self.diskCache removeAllObjects:diskBlock];
    
    if (group) {
        @weakify(self)
        
        dispatch_group_notify(group, _concurrentQueue, ^{
            @strongify(self)
            
            if (self)
                block(self);
        });
    }
}

- (void)trimToDate:(NSDate *)date block:(CacheBlock)block {
    if (!date)
        return;
    
    dispatch_group_t group = nil;
    MemoryCacheBlock memBlock = nil;
    DiskCacheBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(_MemoryCache *cache) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(_DiskCache *cache) {
            dispatch_group_leave(group);
        };
    }
    
    [self.memoryCache trimToDate:date block:memBlock];
    [self.diskCache trimToDate:date block:diskBlock];
    
    if (group) {
        @weakify(self)
        
        dispatch_group_notify(group, _concurrentQueue, ^{
            @strongify(self)
            if (self)
                block(self);
        });
    }
}

- (void)removeAllObjectsWithProgressBlock:(CacheProgressBlock)progress endBlock:(CacheEndBlock)end {
    [self.memoryCache removeAllObjects];
//    [self.diskCache removeAllObjectsWithProgressBlock:progress endBlock:end];
    exceptioning(@"未实现")
}

#pragma mark - Synchronize methods

- (BOOL)containsObjectForKey:(NSString *)key {
    if (!key) {
        return NO;
    }
    
    return [self.memoryCache containsObjectForKey:key] || [self.diskCache containsObjectForKey:key];
}

- (id)objectForKey:(NSString *)key {
    if (!key)
        return nil;
    
    __block id object = nil;
    
    object = [self.memoryCache objectForKey:key];
    
    if (object) {
        // update the access time on disk
        [self.diskCache fileURLForKey:key block:NULL];
    } else {
        object = [self.diskCache objectForKey:key];
        [self.memoryCache setObject:object forKey:key];
    }
    
    return object;
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key {
    if (!key || !object)
        return;
    
    [self.memoryCache setObject:object forKey:key];
    [self.diskCache setObject:object forKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
    if (!key)
        return;
    
    [self.memoryCache removeObjectForKey:key];
    [self.diskCache removeObjectForKey:key];
}

- (void)trimToDate:(NSDate *)date {
    if (!date)
        return;
    
    [self.memoryCache trimToDate:date];
    [self.diskCache trimToDate:date];
}

- (void)removeAllObjects {
    [self.memoryCache removeAllObjects];
    [self.diskCache removeAllObjects];
}

#pragma mark - CacheObjectSubscripting

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    [self setObject:obj forKey:key];
}

@end
