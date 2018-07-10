#import <Foundation/Foundation.h>

// ----------------------------------
// Category code
// ----------------------------------

@interface NSDictionary (XML)

/**
 *  @brief  将NSDictionary转换成XML 字符串
 *
 *  @return XML 字符串
 */
- (NSString *)XMLString;

@end

@interface NSString ( XML )
/**
 *  @brief  xml字符串转换成NSDictionary
 *
 *  @return NSDictionary
 */
- (NSDictionary *)XMLDictionary;

@end

// ----------------------------------
// Class code
// ----------------------------------

@interface _Xml : NSObject

+ (NSDictionary *)dictionaryFromString:(NSString *)string;

@end
