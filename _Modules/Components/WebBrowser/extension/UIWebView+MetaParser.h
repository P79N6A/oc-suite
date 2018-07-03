//
//  UIWebView+MetaParser.h
//  UIWebView+MetaParser
//
//  Created by Hirose Tatsuya on 2013/09/15.
//  Copyright (c) 2013年 Tatyusa. All rights reserved.
//
//  https://github.com/tatyusa/UIWebView-MetaParser

#import <UIKit/UIKit.h>

@interface UIWebView (JKMetaParser)
/**
 *  @brief  获取网页meta信息
 *
 *  @return meta信息
 */
- (NSArray *)getMetaData;

@end
