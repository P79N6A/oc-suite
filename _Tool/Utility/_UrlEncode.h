//
//  NSString_1.h
//  iphone51buy
//
//  Created by Bai Haoquan on 12-9-11.
//  modify by qitao (add URLDecodedString, queryParameters)
//  Copyright (c) 2012年 icson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UrlEncode)

- (NSString *) urlencode;

- (NSString*)URLDecodedString;
- (NSDictionary*)queryParameters;

@end

/*
 URL 字符串 里面可能包含某些字符，比如‘$‘ ‘&’ ‘？’...等，这些字符在 URL 语法中是具有特殊语法含义的，
 
 比如 URL ：http://www.baidu.com/s?wd=%BD%AA%C3%C8%D1%BF&rsv_bp=0&rsv_spt=3&inputT=3512
 
 中 的 & 起到分割作用 等等，如果 你提供的URL 本身就含有 这些字符，就需要把这些字符 转化为 “%+ASCII” 形式，以免造成冲突
 */
@interface NSString (UrlEscape)

- (NSString*)urlEscape;
- (NSString *)urlUnescape;

@end
