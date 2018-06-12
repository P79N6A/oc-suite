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

#import "_aes.h"
#import "_des.h"
#import "_base64.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

// ----------------------------------
// Category source code
// ----------------------------------

@implementation NSData ( Aes )

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key {
    return [self AES128EncryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key {
    return [self AES128DecryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv {
    return [self AES128Operation:kCCEncrypt key:key iv:iv options:kCCOptionPKCS7Padding | kCCOptionECBMode];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv {
    return [self AES128Operation:kCCDecrypt key:key iv:iv options:kCCOptionPKCS7Padding];
}

- (NSData *)AES128DecryptedDataWithKeyData:(NSData *)key ivData:(NSData *)iv {
    return [self AES128Operation:kCCDecrypt keyData:key ivData:iv options:kCCOptionPKCS7Padding];
}

- (NSData *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv options:(uint32_t)options {
    return [[self pad:0] AES128Operation:operation keyData:[key dataUsingEncoding:NSUTF8StringEncoding] ivData:[iv dataUsingEncoding:NSUTF8StringEncoding] options:options];
}

// kCCModeCBC
- (NSData *)AES128Operation:(CCOperation)operation keyData:(NSData *)key ivData:(NSData *)iv options:(uint32_t)options {
    NSParameterAssert(key);
    
    size_t bufferSize = self.length + kCCKeySizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t decryptedLength = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          options,
                                          key.bytes,
                                          kCCKeySizeAES256,
                                          iv.bytes,
                                          self.bytes,
                                          self.length,
                                          buffer,
                                          bufferSize,
                                          &decryptedLength);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:decryptedLength];
    }
    
    free(buffer);
    return nil;
}

- (NSData *)pad:(NSUInteger)blockSize {
    NSMutableData *data = self.mutableCopy;
    if (blockSize == 0)
        blockSize = 16;
    
    NSUInteger count = (blockSize - (data.length % blockSize)) % blockSize;
    data.length = data.length + count;
    
    return data;
}

/**
 *  利用AES加密数据
 *
 *  @param key key
 *  @param iv  iv description
 *
 *  @return data
 */
- (NSData *)encryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv {
    return [self CCCryptData:self algorithm:kCCAlgorithmAES128 operation:kCCEncrypt key:key iv:iv];
}
/**
 *  @brief  利用AES解密据
 *
 *  @param key key
 *  @param iv  iv
 *
 *  @return 解密后数据
 */
- (NSData *)decryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv {
    return [self CCCryptData:self algorithm:kCCAlgorithmAES128 operation:kCCDecrypt key:key iv:iv];
}

@end

@implementation NSString ( Aes )

- (NSString *)encryptedWithAESUsingKey:(NSString *)key andIV:(NSData *)iv {
    NSData *encrypted = [[self dataUsingEncoding:NSUTF8StringEncoding] encryptedWithAESUsingKey:key andIV:iv];
    NSString *encryptedString = [encrypted base64EncodedString];
    
    return encryptedString;
}

- (NSString *)decryptedWithAESUsingKey:(NSString *)key andIV:(NSData *)iv {
    NSData *decrypted = [[NSData dataWithBase64EncodedString:self] decryptedWithAESUsingKey:key andIV:iv];
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}

@end

// ----------------------------------
// Source code
// ----------------------------------

@implementation _aes

@end
