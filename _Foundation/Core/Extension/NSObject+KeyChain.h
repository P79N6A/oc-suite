//
//  NSObject+KeyChain.h
// fallen.ink
//
//  Created by 李杰 on 5/19/15.
//
//

#import <Foundation/Foundation.h>

/**
 *  Only for password, account related to a serviceName
 */
@interface NSObject (KeyChain)

- (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;
- (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;

@end
