//
//  ALSEncryptionImpl.m
//  wesg
//
//  Created by 7 on 28/02/2018.
//  Copyright © 2018 AliSports. All rights reserved.
//

#import "ALSportsPrecompile.h"
#import "ALSEncryptionImpl.h"

@implementation ALSEncryptionImpl
@synthesize aesKey;
@synthesize aesSecret;

- (NSString *)dynamicEncrypt:(NSString *)plainText {
#if __has_SecurityGuardSDK
    id<IOpenDynamicDataEncryptComponent> component =
    [[OpenSecurityGuardManager getInstance] getDynamicDataEncryptComp];
    
    if (component) {
        NSString *encrytpedString = [component dynamicEncrypt:plainText];
        
        return encrytpedString;
    }
    
    return plainText;
#endif
    
    return plainText;
}

- (NSString *)dynamicDecrypt:(NSString *)cipherText {
#if __has_SecurityGuardSDK
    id<IOpenDynamicDataEncryptComponent> component =
    [[OpenSecurityGuardManager getInstance] getDynamicDataEncryptComp];
    
    if (component) {
        NSString *plainString = [component dynamicDecrypt:cipherText];
        
        return plainString;
    }
    
#endif
    
    return cipherText;
}

// MARK: -

- (NSString *)aesEncrypt:(NSString *)plainText {
#if __has_SecurityGuardSDK
#endif
    return plainText;
}

- (NSString *)aesDecrypt:(NSString *)cipherText {
    
#if __has_SecurityGuardSDK
#endif
    
    return cipherText;
}

// MARK: -

- (NSString *)stringAtIndex:(int32_t)index {
    
#if __has_SecurityGuardSDK
    id<IOpenStaticDataStoreComponent> component =
    [[OpenSecurityGuardManager getInstance] getStaticDataStoreComp];
    
    NSString *str = [component getAppKey:@(index) authCode:nil];
    
    return str;
    
#endif
    
    return nil;
}

- (NSString *)stringForKey:(NSString *)key {
    
#if __has_SecurityGuardSDK
    id<IOpenStaticDataStoreComponent> component =
    [[OpenSecurityGuardManager getInstance] getStaticDataStoreComp];
    
    NSString *str = [component getExtraData:key authCode:nil];
    
    return str;
#endif
    
    return nil;
}

@end
