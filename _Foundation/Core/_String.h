#import <Foundation/Foundation.h>

// GBK
// CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

// Unicode
// NSUnicodeStringEncoding

// UTF8
// NSUTF8StringEncoding

//encoding
#define GBSTR_FROM_DATA(data) [[NSString alloc] initWithData: (data) encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif)]
#define UTF82GBK(str) [[NSString alloc] initWithData:[str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(NSUTF8StringEncoding)] encoding: kCFStringEncodingGB_18030_2000]
#define GBK2UTF8(str) [[NSString alloc] initWithData:[str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)] encoding: NSUTF8StringEncoding]

@interface NSString (StringEncoding)

- (NSString *)UTF82GBK;

- (NSString *)GBK2UTF8;

@end


@interface _String : NSObject



@end
