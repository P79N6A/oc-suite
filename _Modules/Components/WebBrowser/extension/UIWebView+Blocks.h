//
//  UIWebView+Blocks.h
//
//  Created by Shai Mishali on 1/1/13.
//  Copyright (c) 2013 Shai Mishali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIWebView (JKBlock) <UIWebViewDelegate>

/**
 Set TRUE_END_REPORT to YES to get notified only when the page has *fully* loaded, and not when every single element loads. (still not fully tested). When this is set to NO, it will work exactly like the UIWebViewDelegate. (Default behavior)
 */
#define TRUE_END_REPORT NO

+ (UIWebView *)loadRequest: (NSURLRequest *) request
                    loaded: (void (^)(UIWebView *webView)) loadedBlock
                    failed: (void (^)(UIWebView *webView, NSError *error)) failureBlock;

+ (UIWebView *)loadRequest: (NSURLRequest *) request
                    loaded: (void (^)(UIWebView *webView)) loadedBlock
                    failed: (void (^)(UIWebView *webView, NSError *error)) failureBlock
               loadStarted: (void (^)(UIWebView *webView)) loadStartedBlock
                shouldLoad: (BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType)) shouldLoadBlock;

+ (UIWebView *)loadHTMLString:(NSString *)htmlString
                      loaded:(void (^)(UIWebView *webView))loadedBlock
                      failed:(void (^)(UIWebView *webView, NSError *error))failureBlock;

+ (UIWebView *)loadHTMLString:(NSString *)htmlString
                       loaded:(void (^)(UIWebView *))loadedBlock
                       failed:(void (^)(UIWebView *, NSError *))failureBlock
                  loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
                   shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock;
@end
