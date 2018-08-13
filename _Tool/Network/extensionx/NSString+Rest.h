//
//  NSString+Rest.h
//  kata
//
//  Created by fallen.ink on 18/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Rest)

// 从URL中解析出参数字典
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding;

// 从JSON字符串解析出参数字典
- (NSDictionary *)JSONDictionary;

// URL转义
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

// 对参数列表生成URL编码后字符串
+ (NSString *)makeQueryStringFromArgs:(NSDictionary *)args;

@end
