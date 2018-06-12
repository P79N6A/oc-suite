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

#import "_des.h"
#import "_base64.h"

// ----------------------------------
// Category source code
// ----------------------------------

@implementation NSData ( Des )

static void __fixKeyLengths(CCAlgorithm algorithm, NSMutableData * keyData, NSMutableData * ivData) {
    NSUInteger keyLength = [keyData length];
    switch ( algorithm ) {
        case kCCAlgorithmAES128: {
            if (keyLength <= 16) {
                [keyData setLength:16];
            } else if (keyLength>16 && keyLength <= 24) {
                [keyData setLength:24];
            } else {
                [keyData setLength:32];
            }
            
            break;
        }
            
        case kCCAlgorithmDES: {
            [keyData setLength:8];
            break;
        }
            
        case kCCAlgorithm3DES: {
            [keyData setLength:24];
            break;
        }
            
        case kCCAlgorithmCAST: {
            if (keyLength <5) {
                [keyData setLength:5];
            } else if ( keyLength > 16) {
                [keyData setLength:16];
            }
            
            break;
        }
            
        case kCCAlgorithmRC4: {
            if ( keyLength > 512)
                [keyData setLength:512];
            break;
        }
            
        default:
            break;
    }
    
    [ivData setLength:[keyData length]];
}

/**
 *  利用3DES加密数据
 *
 *  @param key key
 *  @param iv  iv description
 *
 *  @return data
 */
- (NSData*)encryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv {
    return [self CCCryptData:self algorithm:kCCAlgorithm3DES operation:kCCEncrypt key:key iv:iv];
}

/**
 *  @brief   利用3DES解密数据
 *
 *  @param key key
 *  @param iv  iv
 *
 *  @return 解密后数据
 */
- (NSData*)decryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv {
    return [self CCCryptData:self algorithm:kCCAlgorithm3DES operation:kCCDecrypt key:key iv:iv];
}

/**
 *  利用DES加密数据
 *
 *  @param key key
 *  @param iv  iv description
 *
 *  @return data
 */
- (NSData *)encryptedWithDESUsingKey:(NSString*)key andIV:(NSData*)iv {
    return [self CCCryptData:self algorithm:kCCAlgorithmDES operation:kCCEncrypt key:key iv:iv];
}

/**
 *  @brief   利用DES解密数据
 *
 *  @param key key
 *  @param iv  iv
 *
 *  @return 解密后数据
 */
- (NSData *)decryptedWithDESUsingKey:(NSString*)key andIV:(NSData*)iv {
    return [self CCCryptData:self algorithm:kCCAlgorithmDES operation:kCCDecrypt key:key iv:iv];
}

- (NSData *)CCCryptData:(NSData *)data
                 algorithm:(CCAlgorithm)algorithm
                 operation:(CCOperation)operation
                       key:(NSString *)key
                        iv:(NSData *)iv {
    NSMutableData *keyData = [[key dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    NSMutableData *ivData = [iv mutableCopy];
    
    size_t dataMoved;
    
    int size = 0;
    if (algorithm == kCCAlgorithmAES128 ||algorithm == kCCAlgorithmAES) {
        size = kCCBlockSizeAES128;
    } else if (algorithm == kCCAlgorithmDES) {
        size = kCCBlockSizeDES;
    } else if (algorithm == kCCAlgorithm3DES) {
        size = kCCBlockSize3DES;
    } else if (algorithm == kCCAlgorithmCAST) {
        size = kCCBlockSizeCAST;
    }
    
    NSMutableData *decryptedData = [NSMutableData dataWithLength:data.length + size];
    
    int option = kCCOptionPKCS7Padding | kCCOptionECBMode;
    if (iv) {
        option = kCCOptionPKCS7Padding;
    }
    
    __fixKeyLengths(algorithm, keyData,ivData);
    CCCryptorStatus result = CCCrypt(operation,                    // kCCEncrypt or kCCDecrypt
                                     algorithm,
                                     option,                        // Padding option for CBC Mode
                                     keyData.bytes,
                                     keyData.length,
                                     iv.bytes,
                                     data.bytes,
                                     data.length,
                                     decryptedData.mutableBytes,    // encrypted data out
                                     decryptedData.length,
                                     &dataMoved);                   // total data moved
    
    if (result == kCCSuccess) {
        decryptedData.length = dataMoved;
        return decryptedData;
    }
    
    return nil;
}

@end

@implementation NSString (JKEncrypt)

- (NSString *)encryptedWithDESUsingKey:(NSString *)key andIV:(NSData *)iv {
    NSData *encrypted = [[self dataUsingEncoding:NSUTF8StringEncoding] encryptedWithDESUsingKey:key andIV:iv];
    NSString *encryptedString = [encrypted base64EncodedString];
    
    return encryptedString;
}

- (NSString *)decryptedWithDESUsingKey:(NSString*)key andIV:(NSData*)iv {
    NSData *decrypted = [[NSData dataWithBase64EncodedString:self] decryptedWithDESUsingKey:key andIV:iv];
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}

- (NSString *)encryptedWith3DESUsingKey:(NSString *)key andIV:(NSData *)iv {
    NSData *encrypted = [[self dataUsingEncoding:NSUTF8StringEncoding] encryptedWith3DESUsingKey:key andIV:iv];
    NSString *encryptedString = [encrypted base64EncodedString];
    
    return encryptedString;
}

- (NSString *)decryptedWith3DESUsingKey:(NSString *)key andIV:(NSData *)iv {
    NSData *decrypted = [[NSData dataWithBase64EncodedString:self] decryptedWith3DESUsingKey:key andIV:iv];
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}

@end

// ----------------------------------
// Source code
// ----------------------------------

@implementation _des

@end
