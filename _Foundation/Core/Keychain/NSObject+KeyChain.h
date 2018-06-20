
#import <Foundation/Foundation.h>

/**
 *  Only for password, account related to a serviceName
 */
@interface NSObject (KeyChain)

- (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;
- (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;

@end
