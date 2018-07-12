//
//  BaseWebViewController.h
//  Html5Demo
//
//  Created by 李杰 on 4/7/15.
//  Copyright (c) 2015 only.com. All rights reserved.
//

//#import "_building_precompile.h"
#import "WebViewJavascriptBridge.h"
#import "BaseViewController.h"

/**
 *  param:
 *      title : self.title
 *      1. 优先使用外部设置的
 *      2. 其次使用h5中的title
 *      3. 最后使用应用名字
 */
@interface BaseWebViewController : BaseViewController

@property (nonatomic) NSURL *url; // origin url
@property (nonatomic) UIWebView *webView; // embed webView
@property (nonatomic, strong) NSDictionary *params;


/**
 *  config
 */
@property (nonatomic) UIColor *progressViewColor;
@property (nonatomic) BOOL useCache; // default: NO

- (instancetype)initWithUrl:(NSURL *)url;
- (instancetype)initWithUrl:(NSURL *)url param:(NSDictionary *)param;

- (void)reloadWebView;

@end

#pragma mark - BaseViewController, WebView

@interface BaseViewController ( WebView )

/**
 *  open html link
 *
 *  @param url link
 */
- (void)pushHtml:(NSURL *)url;

- (void)pushHtml:(NSURL *)url extraParams:(NSDictionary *)params;

@end

