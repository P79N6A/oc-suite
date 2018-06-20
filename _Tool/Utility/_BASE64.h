#import <Foundation/Foundation.h>

// ----------------------------------
// Category code
// ----------------------------------

@interface NSData ( Base64 )

@property (nonatomic, readonly) NSData *    Base64;
@property (nonatomic, readonly) NSString *  Base64String;

/**
 *  @brief  字符串base64后转data
 *
 *  @param string 传入字符串
 *
 *  @return 传入字符串 base64后的data
 */
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
/**
 *  @brief  NSData转string
 *
 *  @param wrapWidth 换行长度  76  64
 *
 *  @return base64后的字符串
 */
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
/**
 *  @brief  NSData转string 换行长度默认64
 *
 *  @return base64后的字符串
 */
- (NSString *)base64EncodedString;

@end

@interface NSString ( Base64 )

+ (NSString *)stringWithBase64EncodedString:(NSString *)string;

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSData *)base64DecodedData;

@end


// ----------------------------------
// Class code
// ----------------------------------

@interface _base64 : NSObject

@end
