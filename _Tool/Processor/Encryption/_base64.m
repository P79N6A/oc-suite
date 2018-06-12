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

#import "_base64.h"
#pragma GCC diagnostic ignored "-Wselector"
#import <Availability.h>


// ----------------------------------
// Category source code
// ----------------------------------

@implementation NSData ( Base64 )

#define CHAR64(c) (index_64[(unsigned char)(c)])

#define BASE64_GETC (length > 0 ? (length--, bytes++, (unsigned int)(bytes[-1])) : (unsigned int)EOF)
#define BASE64_PUTC(c) [buffer appendBytes: &c length: 1]

static char basis_64[] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static inline void output64Chunk( int c1, int c2, int c3, int pads, NSMutableData * buffer ) {
    char pad = '=';
    BASE64_PUTC(basis_64[c1 >> 2]);
    BASE64_PUTC(basis_64[((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4)]);
    
    switch ( pads ) {
        case 2:
            BASE64_PUTC(pad);
            BASE64_PUTC(pad);
            break;
            
        case 1:
            BASE64_PUTC(basis_64[((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6)]);
            BASE64_PUTC(pad);
            break;
            
        default:
        case 0:
            BASE64_PUTC(basis_64[((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6)]);
            BASE64_PUTC(basis_64[c3 & 0x3F]);
            break;
    }
}

- (NSData *)Base64 {
    NSMutableData * buffer = [NSMutableData data];
    const unsigned char * bytes;
    NSUInteger length;
    unsigned int c1, c2, c3;
    
    bytes = [self bytes];
    length = [self length];
    
    while ( (c1 = BASE64_GETC) != (unsigned int)EOF ) {
        c2 = BASE64_GETC;
        if ( c2 == (unsigned int)EOF ) {
            output64Chunk( c1, 0, 0, 2, buffer );
        } else {
            c3 = BASE64_GETC;
            if ( c3 == (unsigned int)EOF )
                output64Chunk( c1, c2, 0, 1, buffer );
            else
                output64Chunk( c1, c2, c3, 0, buffer );
        }
    }
    
    return buffer;
}

- (NSString *)Base64String {
    return [[NSString alloc] initWithData:[self Base64] encoding:NSASCIIStringEncoding];
}

+ (NSData *)dataWithBase64EncodedString:(NSString *)string {
    if (![string length]) return nil;
    NSData *decoded = nil;
#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9 || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if (![NSData instancesRespondToSelector:@selector(initWithBase64EncodedString:options:)])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        decoded = [[self alloc] initWithBase64Encoding:[string stringByReplacingOccurrencesOfString:@"[^A-Za-z0-9+/=]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [string length])]];
#pragma clang diagnostic pop
    }
    else
#endif
    {
        decoded = [[self alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    return [decoded length]? decoded: nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth {
    if (![self length]) return nil;
    NSString *encoded = nil;
#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9 || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if (![NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        encoded = [self base64Encoding];
#pragma clang diagnostic pop
        
    }
    else
#endif
    {
        switch (wrapWidth) {
            case 64: {
                return [self base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            }
            case 76: {
                return [self base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
            }
            default:
            {
                encoded = [self base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
            }
        }
    }
    
    if (!wrapWidth || wrapWidth >= [encoded length]) {
        return encoded;
    }
    
    wrapWidth = (wrapWidth / 4) * 4;
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < [encoded length]; i+= wrapWidth) {
        if (i + wrapWidth >= [encoded length]) {
            [result appendString:[encoded substringFromIndex:i]];
            break;
        }
        
        [result appendString:[encoded substringWithRange:NSMakeRange(i, wrapWidth)]];
        [result appendString:@"\r\n"];
    }
    
    return result;
}

- (NSString *)base64EncodedString {
    return [self base64EncodedStringWithWrapWidth:0];
}

@end

@implementation NSString (Base64)

+ (NSString *)stringWithBase64EncodedString:(NSString *)string {
    NSData *data = [NSData dataWithBase64EncodedString:string];
    if (data) {
        return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSString *)base64EncodedString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedString];
}

- (NSString *)base64DecodedString {
    return [NSString stringWithBase64EncodedString:self];
}

- (NSData *)base64DecodedData {
    return [NSData dataWithBase64EncodedString:self];
}

@end

// ----------------------------------
// Source code
// ----------------------------------

@implementation _base64

@end
