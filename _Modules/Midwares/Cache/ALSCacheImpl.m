//
//  ALSCacheImpl.m
//  NewStructure
//
//  Created by 7 on 20/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "ALSCacheImpl.h"

@implementation ALSCacheImpl

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx {
    return nil;
}

- (void)setObject:(nonnull id)obj atIndexedSubscript:(NSUInteger)idx {
    
}

- (nullable id)objectForKeyedSubscript:(nonnull NSString *)key {
#if __has_AEDataKit
    id result = [[AEDKCacheOperation operation].withOperationType(AEDKCacheOperationTypeRead).withKey(key) withResult];
    
    return result;
    
#endif
    return nil;
}

- (void)setObject:(nullable id)obj forKeyedSubscript:(nonnull NSString *)key {
#if __has_AEDataKit
    [[AEDKCacheOperation operation].withOperationType(AEDKCacheOperationTypeWrite).withKey(key).withValue(obj) withResult];
#endif
}

@end
