//
//  GrowthCache.m
//  consumer
//
//  Created by 张衡的mini on 16/12/26.
//
//

#import "GrowthCache.h"

@implementation Growth

@end

@implementation GrowthCache

@def_singleton( GrowthCache )

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSArray *)allObjects{
    
    return nil;
}

- (NSInteger)allObjectsCount {
//    NSObject *results = [Growth allObjects];
    
    ASSERT(@"未实现")
    
    return 0;
}

- (void)addObject:(NSObject *)obj {
    
}

- (void)removeAllObject {
    
}

@end
