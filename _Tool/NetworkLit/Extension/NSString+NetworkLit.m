#import "NSString+NetworkLit.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (NetworkLit)

+ (NSString *)netMD5StringFromData:(NSData *)data {
    const char *cStr = data.bytes;
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];      
}

- (NSString *)netURLEncodedString { // mk_ prefix prevents a clash with a private api
    // Old API
//    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                        (__bridge CFStringRef) self,
//                                                                        nil,
//                                                                        CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
//                                                                        kCFStringEncodingUTF8);
//
//    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) encodedCFString];
//
//    if(!encodedString)
//        encodedString = @"";
//
//    return encodedString;
    
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedString = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters]; // iOS 7.0
    
    return encodedString;
}

- (NSString *)netURLDecodedString {
    // Old API
//    CFStringRef decodedCFString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,                           (__bridge CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
//
//    // We need to replace "+" with " " because the CF method above doesn't do it
//    NSString *decodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) decodedCFString];
//    return (!decodedString) ? @"" : [decodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    
    NSString *decodedString = [self stringByRemovingPercentEncoding]; // iOS 7.0
    return (!decodedString) ? @"" : [decodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}

@end
