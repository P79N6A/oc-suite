//
//  _web_service.h
//  student
//
//  Created by fallen.ink on 08/10/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_foundation.h"
//  1. UIWebView当图文很多时候的加载性能问题 ？
//  [iOS](https://segmentfault.com/q/1010000002531365) 前端处理，可以先把所有图片设置成占位图，等webviewdidfinshload的时候，给webview发送一个通知（参照phonegap的gapready），网页端再去加载实际图片即可。这实际上是hybrid很关键的体验提升步骤。
//  [android](http://blog.csdn.net/jimtrency/article/details/52118268)

#import "UIColor+Web.h"
#import "UIWebView+Blocks.h"
#import "UIWebView+Canvas.h"
#import "UIWebView+JavaScript.h"
#import "UIWebView+Load.h"
#import "UIWebView+MetaParser.h"
#import "UIWebView+Style.h"
#import "UIWebVIew+SwipeGesture.h"
#import "UIWebView+WebStorage.h"


#undef  service_web
#define service_web     [_WebService sharedInstance]

@interface _WebService : NSObject

@singleton( _WebService )

- (void)clearCache;

@end
