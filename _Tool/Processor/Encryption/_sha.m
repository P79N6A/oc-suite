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

#import "_sha.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

// ----------------------------------
// Category source code
// ----------------------------------

@implementation NSData ( Sha)

- (NSString *)sha256Hash {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (unsigned int)self.length, result);
    
    NSMutableString *hash = [NSMutableString string];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02x", result[i]];
    
    return hash;
}


/**
 *  @brief  sha1Data NSData
 */
- (NSData *)sha1Data {
    unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(self.bytes, (CC_LONG)self.length, bytes);
    return [NSData dataWithBytes:bytes length:CC_SHA1_DIGEST_LENGTH];
}
/**
 *  @brief  sha256Data NSData
 */
- (NSData *)sha256Data {
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (CC_LONG)self.length, bytes);
    return [NSData dataWithBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
}
/**
 *  @brief  sha512Data NSData
 */
- (NSData *)sha512Data {
    unsigned char bytes[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(self.bytes, (CC_LONG)self.length, bytes);
    return [NSData dataWithBytes:bytes length:CC_SHA512_DIGEST_LENGTH];
}

/**
 *  @brief  sha1Data NSData
 *
 *  @param key 密钥
 *
 *  @return 结果
 */
- (NSData *)hmacSHA1DataWithKey:(NSData *)key {
    return [self hmacDataUsingAlg:kCCHmacAlgSHA1 withKey:key];
}

/**
 *  @brief  sha256Data NSData
 *
 *  @param key 密钥
 *
 *  @return 结果
 */
- (NSData *)hmacSHA256DataWithKey:(NSData *)key {
    return [self hmacDataUsingAlg:kCCHmacAlgSHA256 withKey:key];
}

/**
 *  @brief  sha512Data NSData
 *
 *  @param key 密钥
 *
 *  @return 结果
 */
- (NSData *)hmacSHA512DataWithKey:(NSData *)key {
    return [self hmacDataUsingAlg:kCCHmacAlgSHA512 withKey:key];
}


- (NSData *)hmacDataUsingAlg:(CCHmacAlgorithm)alg withKey:(NSData *)key {
    
    size_t size;
    switch (alg) {
        case kCCHmacAlgMD5: size = CC_MD5_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA1: size = CC_SHA1_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA224: size = CC_SHA224_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA256: size = CC_SHA256_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA384: size = CC_SHA384_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA512: size = CC_SHA512_DIGEST_LENGTH; break;
        default: return nil;
    }
    unsigned char result[size];
    CCHmac(alg, [key bytes], key.length, self.bytes, self.length, result);
    return [NSData dataWithBytes:result length:size];
}

@end

@implementation NSString (JKHash)

- (NSString *)sha1String {
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA1_DIGEST_LENGTH];
}

- (NSString *)sha224String {
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA224(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)sha256String {
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)sha384String {
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA384(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)sha512String {
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA512_DIGEST_LENGTH];
}

- (NSString *)hmacSHA1StringWithKey:(NSString *)key {
    return [self hmacStringUsingAlg:kCCHmacAlgSHA1 withKey:key];
    
}

- (NSString *)hmacSHA224StringWithKey:(NSString *)key {
    return [self hmacStringUsingAlg:kCCHmacAlgSHA224 withKey:key];
}

- (NSString *)hmacSHA256StringWithKey:(NSString *)key {
    return [self hmacStringUsingAlg:kCCHmacAlgSHA256 withKey:key];
    
}

- (NSString *)hmacSHA384StringWithKey:(NSString *)key{
    return [self hmacStringUsingAlg:kCCHmacAlgSHA384 withKey:key];
}

- (NSString *)hmacSHA512StringWithKey:(NSString *)key {
    return [self hmacStringUsingAlg:kCCHmacAlgSHA512 withKey:key];
    
}

#pragma mark - Helpers

- (NSString *)hmacStringUsingAlg:(CCHmacAlgorithm)alg withKey:(NSString *)key {
    size_t size;
    switch (alg) {
        case kCCHmacAlgMD5: size = CC_MD5_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA1: size = CC_SHA1_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA224: size = CC_SHA224_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA256: size = CC_SHA256_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA384: size = CC_SHA384_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA512: size = CC_SHA512_DIGEST_LENGTH; break;
        default: return nil;
    }
    
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *messageData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *mutableData = [NSMutableData dataWithLength:size];
    CCHmac(alg, keyData.bytes, keyData.length, messageData.bytes, messageData.length, mutableData.mutableBytes);
    return [self stringFromBytes:(unsigned char *)mutableData.bytes length:(int)mutableData.length];
}

- (NSString *)stringFromBytes:(unsigned char *)bytes length:(int)length {
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < length; i++)
        [mutableString appendFormat:@"%02x", bytes[i]];
    return [NSString stringWithString:mutableString];
}
@end

// ----------------------------------
// Source code
// ----------------------------------

@implementation _sha

@end
