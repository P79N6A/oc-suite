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

#import "_precompile.h"

// ----------------------------------
// Category code
// ----------------------------------

@interface NSData ( MD5 )

@property (nonatomic, readonly) NSData *	MD5Data;
@property (nonatomic, readonly) NSString *	MD5String;

@property (nonatomic, readonly) NSString *	MD5Hash;

/**
 *  @brief  md5 NSData
 *
 *  @param key 密钥
 *
 *  @return 结果
 */
- (NSData *)hmacMD5DataWithKey:(NSData *)key;

@end

@interface NSString ( MD5Hash )

/// 返回结果：32长度(128位，16字节，16进制字符输出则为32字节长度)   终端命令：md5 -s "123"
@property (readonly) NSString *md5String;

/// 返回结果：32长度  终端命令：echo -n "123" | openssl dgst -md5 -hmac "123"
- (NSString *)hmacMD5StringWithKey:(NSString *)key;

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _md5 : NSObject

@end
