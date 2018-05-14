#import "_MockStringUtil.h"

@implementation NSString(mock)

- (NSRegularExpression *)regex {
    NSError *error = nil;
    NSRegularExpression *regex =  [[NSRegularExpression alloc] initWithPattern:self options:0 error:&error];
    if (error) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid regex pattern: %@\nError: %@", self, error];
    }
    return regex;
}

- (NSData *)data {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)URLEncoded {
    __autoreleasing NSString *encodedString = nil;
    
    NSString *originalString = self;
    
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    encodedString = [originalString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];

    return encodedString;
}

@end
