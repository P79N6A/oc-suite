//
//  ALSErrorImpl.m
//  wesg
//
//  Created by 7 on 22/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "ALSportsPrecompile.h"
#import "ALSErrorImpl.h"

@implementation NSError (ALSErrorImpl)

- (NSString *)message {
    return self.userInfo[kErrorMessageKey];
}

+ (instancetype)withCode:(int64_t)code message:(NSString *)message {
    return [self withDomain:kAlisportsErrorDomain code:code message:message];
}

+ (instancetype)withDomain:(NSString *)domain code:(int64_t)code message:(NSString *)message {
    NSMutableDictionary *userInfo = [@{} mutableCopy];
    
    userInfo[kErrorMessageKey] = message ? : @"未知错误";
    
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    
    
    return error;
}

- (void)showAsToast {
#if __has_iToast
    [[iToast makeText:self.message] show];
#endif
}

- (void)showAsAlert {

}

@end
