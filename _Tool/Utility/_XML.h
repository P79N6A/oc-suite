#import <Foundation/Foundation.h>

// ----------------------------------
// Category code
// ----------------------------------

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
