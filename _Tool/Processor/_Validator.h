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

#import "_precompile.h"
#import "_foundation.h"
#import "_tool_box.h"

#pragma mark -

@interface NSObject ( Validation )

- (BOOL)validate;
- (BOOL)validate:(NSString *)prop;

@end

#pragma mark -

@interface NSString ( Validation )

- (BOOL)containsChinese; // 判断URL中是否包含中文
- (BOOL)containsBlank; // 是否包含空格
- (BOOL)isNumber;
- (BOOL)isNumberWithUnit:(NSString *)unit;
- (BOOL)isEmail;
- (BOOL)isUrl;
- (BOOL)isIPAddress;
- (BOOL)isPureInt;    // 判断是否为整形
- (BOOL)isPureFloat;  // 判断是否为浮点形
- (BOOL)isMobileNumber;
- (BOOL)isContainsEmoji; // 是否包含表情

@end

#pragma mark -

@interface _Validator : NSObject

@singleton( _Validator )

@prop_strong( NSString *,	lastProperty );
@prop_strong( NSString *,	lastError );

- (ValidatorRule)typeFromString:(NSString *)string;

- (BOOL)validate:(NSObject *)value rule:(NSString *)rule;
- (BOOL)validate:(NSObject *)value ruleName:(NSString *)ruleName ruleValue:(NSString *)ruleValue;
- (BOOL)validate:(NSObject *)value ruleType:(ValidatorRule)ruleType ruleValue:(NSString *)ruleValue;

- (BOOL)validateObject:(NSObject *)obj;
- (BOOL)validateObject:(NSObject *)obj property:(NSString *)property;

@end
