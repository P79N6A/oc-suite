//
//  ALSUserImpl.m
//  wesg
//
//  Created by 7 on 22/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "ALSUserImpl.h"
#if __has_AESUser
#import "AESUser.h"
#endif

@implementation ALSUserImpl

- (NSString *)uuid {
#if __has_AESUser
    return [AESUser currentUser].uid;
#else
    return nil;
#endif
}

- (NSString *)token {
#if __has_AESUser
    return [AESUser currentUser].skey;
#else
    return nil;
#endif
}

@end
