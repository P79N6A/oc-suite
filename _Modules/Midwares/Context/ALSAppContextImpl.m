//
//  ALSAppContextImpl.m
//  wesg
//
//  Created by 7 on 27/12/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "ALSAppContextImpl.h"

@implementation ALSAppContextImpl

- (void)launch {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAppContextLaunch object:nil];
}

- (void)ready {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAppContextReady object:nil];
}

@end
