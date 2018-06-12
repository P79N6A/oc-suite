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
#import <CommonCrypto/CommonCrypto.h>

// ----------------------------------
// Category code
// ----------------------------------

@interface NSData ( Sha )

@property (nonatomic, readonly) NSData *sha1Data;
@property (nonatomic, readonly) NSData *sha256Data;
@property (nonatomic, readonly) NSData *sha512Data;

@property (nonatomic, readonly) NSString *sha256Hash;

/**
 *  @brief  sha1Data NSData
 *
 *  @param key 密钥
 *
 *  @return 结果
 */
- (NSData *)hmacSHA1DataWithKey:(NSData *)key;

/**
 *  @brief  sha256Data NSData
 *
 *  @param key 密钥
 *
 *  @return 结果
 */
- (NSData *)hmacSHA256DataWithKey:(NSData *)key;

/**
 *  @brief  sha512Data NSData
 *
 *  @param key 密钥
 *
 *  @return 结果
 */
- (NSData *)hmacSHA512DataWithKey:(NSData *)key;

- (NSData *)hmacDataUsingAlg:(CCHmacAlgorithm)alg withKey:(NSData *)key;

@end

@interface NSString ( AesHash )

/// 返回结果：40长度   终端命令：echo -n "123" | openssl sha -sha1
@property (readonly) NSString *sha1String;
/// 返回结果：56长度   终端命令：echo -n "123" | openssl sha -sha224
@property (readonly) NSString *sha224String;
/// 返回结果：64长度   终端命令：echo -n "123" | openssl sha -sha256
@property (readonly) NSString *sha256String;
/// 返回结果：96长度   终端命令：echo -n "123" | openssl sha -sha384
@property (readonly) NSString *sha384String;
/// 返回结果：128长度   终端命令：echo -n "123" | openssl sha -sha512
@property (readonly) NSString *sha512String;

/// 返回结果：40长度   echo -n "123" | openssl sha -sha1 -hmac "123"
- (NSString *)hmacSHA1StringWithKey:(NSString *)key;
- (NSString *)hmacSHA224StringWithKey:(NSString *)key;
- (NSString *)hmacSHA256StringWithKey:(NSString *)key;
- (NSString *)hmacSHA384StringWithKey:(NSString *)key;
- (NSString *)hmacSHA512StringWithKey:(NSString *)key;

- (NSString *)hmacStringUsingAlg:(CCHmacAlgorithm)alg withKey:(NSString *)key;
- (NSString *)stringFromBytes:(unsigned char *)bytes length:(int)length;

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _sha : NSObject

@end
