
#import "NSData+Extension.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSData ( Extension )

- (NSString *)string {
    return [[NSString alloc] initWithData:self encoding:NSStringEncodingConversionAllowLossy];
}

- (void)writeToBinaryFile:(NSString *)path atomically:(BOOL)atomically {
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    if (error)
        [NSException raise:NSInternalInconsistencyException format:@"%@", error.localizedDescription];
    [data writeToFile:path atomically:atomically];
}

- (NSString *)hexadecimalString {
    const unsigned char *dataBuffer = (const unsigned char *)self.bytes;
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger      dataLength  = self.length;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return hexString;
}

/**
 *  @brief  NSData 转成UTF8 字符串
 *
 *  @return 转成UTF8 字符串
 */
- (NSString *)utf8String {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end

#pragma mark - FileFormat

@implementation NSData (FileFormat)

- (BOOL)isJPEG {
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    return a == 0xFF && b == 0xD8 && c == 0xFF && (d == 0xE0 || d == 0xE1 || d == 0xE8);
}

- (BOOL)isPNG {
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    return a == 0x89 && b == 0x50 && c == 0x4E && d == 0x47;
}

- (BOOL)isImage {
    return self.isJPEG || self.isPNG;
}

- (BOOL)isMPEG4 {
    uint8_t a, b, c, d;
    [self getBytes:&a range:NSMakeRange(4, 1)];
    [self getBytes:&b range:NSMakeRange(5, 1)];
    [self getBytes:&c range:NSMakeRange(6, 1)];
    [self getBytes:&d range:NSMakeRange(7, 1)];
    
    return a == 0x66 && b == 0x74 && c == 0x79 && d == 0x70;
}

- (BOOL)isMedia {
    return self.isImage || self.isMPEG4;
}

- (BOOL)isCompressed {
    uint8_t a, b, c, d;
    [self getHeader:&a b:&b c:&c d:&d];
    
    // PK header
    return a == 0x50 && b == 0x4B && c == 0x03 && d == 0x04;
}

- (void)getHeader:(void *)a b:(void *)b c:(void *)c d:(void *)d {
    [self getBytes:a length:1];
    [self getBytes:b range:NSMakeRange(1, 1)];
    [self getBytes:c range:NSMakeRange(2, 1)];
    [self getBytes:d range:NSMakeRange(3, 1)];
}

- (NSString *)appropriateFileExtension {
    if (self.isJPEG) return @".jpg";
    if (self.isPNG) return @".png";
    if (self.isMPEG4) return @".mp4";
    if (self.isCompressed) return @".zip";
    return @".dat";
}

@end
