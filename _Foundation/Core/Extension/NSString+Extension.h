
#import "_Precompile.h"
#import <CoreLocation/CoreLocation.h>

#pragma mark -

@interface NSString ( Extension )

- (NSString *)unwrap;
- (NSString *)normalize;

- (NSString *)trim;
- (NSString *)trimBy:(NSString *)str;
- (NSString *)trimFloatPointNumber; // 去掉浮点数尾部的'0'和'.' 如：1.00 ==> 1, 0.00 ==> 0, 0.50 ==> 0.5
- (NSString *)trimmingWhitespace; // 去除空格
- (NSString *)trimmingWhitespaceAndNewlines; // 去除字符串与空行
+ (NSString *)trimmingWhitespaceAndChangLineWithChangN:(NSString*)str;
- (NSString *)trimmingLeadingWhitespace; // 去掉NSString前面的空格
- (NSString *)trimmingLeadingAndTrailingWhitespace; // 去掉NSString前面和后面的空格

- (NSString *)strippingHTML;
- (NSString *)removingScriptsAndStrippingHTML; // 清除js脚本

- (NSString *)repeat:(NSUInteger)count;

- (BOOL)match:(NSString *)expression;
- (BOOL)matchAnyOf:(NSArray *)array;
- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex;
- (NSArray *)allMatchesForRegex:(NSString *)regex;
- (NSString *)stringByReplacingMatchesForRegex:(NSString *)regex withString:(NSString *)replacement;
- (NSString *)stringByRegex:(NSString*)pattern substitution:(NSString*)substitute;

- (BOOL)contains:(NSString *)str;
- (BOOL)contains:(NSString *)str options:(NSStringCompareOptions)option;

- (BOOL)startsWith:(NSString *)prefix;
- (BOOL)endsWith:(NSString *)suffix;

/**  Return the char value at the specified index. */
- (unichar)charAt:(int)index;
- (int)indexOfChar:(unichar)ch;
- (int)indexOfChar:(unichar)ch fromIndex:(int)index;
- (int)indexOfString:(NSString *)str;
- (int)indexOfString:(NSString *)str fromIndex:(int)index;
- (int)lastIndexOfChar:(unichar)ch;
- (int)lastIndexOfChar:(unichar)ch fromIndex:(int)index;
- (int)lastIndexOfString:(NSString *)str;
- (int)lastIndexOfString:(NSString *)str fromIndex:(int)index;

- (NSString *)toLowerCase;
- (NSString *)toUpperCase;

- (NSString *)replaceAll:(NSString *)origin with:(NSString *)replacement;
- (NSArray *)split:(NSString *)separator;
+ (NSString *)reverseString:(NSString *)strSrc; // 反转字符串

- (BOOL)empty;
- (BOOL)notEmpty;

- (BOOL)is:(NSString *)other;
- (BOOL)isNot:(NSString *)other;
- (BOOL)equalsIgnoreCase:(NSString *)anotherString;

/**
 * Compares two strings lexicographically.
 * the value 0 if the argument string is equal to this string;
 * a value less than 0 if this string is lexicographically less than the string argument;
 * and a value greater than 0 if this string is lexicographically greater than the string argument.
 */
- (int)compareTo:(NSString *)anotherString;
- (int)compareToIgnoreCase:(NSString *)str;

- (BOOL)isValueOf:(NSArray *)array;
- (BOOL)isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens;

- (int)wordsCount; // 获取中文字符数量

- (NSString *)substringFromIndex:(NSUInteger)from untilString:(NSString *)string;
- (NSString *)substringFromIndex:(NSUInteger)from untilString:(NSString *)string endOffset:(NSUInteger *)endOffset;

- (NSString *)substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset;
- (NSString *)substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset endOffset:(NSUInteger *)endOffset;

- (NSString *)substringFromIndex:(int)beginIndex toIndex:(int)endIndex;

- (NSUInteger)countFromIndex:(NSUInteger)from inCharset:(NSCharacterSet *)charset;

- (NSArray *)pairSeparatedByString:(NSString *)separator;

- (NSArray<NSString *> *)rangeStringsOfSubString:(NSString *)subString;

@end

#pragma mark - Attributed 

@interface NSString (Attributed)

- (NSAttributedString *)attributedString;

- (NSAttributedString *)withColor:(UIColor *)color;

- (NSMutableAttributedString *)withSubString:(NSString *)subString color:(UIColor *)color;

- (NSString *)stringByDeletingCharacterAtIndex:(NSUInteger)idx;

@end

#pragma mark - JSDomOperate

@interface NSString (JSDomOperate)

+(NSString*)js_getCurrentClickImageIndexAndUrl;

@end

@interface NSString (Convertion)

+ (NSString *)distanceDescriptionWithMeters:(NSUInteger)meters;

+ (CLLocationCoordinate2D)coordinateFromString:(NSString *)string;

+ (NSString *)stringFromCoordinate:(CLLocationCoordinate2D)coordinate;

+ (NSString *)jsonFromObject:(id)obj;

- (NSDictionary *)parsetUrlString;

@end

