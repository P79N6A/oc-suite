//
//  UIWebView+loadURL.m
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 14/12/15.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "UIWebView+Load.h"

@implementation UIWebView ( Load )

- (void)loadURL:(NSString*)URLString {
    NSString *encodedUrl = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes (NULL, (__bridge CFStringRef) URLString, NULL, NULL,kCFStringEncodingUTF8);
    NSURL *url = [NSURL URLWithString:encodedUrl];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self loadRequest:req];
}

- (void)loadLocalHtml:(NSString*)htmlName {
    [self loadLocalHtml:htmlName inBundle:[NSBundle mainBundle]];
}

- (void)loadLocalHtml:(NSString*)htmlName inBundle:(NSBundle*)inBundle {
    NSString *filePath = [inBundle pathForResource:htmlName ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self loadRequest:request];
}

- (void)loadHTMLStringPartially:(NSString *)htmls { // div: webview_content_wrapper
    NSUInteger margin = 4.f;
    NSString * htmlcontent = [NSString stringWithFormat:@"<div id=\"webview_content_wrapper\">%@</div>", htmls];
    NSString *html = [NSString stringWithFormat:@""
                    "<html> \n"
                        "<head> \n"
                            "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1,maximum-scale=1,user-scalable=no\">"
                            "<style type=\"text/css\"> \n"
                                "body {font-size:15px;margin:%ldpx;}\n"
                            "</style> \n"
                        "</head> \n"
                        "<body>"
                            "<script type='text/javascript'>"
                                "window.onload = function(){\n"
                                    "var $img = document.getElementsByTagName('img');\n"
                                    "for(var p in  $img){\n"
                                        "$img[p].style.width = '100%%';\n"
                                        "$img[p].style.height ='auto';\n"
                                    "}\n"
                                "}"
                            "</script>%@"
                        "</body>"
                    "</html>", margin, htmlcontent]; // 这里的webInfo就是原始的HTML字符串。
//    self.scalesPageToFit = YES;
    [self loadHTMLString:html baseURL:nil];
}

// [ios webview自适应高度及关闭回弹效果](http://blog.csdn.net/cxiao_11/article/details/50829482)
- (void)sizeToFitByHtmlContentWithWidth:(CGFloat)constraintWidth {
    NSString *clientHeights = [self stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"]; // 获取页面高度（像素）
    float clientheight = [clientHeights floatValue];
    self.frame = CGRectMake(0, self.frame.origin.y, constraintWidth, clientheight);
    
    CGSize size = [self sizeThatFits:self.frame.size]; // 获取WebView最佳尺寸（点）
    NSString *heights = [self stringByEvaluatingJavaScriptFromString: @"document.getElementById('webview_content_wrapper').offsetHeight + parseInt(window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin-top'))  + parseInt(window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin-bottom'))"]; // 获取内容实际高度（像素）
    float height = [heights floatValue];
    height = height * size.height / clientheight; // 内容实际高度（像素）* 点和像素的比
    self.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, height); // 再次设置WebView高度（点）
}

- (void)clearCookies {
    NSHTTPCookieStorage *storage = NSHTTPCookieStorage.sharedHTTPCookieStorage;
    
    for (NSHTTPCookie *cookie in storage.cookies)
        [storage deleteCookie:cookie];
    
    [NSUserDefaults.standardUserDefaults synchronize];
}
@end
