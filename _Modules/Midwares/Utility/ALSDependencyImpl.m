//
//  ALSDependencyImpl.m
//  wesg
//
//  Created by 7 on 11/02/2018.
//  Copyright © 2018 AliSports. All rights reserved.
//

#import "ALSportsPrecompile.h"
#import "ALSDependencyImpl.h"


@implementation ALSDependencyImpl

- (BOOL)isQQInstalled {
#if __has_ALSTencentOpenAPI
    return [QQApiInterface isQQInstalled];
#else
    return NO;
#endif
}

- (BOOL)isTIMInstalled {
#if __has_ALSTencentOpenAPI
    return [QQApiInterface isTIMInstalled];
#else
    return NO;
#endif
}

@end
