//
//  DBTransitEncryptor+Base64.m
//  Pods
//
//  Created by David Benko on 6/16/14.
//
//

#import "_transit_encryptor_extension.h"

@implementation _TransitEncryptor ( Base64 )

#pragma mark - Base64 Handling

NSString* base64EncodeData(NSData* data) {
    return [data base64EncodedStringWithOptions:0];
}

NSData* base64DecodeData(NSString *base64) {
    return [[NSData alloc]initWithBase64EncodedString:base64 options:0];
}

#pragma mark - Encryption

- (NSString *)encryptAndBase64EncodeData:(NSData *)data base64RsaEncryptedKey:(NSString **)key iv:(NSData **)iv error:(NSError **)error{
    NSData *keyData = nil;
	NSData *encryptedData = [self encryptData:data rsaEncryptedKey:&keyData iv:iv error:error];
    *key = base64EncodeData(keyData);
    keyData = nil;
    return base64EncodeData(encryptedData);
}

- (NSString *)encryptAndBase64EncodeData:(NSData *)data withIVMixer:(IVMixerBlock)ivMixer base64RsaEncryptedKey:(NSString **)key error:(NSError **)error{
	NSData *keyData = nil;
	NSData *encryptedData = [self encryptData:data withIVMixer:ivMixer rsaEncryptedKey:&keyData error:error];
    *key = base64EncodeData(keyData);
    keyData = nil;
    return base64EncodeData(encryptedData);
}

- (NSString *)encryptAndBase64EncodeString:(NSString *)string base64RsaEncryptedKey:(NSString **)key iv:(NSData **)iv error:(NSError **)error{
    NSData *keyData = nil;
	NSData *encryptedData = [self encryptString:string rsaEncryptedKey:&keyData iv:iv error:error];
    *key = base64EncodeData(keyData);
    keyData = nil;
    return base64EncodeData(encryptedData);
}

- (NSString *)encryptAndBase64EncodeString:(NSString *)string withIVMixer:(IVMixerBlock)ivMixer base64RsaEncryptedKey:(NSString **)key error:(NSError **)error{
    NSData *keyData = nil;
	NSData *encryptedData = [self encryptString:string withIVMixer:ivMixer rsaEncryptedKey:&keyData error:error];
    *key = base64EncodeData(keyData);
    keyData = nil;
    return base64EncodeData(encryptedData);
}

#pragma mark - Decryption

- (NSData *)base64decodeAndDecryptData:(NSString *)base64Data base64RsaEncryptedKey:(NSString *)key iv:(NSData *)iv error:(NSError **)error{
    NSData *data = base64DecodeData(base64Data);
    NSData *keyContents = base64DecodeData(key);
    return [self decryptData:data rsaEncryptedKey:keyContents iv:iv error:error];
}

- (NSData *)base64decodeAndDecryptData:(NSString *)base64Data withIVSeparator:(IVSeparatorBlock)ivSeparator base64RsaEncryptedKey:(NSString *)key error:(NSError **)error{
    NSData *data = base64DecodeData(base64Data);
    NSData *keyContents = base64DecodeData(key);
    return [self decryptData:data withIVSeparator:ivSeparator rsaEncryptedKey:keyContents error:error];
}

- (NSString *)base64decodeAndDecryptString:(NSString *)base64Data base64RsaEncryptedKey:(NSString *)key iv:(NSData *)iv error:(NSError **)error{
    NSData *data = base64DecodeData(base64Data);
    NSData *keyContents = base64DecodeData(key);
    return [self decryptString:data rsaEncryptedKey:keyContents iv:iv error:error];
}

- (NSString *)base64decodeAndDecryptString:(NSString *)base64Data withIVSeparator:(IVSeparatorBlock)ivSeparator base64RsaEncryptedKey:(NSString *)key error:(NSError **)error{
    NSData *data = base64DecodeData(base64Data);
    NSData *keyContents = base64DecodeData(key);
    return [self decryptString:data withIVSeparator:ivSeparator rsaEncryptedKey:keyContents error:error];
}

@end

@implementation _TransitEncryptor ( NSString )

#pragma mark - Encryption

- (NSData *)encryptString:(NSString *)string rsaEncryptedKey:(NSData **)key iv:(NSData **)iv error:(NSError **)error{
    NSData *dataToEncrypt = [string dataUsingEncoding:self.encryptorStringEncoding];
    return [self encryptData:dataToEncrypt rsaEncryptedKey:key iv:iv error:error];
}

- (NSData *)encryptString:(NSString *)string withIVMixer:(IVMixerBlock)ivMixer rsaEncryptedKey:(NSData **)key error:(NSError **)error {
    NSData *dataToEncrypt = [string dataUsingEncoding:self.encryptorStringEncoding];
    return [self encryptData:dataToEncrypt withIVMixer:ivMixer rsaEncryptedKey:key error:error];
}

#pragma mark - Decryption

- (NSString *)decryptString:(NSData *)data rsaEncryptedKey:(NSData *)key iv:(NSData *)iv error:(NSError **)error{
    NSData *decryptedData = [self decryptData:data rsaEncryptedKey:key iv:iv error:error];
    return [[NSString alloc]initWithData:decryptedData encoding:self.encryptorStringEncoding];
}

- (NSString *)decryptString:(NSData *)data withIVSeparator:(IVSeparatorBlock)ivSeparator rsaEncryptedKey:(NSData *)key error:(NSError **)error{
    NSData *decryptedData = [self decryptData:data withIVSeparator:ivSeparator rsaEncryptedKey:key error:error];
    return [[NSString alloc]initWithData:decryptedData encoding:self.encryptorStringEncoding];
}

@end
