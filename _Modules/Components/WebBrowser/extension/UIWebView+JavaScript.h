//
//  UIWebView+JS.h
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 14/12/22.
//  Copyright (c) 2014年 duzixi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView ( JavaScript )

#pragma mark - 获取网页中的数据

- (int)nodeCountOfTag:(NSString *)tag; // 获取某个标签的结点个数
- (NSString *)getCurrentURL; // 获取当前页面URL
- (NSString *)getTitle; // 获取标题
- (NSArray *)getImages; // 获取图片
- (NSArray *)getOnClicks; // 获取当前页面所有链接

#pragma mark - 获取、改变网页样式和行为

- (void)loadHtmlWithTextFirst; // 优先 load 文字
- (CGFloat)getHtmlHeight;

- (void)setBackgroundColor:(UIColor *)color; // 改变背景颜色
- (void)addClickEventOnImg; // 为所有图片添加点击事件(网页中有些图片添加无效)

/**
 @usage
 
 - (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_webView setWebViewHtmlImageFit];
 
    CGRect frame = webView.frame;
    webView.frame = CGRectMake(frame.origin.x, UserInfoViewHeight, screen_width, webView.getHtmlHeight);
 
 
    // Update scrollView frame and others
    _scrollView.contentHeight = separator_height + UserInfoViewHeight + webView.frame.size.height + separator_height + UserAppraiseViewHeight;
 }
 
 @brief space用于处理图片两边空白，使之对称；图片宽高导致的不适配，推荐使用：loadHTMLStringPartially:方法
 */

- (void)setWebViewHtmlImageFit; // 让图片 根据实际的webview大小适配
- (void)setImgWidth:(int)size; // 改变所有图像的宽度
- (void)setImgHeight:(int)size; // 改变所有图像的高度
- (void)setFontColor:(UIColor *) color withTag:(NSString *)tagName; // 改变指定标签的字体颜色
- (void)setFontSize:(int) size withTag:(NSString *)tagName; // 改变指定标签的字体大小

#pragma mark - 删除

- (void)deleteNodeByElementID:(NSString *)elementID; //根据 ElementsID 删除WebView 中的节点
- (void)deleteNodeByElementClass:(NSString *)elementClass; // 根据 ElementsClass 删除 WebView 中的节点
- (void)deleteNodeByTagName:(NSString *)elementTagName; //根据  TagName 删除 WebView 的节点

@end
