//
//  ALSBrowserPage.h
//  wesg
//
//  Created by 7 on 28/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol ALSBrowserPage <NSObject>

@property (nonatomic, readonly) UIView *view; // addSubView: 的时候使用
@property (nonatomic, readonly) UIView *webView; // UIWebView, WKWebView



@end
