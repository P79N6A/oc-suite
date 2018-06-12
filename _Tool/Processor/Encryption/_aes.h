//
//     ____              _____    _____    _____
//    / ___\   /\ /\     \_   \   \_  _\  /\  __\
//    \ \     / / \ \     / /\/    / /    \ \  _\_
//  /\_\ \    \ \_/ /  /\/ /_     / /      \ \____\
//  \____/     \___/   \____/    /__|       \/____/
//
//	Copyright BinaryArtists development team and other contributors
//
//	https://github.com/BinaryArtists/suite.great
//
//	Free to use, prefer to discuss!
//
//  Welcome!
//

#import <Foundation/Foundation.h>

// ----------------------------------
// Category code
// ----------------------------------

@interface NSData ( Aes )

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key;
- (NSData *)AES128DecryptedDataWithKey:(NSString *)key;
- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv;

/** Pads data using PKCS5. blockSize defaults to 16 if given 0. */
- (NSData *)pad:(NSUInteger)blockSize;

/**
 *  利用AES加密数据
 *
 *  @param key  key 长度一般为16（AES算法所能支持的密钥长度可以为128,192,256位（也即16，24，32个字节））
 *  @param iv  iv description
 *
 *  @return data
 */
- (NSData *)encryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv;
/**
 *  @brief  利用AES解密据
 *
 *  @param key key 长度一般为16 （AES算法所能支持的密钥长度可以为128,192,256位（也即16，24，32个字节））
 *  @param iv  iv
 *
 *  @return 解密后数据
 */
- (NSData *)decryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv;

@end

@interface NSString ( Aes )

/**
 *  AES加密数据
 *
 *  @param key  key 长度一般为16（AES算法所能支持的密钥长度可以为128,192,256位（也即16，24，32个字节））
 *  @param iv  iv
 *
 *  @return data
 */
- (NSString *)encryptedWithAESUsingKey:(NSString *)key andIV:(NSData *)iv;

/**
 *  AES解密数据
 *
 *  @param key key 长度一般为16
 *  @param iv  iv
 *
 *  @return data
 */
- (NSString *)decryptedWithAESUsingKey:(NSString *)key andIV:(NSData *)iv;

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _aes : NSObject

@end
