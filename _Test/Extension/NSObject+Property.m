//
//  NSObject+Property.m
//  wesg
//
//  Created by 7 on 01/08/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "NSObject+Property.h"

@implementation NSObject (Property)

- (NSString *)className {
    return [self.class className];
}

+ (NSString *)className {
    return NSStringFromClass(self.class);
}

@end
