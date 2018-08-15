//
//  ALSEncryptionProtocol.h
//  wesg
//
//  Created by 7 on 28/02/2018.
//  Copyright © 2018 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol _EncryptionProtocol <NSObject>

/**
 *  动态加密字符串值
 *
 *  @param plainText 需要加密的字符串
 *
 *  @return 返回加密结果，加密失败返回nil
 */
- (NSString *)dynamicEncrypt:(NSString *)plainText;


/**
 *  动态解密字符串值
 *
 *  @param cipherText 需要解密的字符串
 *
 *  @return 返回解密结果，解密失败返回nil
 */
- (NSString *)dynamicDecrypt:(NSString *)cipherText;

// MARK: - AES
@property (nonatomic, strong) NSString *aesKey;
@property (nonatomic, strong) NSString *aesSecret;

- (NSString *)aesEncrypt:(NSString *)plainText;

- (NSString *)aesDecrypt:(NSString *)cipherText;

// MARK: - Security Pic

- (NSString *)stringAtIndex:(int32_t)index;

- (NSString *)stringForKey:(NSString *)key;

@end
