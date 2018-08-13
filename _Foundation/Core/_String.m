#import "_String.h"

@implementation NSString (StringEncoding)

- (NSString *)UTF82GBK {
    return [[NSString alloc] initWithData:[self dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(NSUTF8StringEncoding)] encoding: kCFStringEncodingGB_18030_2000];
}

- (NSString *)GBK2UTF8 {
    return [[NSString alloc] initWithData:[self dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)] encoding: NSUTF8StringEncoding];
}

@end

@implementation _String

//iOS中对字符串进行UTF-8编码：输出str字符串的UTF-8格式
//
//[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//
//
//解码：把str字符串以UTF-8规则进行解码
//
//[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

// http://www.cocoachina.com/bbs/read.php?tid=167144

@end
