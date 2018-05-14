#import "_CacheManager.h"
#import "_MemoryCache.h"
#import "_DiskCache.h"

@implementation _CacheManager
@def_singleton( _CacheManager )

#pragma mark - mem cache



#pragma mark - Public Synchronous Accessors

- (NSUInteger)diskByteCount {
    __block NSUInteger byteCount = 0;
    
    [[_DiskCache sharedInstance] synchronouslyLockFileAccessWhileExecutingBlock:^(_DiskCache *diskCache) {
        byteCount = diskCache.byteCount;
    }];
    
    return byteCount;
}

#pragma mark - Property

- (NSString *)rootPath {
    return path_of_cache;
}

@end
