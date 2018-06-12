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

#import "_validator.h"
#import "_foundation.h"
#import "_serializer.h"

#pragma mark -

@implementation NSObject ( Validation )

- (BOOL)validate {
    return [[_Validator sharedInstance] validateObject:self];
}

- (BOOL)validate:(NSString *)prop {
    return [[_Validator sharedInstance] validateObject:self property:prop];
}

@end

#pragma mark -

@implementation NSString ( Validation )

- (BOOL)isNumber {
    NSString *		regex = @"-?[0-9.]+";
    NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}

- (BOOL)isNumberWithUnit:(NSString *)unit {
    NSString *		regex = [NSString stringWithFormat:@"-?[0-9.]+%@", unit];
    NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}

- (BOOL)isEmail {
    NSString *		regex = @"[A-Z0-9a-z._\%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:[self lowercaseString]];
}

- (BOOL)isUrl {
    return ([self hasPrefix:@"http://"] || [self hasPrefix:@"https://"]) ? YES : NO;
}

- (BOOL)isIPAddress {
    NSArray *			components = [self componentsSeparatedByString:@"."];
    NSCharacterSet *	invalidCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
    
    if ( [components count] == 4 ) {
        NSString *part1 = [components objectAtIndex:0];
        NSString *part2 = [components objectAtIndex:1];
        NSString *part3 = [components objectAtIndex:2];
        NSString *part4 = [components objectAtIndex:3];
        
        if ( 0 == [part1 length] ||
            0 == [part2 length] ||
            0 == [part3 length] ||
            0 == [part4 length] ) {
            return NO;
        }
        
        if ( [part1 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part2 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part3 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part4 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound ) {
            if ( [part1 intValue] <= 255 &&
                [part2 intValue] <= 255 &&
                [part3 intValue] <= 255 &&
                [part4 intValue] <= 255 ) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)isPureInt {
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isPureFloat {
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

- (BOOL)isMobileNumber {
    //手机号以13， 15，18,17开头，八个 \d 数字字符
    NSString *regEx = @"^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$";
    NSPredicate* checkMobilePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regEx];
    
    return [checkMobilePredicate evaluateWithObject:self] && (self.length >= 11);
}

- (BOOL)isContainsEmoji {
    __block BOOL isEomji = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEomji = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
     }];
    
    return isEomji;
}

- (BOOL)containsChinese {
    NSUInteger length = [self length];
    for (NSUInteger i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsBlank {
    NSRange range = [self rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end

#pragma mark -

@implementation _Validator

@def_singleton( _Validator )

@def_prop_strong( NSString *,	lastProperty );
@def_prop_strong( NSString *,	lastError );

static __strong NSMutableDictionary * __rules = nil;

+ (void)classAutoLoad {
    [[_Validator sharedInstance] loadRules];
}

- (void)loadRules {
    if ( nil == __rules ) {
        __rules = [[NSMutableDictionary alloc] init];
        
        [__rules setObject:@(ValidatorRule_Regex)		forKey:@"regex"];
        [__rules setObject:@(ValidatorRule_Accepted)	forKey:@"accepted"];
        [__rules setObject:@(ValidatorRule_Alpha)		forKey:@"alpha"];
        [__rules setObject:@(ValidatorRule_Numeric)		forKey:@"numeric"];
        [__rules setObject:@(ValidatorRule_AlphaNum)	forKey:@"alpha_num"];
        [__rules setObject:@(ValidatorRule_AlphaDash)	forKey:@"alpha_dash"];
        [__rules setObject:@(ValidatorRule_URL)			forKey:@"url"];
        [__rules setObject:@(ValidatorRule_Email)		forKey:@"email"];
        [__rules setObject:@(ValidatorRule_Tel)			forKey:@"tel"];
        [__rules setObject:@(ValidatorRule_Integer)		forKey:@"integer"];
        [__rules setObject:@(ValidatorRule_IP)			forKey:@"ip"];
        [__rules setObject:@(ValidatorRule_Before)		forKey:@"before"];
        [__rules setObject:@(ValidatorRule_After)		forKey:@"after"];
        [__rules setObject:@(ValidatorRule_Between)		forKey:@"between"];
        [__rules setObject:@(ValidatorRule_Same)		forKey:@"same"];
        [__rules setObject:@(ValidatorRule_Size)		forKey:@"size"];
        [__rules setObject:@(ValidatorRule_Date)		forKey:@"date"];
        [__rules setObject:@(ValidatorRule_DateFormat)	forKey:@"dateformat"];
        [__rules setObject:@(ValidatorRule_Different)	forKey:@"different"];
        [__rules setObject:@(ValidatorRule_Min)			forKey:@"min"];
        [__rules setObject:@(ValidatorRule_Max)			forKey:@"max"];
        [__rules setObject:@(ValidatorRule_Required)	forKey:@"required"];
    }
}

- (ValidatorRule)typeFromString:(NSString *)string {
    string = [[string trim] unwrap];
    
    NSNumber * ruleType = [__rules objectForKey:string];
    if ( ruleType ) {
        return (ValidatorRule)ruleType.integerValue;
    }
    
    return ValidatorRule_Unknown;
}

- (BOOL)validate:(NSObject *)value rule:(NSString *)rule {
    NSUInteger offset = 0;
    
    if ( NSNotFound != [rule rangeOfString:@":"].location ) {
        NSString * ruleName = [[rule substringFromIndex:0 untilString:@":" endOffset:&offset] trim];
        NSString * ruleValue = [[[rule substringFromIndex:offset] trim] unwrap];
        
        return [self validate:value ruleName:ruleName ruleValue:ruleValue];
    } else {
        return [self validate:value ruleName:rule ruleValue:nil];
    }
}

- (BOOL)validate:(NSObject *)value ruleName:(NSString *)ruleName ruleValue:(NSString *)ruleValue {
    ValidatorRule ruleType = [self typeFromString:ruleName];
    
    if ( ValidatorRule_Unknown == ruleType ) {
        return NO;
    }
    
    return [self validate:value ruleType:ruleType ruleValue:ruleValue];
}

- (BOOL)validate:(NSObject *)value ruleType:(ValidatorRule)ruleType ruleValue:(NSString *)ruleValue {
    switch ( ruleType ) {
        case ValidatorRule_Regex: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            BOOL matched = [textValue match:ruleValue];
            if ( NO == matched ) {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_Accepted: {
            BOOL accepted = [[value toNumber] boolValue];
            if ( NO == accepted ) {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_Alpha: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue match:@"^([a-zA-Z]+)$"] ) {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_Numeric: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue match:@"^([+\\-\\.0-9]+)$"] ) {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_AlphaNum: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue match:@"^([a-zA-Z0-9]+)$"] ) {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_AlphaDash: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue match:@"^([a-zA-Z_]+)$"] ) {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_URL: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue isUrl] )
            {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_Email:
        {
            NSString * textValue = [value toString];
            if ( nil == textValue )
            {
                return NO;
            }
            
            if ( NO == [textValue isEmail] )
            {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_Tel:
            {
                NSString * textValue = [value toString];
                if ( nil == textValue )
                {
                    return NO;
                }

                if ( NO == [textValue isMobileNumber] )
                {
                    return NO;
                }
            }
            break;
            
        case ValidatorRule_Image:
        {
            if ( NO == [value isKindOfClass:[UIImage class]] )
            {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_Integer:
        {
            EncodingType encoding = [_Encoding typeOfObject:value];
            
            if ( EncodingType_Number != encoding )
            {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_IP:
        {
            NSString * textValue = [value toString];
            if ( nil == textValue )
            {
                return NO;
            }
            
            if ( NO == [textValue isIPAddress] )
            {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_Before:
        {
            NSDate * dateValue = [value toDate];
            NSDate * dateValue2 = [ruleValue toDate];
            
            if ( nil == dateValue || nil == dateValue2 )
            {
                return NO;
            }
            
            if ( NSOrderedAscending != [dateValue compare:dateValue2] )
            {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_After:
        {
            NSDate * dateValue = [value toDate];
            NSDate * dateValue2 = [ruleValue toDate];
            
            if ( nil == dateValue || nil == dateValue2 )
            {
                return NO;
            }
            
            if ( NSOrderedDescending != [dateValue compare:dateValue2] )
            {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_Between:
        {
            NSNumber * numberValue = [value toNumber];
            if ( nil == numberValue )
            {
                return NO;
            }
            
            NSArray *	array = [ruleValue componentsSeparatedByString:@","];
            NSNumber *	value1 = [[[array safeObjectAtIndex:0] trim] toNumber];
            NSNumber *	value2 = [[[array safeObjectAtIndex:1] trim] toNumber];
            
            if ( nil == value1 || nil == value2 )
            {
                return NO;
            }
            
            if ( NSOrderedDescending != [numberValue compare:value1] )
            {
                return NO;
            }
            
            if ( NSOrderedAscending != [numberValue compare:value2] )
            {
                return NO;
            }
        }
            break;
            
        case ValidatorRule_Same:
        {
//            TODO( "same: xxx" );
        }
            break;
            
        case ValidatorRule_Size:
        {
            EncodingType encoding = [_Encoding typeOfObject:value];
            
            if ( EncodingType_Number == encoding )
            {
                NSNumber * numberValue = (NSNumber *)value;
                
                if ( NSOrderedSame != [numberValue compare:[[ruleValue trim] toNumber]] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_String == encoding )
            {
                NSString * stringValue = (NSString *)value;
                
                if ( [stringValue length] != (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_Data == encoding )
            {
                NSData * dataValue = (NSData *)value;
                
                if ( [dataValue length] != (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_Url == encoding )
            {
                NSString * stringValue = [value toString];
                
                if ( [stringValue length] != (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_Array == encoding )
            {
                NSArray * arrayValue = (NSArray *)value;
                
                if ( [arrayValue count] != (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_Dict == encoding )
            {
                NSDictionary * dictValue = (NSDictionary *)value;
                
                if ( [dictValue count] != (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
        }
            break;
            
        case ValidatorRule_Date:
        {
            EncodingType encoding = [_Encoding typeOfObject:value];
            
            if ( EncodingType_Date != encoding )
            {
                NSDate * date = [value toDate];
                if ( nil == date )
                {
                    return NO;
                }
            }
        }
            break;
            
        case ValidatorRule_DateFormat: {
//            TODO( "data_format: xxx" );
        }
            break;
            
        case ValidatorRule_Different: {
//            TODO( "different: xxx" );
        }
            break;
            
        case ValidatorRule_Min: {
            EncodingType encoding = [_Encoding typeOfObject:value];
            
            if ( EncodingType_Number == encoding ) {
                NSNumber * numberValue = (NSNumber *)value;
                
                if ( NSOrderedAscending == [numberValue compare:[[ruleValue trim] toNumber]] ) {
                    return NO;
                }
            } else if ( EncodingType_String == encoding ) {
                NSString * stringValue = (NSString *)value;
                
                if ( [stringValue length] < (NSUInteger)[ruleValue integerValue] ) {
                    return NO;
                }
            } else if ( EncodingType_Data == encoding ) {
                NSData * dataValue = (NSData *)value;
                
                if ( [dataValue length] < (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            } else if ( EncodingType_Url == encoding ) {
                NSString * stringValue = [value toString];
                
                if ( [stringValue length] < (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_Array == encoding )
            {
                NSArray * arrayValue = (NSArray *)value;
                
                if ( [arrayValue count] < (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_Dict == encoding )
            {
                NSDictionary * dictValue = (NSDictionary *)value;
                
                if ( [dictValue count] < (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
        }
            break;
            
        case ValidatorRule_Max:
        {
            EncodingType encoding = [_Encoding typeOfObject:value];
            
            if ( EncodingType_Number == encoding )
            {
                NSNumber * numberValue = (NSNumber *)value;
                
                if ( NSOrderedDescending == [numberValue compare:[[ruleValue trim] toNumber]] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_String == encoding )
            {
                NSString * stringValue = (NSString *)value;
                
                if ( [stringValue length] > (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_Data == encoding )
            {
                NSData * dataValue = (NSData *)value;
                
                if ( [dataValue length] > (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_Url == encoding )
            {
                NSString * stringValue = [value toString];
                
                if ( [stringValue length] > (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_Array == encoding )
            {
                NSArray * arrayValue = (NSArray *)value;
                
                if ( [arrayValue count] > (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
            else if ( EncodingType_Dict == encoding )
            {
                NSDictionary * dictValue = (NSDictionary *)value;
                
                if ( [dictValue count] > (NSUInteger)[ruleValue integerValue] )
                {
                    return NO;
                }
            }
        }
            break;
            
        case ValidatorRule_Required:
        {
            if ( nil == value )
            {
                return NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (BOOL)validateObject:(NSObject *)obj
{
    Class baseClass = [[obj class] baseClass];
    if ( nil == baseClass )
    {
        baseClass = [NSObject class];
    }
    
    for ( Class clazzType = [obj class]; clazzType != baseClass; )
    {
        unsigned int		propertyCount = 0;
        objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ )
        {
            const char *	name = property_getName(properties[i]);
            NSString *		propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            NSObject *		propertyValue = [obj valueForKey:propertyName];
            NSArray *		ruleValues = [obj extentionForProperty:propertyName arrayValueWithKey:@"Rule"];
            
            for ( NSString * ruleValue in ruleValues )
            {
                BOOL passes = [self validate:propertyValue rule:ruleValue];
                if ( NO == passes )
                {
                    self.lastProperty	= propertyName;
                    self.lastError		= @"Unknown";
                    
                    return NO;
                }
            }
        }
        
        free( properties );
        
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
    
    return YES;
}

- (BOOL)validateObject:(NSObject *)obj property:(NSString *)property
{
    if ( nil == property )
        return NO;
    
    NSString *		propertyName = property;
    NSObject *		propertyValue = [obj valueForKey:propertyName];
    NSArray *		ruleValues = [obj extentionForProperty:propertyName arrayValueWithKey:@"Rule"];
    
    for ( NSString * ruleValue in ruleValues )
    {
        BOOL passes = [self validate:propertyValue rule:ruleValue];
        if ( NO == passes )
        {
            self.lastProperty	= propertyName;
            self.lastError		= @"Unknown";
            
            return NO;
        }
    }
    
    return YES;
}

@end
