#import "_Validator.h"

#pragma mark -

@implementation NSString ( Validation )


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
        
        [__rules setObject:@(_ValidatorRule_Regex)		forKey:@"regex"];
        [__rules setObject:@(_ValidatorRule_Accepted)	forKey:@"accepted"];
        [__rules setObject:@(_ValidatorRule_Alpha)		forKey:@"alpha"];
        [__rules setObject:@(_ValidatorRule_Numeric)		forKey:@"numeric"];
        [__rules setObject:@(_ValidatorRule_AlphaNum)	forKey:@"alpha_num"];
        [__rules setObject:@(_ValidatorRule_AlphaDash)	forKey:@"alpha_dash"];
        [__rules setObject:@(_ValidatorRule_URL)			forKey:@"url"];
        [__rules setObject:@(_ValidatorRule_Email)		forKey:@"email"];
        [__rules setObject:@(_ValidatorRule_Tel)			forKey:@"tel"];
        [__rules setObject:@(_ValidatorRule_Integer)		forKey:@"integer"];
        [__rules setObject:@(_ValidatorRule_IP)			forKey:@"ip"];
        [__rules setObject:@(_ValidatorRule_Date)		forKey:@"date"];
        [__rules setObject:@(_ValidatorRule_Required)	forKey:@"required"];
    }
}

- (_ValidatorRule)typeFromString:(NSString *)string {
    string = [[string trim] unwrap];
    
    NSNumber * ruleType = [__rules objectForKey:string];
    if ( ruleType ) {
        return (_ValidatorRule)ruleType.integerValue;
    }
    
    return _ValidatorRule_Unknown;
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
    _ValidatorRule ruleType = [self typeFromString:ruleName];
    
    if ( _ValidatorRule_Unknown == ruleType ) {
        return NO;
    }
    
    return [self validate:value ruleType:ruleType ruleValue:ruleValue];
}

- (BOOL)validate:(NSObject *)value ruleType:(_ValidatorRule)ruleType ruleValue:(NSString *)ruleValue {
    switch ( ruleType ) {
        case _ValidatorRule_Regex: {
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
            
        case _ValidatorRule_Accepted: {
            BOOL accepted = [[value toNumber] boolValue];
            if ( NO == accepted ) {
                return NO;
            }
        }
            break;
            
        case _ValidatorRule_Alpha: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue match:@"^([a-zA-Z]+)$"] ) {
                return NO;
            }
        }
            break;
            
        case _ValidatorRule_Numeric: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue match:@"^([+\\-\\.0-9]+)$"] ) {
                return NO;
            }
        }
            break;
            
        case _ValidatorRule_AlphaNum: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue match:@"^([a-zA-Z0-9]+)$"] ) {
                return NO;
            }
        }
            break;
            
        case _ValidatorRule_AlphaDash: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue match:@"^([a-zA-Z_]+)$"] ) {
                return NO;
            }
        }
            break;
            
        case _ValidatorRule_URL: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue isURL] ) {
                return NO;
            }
        }
            break;
            
        case _ValidatorRule_Email: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue isEmailAddress] ) {
                return NO;
            }
        }
            break;
            
        case _ValidatorRule_Tel: {
                NSString * textValue = [value toString];
                if ( nil == textValue ) {
                    return NO;
                }

                if ( NO == [textValue isMobileNumber] ) {
                    return NO;
                }
            }
            break;
            
        case _ValidatorRule_Image: {
            if ( NO == [value isKindOfClass:[UIImage class]] ) {
                return NO;
            }
        }
            break;
            
        case _ValidatorRule_Integer: {
            EncodingType encoding = [_Encoding typeOfObject:value];
            
            if ( EncodingType_Number != encoding ) {
                return NO;
            }
        }
            break;
            
        case _ValidatorRule_IP: {
            NSString * textValue = [value toString];
            if ( nil == textValue ) {
                return NO;
            }
            
            if ( NO == [textValue isIPAddress] ) {
                return NO;
            }
        }
            break;
            
        case _ValidatorRule_Date: {
            EncodingType encoding = [_Encoding typeOfObject:value];
            
            if ( EncodingType_Date != encoding ) {
                NSDate * date = [value toDate];
                if ( nil == date ) {
                    return NO;
                }
            }
        }
            break;
            
        case _ValidatorRule_Required: {
            if ( nil == value ) {
                return NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

@end
