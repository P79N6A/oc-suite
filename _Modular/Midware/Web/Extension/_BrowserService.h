//
//  ALSBrowserService.h
//  wesg
//
//  Created by 7 on 30/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "ALSProtocol.h"
#import "ALSJavaScriptMediatorProtocol.h"
#import "ALSJavaScriptMessagePerformer.h"

@protocol ALSBrowserService <ALSProtocol, ALSJavaScriptMessagePerformer>

// 视图容器: Browser <-> BrowserPage -> Container -> BrowserService sub view

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *webView;

- (void)pageDidLoad:(UIView *)view web:(UIView *)webView; // 网页加载完成

- (void)pageDidUnload:(UIView *)view; // 网页加载完成

// 桥接: 与 Browser <-> BrowserPage 通信

@property (nonatomic, weak) id<ALSJavaScriptMediatorProtocol> mediator;

// 功能: 比如 畅言评论、支付服务、分享服务 ... 这里不枚举

// 第三方依赖 ... 这里不提

@end
