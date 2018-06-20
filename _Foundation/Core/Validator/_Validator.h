#import "_Precompile.h"
#import "_Foundation.h"
#import "NSString+Validation.h"

// ----------------------------------
// MARK: _ValidatorRule
// ----------------------------------

typedef enum {
    _ValidatorRule_Unknown = 0,
    _ValidatorRule_Regex,           // 验证此规则的值必须符合给定的正则表达式
    _ValidatorRule_Accepted,        // 验证此规则的值必须是 yes、 on 或者是 1
    _ValidatorRule_Alpha,           // 验证此规则的值必须全部由字母字符构成
    _ValidatorRule_Numeric,         // 验证此规则的值必须是一个数字（数字）
    _ValidatorRule_AlphaNum,        // 验证此规则的值必须全部由字母和数字构成（字母|数字）
    _ValidatorRule_AlphaDash,       // 验证此规则的值必须全部由字母、数字、中划线或下划线字符构成（字母|数字|中划线|下划线）
    _ValidatorRule_URL,             // 验证此规则的值必须是一个URL
    _ValidatorRule_Email,           // 验证此规则的值必须是一个电子邮件地址
    _ValidatorRule_Tel,             // 验证此规则的值必须是一个电话
    _ValidatorRule_Image,           // 验证此规则的值必须是一个图片
    _ValidatorRule_Integer,         // 验证此规则的值必须是一个整数
    _ValidatorRule_IP,              // 验证此规则的值必须是一个IP地址
    _ValidatorRule_Date,            // 验证此规则的值必须是一个合法的日期
    _ValidatorRule_Required,        // 验证此规则的值必须在输入数据中存在
} _ValidatorRule;

// ----------------------------------
// MARK: -
// ----------------------------------

@interface NSString ( Validation )



@end

// ----------------------------------
// MARK: -
// ----------------------------------

@interface _Validator : NSObject

@singleton( _Validator )

@prop_strong( NSString *,	lastProperty );
@prop_strong( NSString *,	lastError );

- (_ValidatorRule)typeFromString:(NSString *)string;

- (BOOL)validate:(NSObject *)value rule:(NSString *)rule;
- (BOOL)validate:(NSObject *)value ruleName:(NSString *)ruleName ruleValue:(NSString *)ruleValue;
- (BOOL)validate:(NSObject *)value ruleType:(_ValidatorRule)ruleType ruleValue:(NSString *)ruleValue;

@end
