//
//  NSObject+KeyChain.m
// fallen.ink
//
//  Created by 李杰 on 5/19/15.
//
//

#import "NSObject+KeyChain.h"
#import "_keychain.h"

@implementation NSObject (KeyChain)

- (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account {
    return [_Keychain passwordForService:serviceName account:account];
}

- (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account {
    return [_Keychain setPassword:password forService:serviceName account:account];
}

@end
