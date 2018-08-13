#import <Foundation/Foundation.h>

typedef enum {
    _OperationEncrypt,
    _OperationDecrypt
} _OperationCrypt;

typedef enum {
    _OptionCBCMode        = 0x0000,
    _OptionPKCS7Padding   = 0x0001,
    _OptionECBMode        = 0x0002
} _OperationCryptOptions;

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

@interface _AES : NSObject

//AES128加解密
+ (NSString *)AES256Operation:(_OperationCrypt)operation withString:(NSString *)content key:(NSString *)key mode:(_OperationCryptOptions)options;

//AES256加解密
+ (NSString *)AES128Operation:(_OperationCrypt)operation withString:(NSString *)content Key:(NSString *)key vector:(NSString *)vector mode:(_OperationCryptOptions)options;

@end
