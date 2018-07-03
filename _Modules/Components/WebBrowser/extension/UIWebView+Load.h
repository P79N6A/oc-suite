//
//  UIWebView+loadURL.h
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 14/12/15.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView ( Load )

/**
 *  @brief  读取一个网页地址
 *
 *  @param URLString 网页地址
 */
- (void)loadURL:(NSString *)URLString;

/**
 *  @brief  读取bundle中的webview
 *
 *  @param htmlName 文件名称 xxx.html
 */
- (void)loadLocalHtml:(NSString *)htmlName;

/**
 *
 *  读取bundle中的webview
 *
 *  @param htmlName htmlName 文件名称 xxx.html
 *  @param inBundle bundle
 */
- (void)loadLocalHtml:(NSString *)htmlName inBundle:(NSBundle*)inBundle;

/**
 *  @brief  加载部分html内容，同时让图片适应屏幕宽高
 *
 
    self.superview.clipsToBounds = YES; // 超出部分不予显示
 
 *  inspired by http://www.jianshu.com/p/5aa7383fe39f
 */
- (void)loadHTMLStringPartially:(NSString *)htmls;
- (void)sizeToFitByHtmlContentWithWidth:(CGFloat)constraintWidth; // 两者配合使用

/**
 *  @brief  清空cookie
 */
- (void)clearCookies;

@end
