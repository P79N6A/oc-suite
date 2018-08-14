//
//  ALSBrowserProtocol.h
//  NewStructure
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_Protocol.h"
#import "_BrowserConfigureProtocol.h"
#import "_BrowserPage.h"
#import "_BrowserService.h"

#import "_JavaScriptHandlerProtocol.h"
#import "_JavaScriptMessageHandler.h"
#import "_JavaScriptMessage.h"
#import "_JavaScriptMediatorProtocol.h"

@protocol _BrowserProtocol <_Protocol>

// 配置
@property (nonatomic, strong) id<_BrowserConfigureProtocol> config;

// 扩展服务
- (void)addExtension:(id<_BrowserService>)e;
- (void)removeExtension:(id<_BrowserService>)e;
- (void)eachExtension:(void (^)(id<_BrowserService> e))handler;

// JavaScript 消息执行者
- (void)addPerformer:(id<_JavaScriptMessagePerformer>)p;
- (void)removePerformer:(id<_JavaScriptMessagePerformer>)p;
- (void)eachPerformer:(BOOL (^)(id<_JavaScriptMessagePerformer>))handler;

////////////// 以下 可能全部废弃

// MARK: - 缓存

//- (void)addCookie:(NSHTTPCookie *)cookie;

@optional

// MARK: - JS 通信
@property (nonatomic, strong) id<_JavaScriptMediatorProtocol> mediator;
@property (nonatomic, weak) id tempBrowser; // 暂时策略

- (id<_JavaScriptMessageHandler>)callbackWith:(id)data;

- (void)evaluateJavaScript:(NSString *)code completion:(void (^)(id completion, NSError *error))completionHandler;

@end
