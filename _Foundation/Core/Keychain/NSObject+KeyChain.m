
#import "NSObject+KeyChain.h"
#import "_Keychain.h"

@implementation NSObject (KeyChain)

- (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account {
    return [_Keychain passwordForService:serviceName account:account];
}

- (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account {
    return [_Keychain setPassword:password forService:serviceName account:account];
}

@end
