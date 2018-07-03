//
//  NSObject+GrowthAttributes.m
//  consumer
//
//  Created by fallen on 16/11/23.
//
//

#import "NSObject+GrowthAttributes.h"
#import "_foundation.h"

@implementation NSObject (GrowthAttributes)

- (void)setGrowthAttributesUniqueTag:(NSString *)growthAttributesUniqueTag {
    if (![self hasAssociatedObjectForKey:"growthAttributesUniqueTag"]) {
        [self assignAssociatedObject:growthAttributesUniqueTag forKey:"growthAttributesUniqueTag"];
        
        // Do nothing
    }
}

- (NSString *)growthAttributesUniqueTag {
    return [self getAssociatedObjectForKey:"growthAttributesUniqueTag"];
}


@end
