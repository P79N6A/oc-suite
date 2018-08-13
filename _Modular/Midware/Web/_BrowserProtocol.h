//
//  ALSBrowserProtocol.h
//  NewStructure
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSProtocol.h"
#import "ALSBrowserConfigureProtocol.h"
#import "ALSBrowserPage.h"
#import "ALSBrowserService.h"

#import "ALSJavaScriptHandlerProtocol.h"
#import "ALSJavaScriptMessageHandler.h"
#import "ALSJavaScriptMessage.h"
#import "ALSJavaScriptMediatorProtocol.h"

@protocol ALSBrowserProtocol <ALSProtocol>

// 配置
@property (nonatomic, strong) id<ALSBrowserConfigureProtocol> config;

// 扩展服务
- (void)addExtension:(id<ALSBrowserService>)e;
- (void)removeExtension:(id<ALSBrowserService>)e;
- (void)eachExtension:(void (^)(id<ALSBrowserService> e))handler;

// JavaScript 消息执行者
- (void)addPerformer:(id<ALSJavaScriptMessagePerformer>)p;
- (void)removePerformer:(id<ALSJavaScriptMessagePerformer>)p;
- (void)eachPerformer:(BOOL (^)(id<ALSJavaScriptMessagePerformer>))handler;

////////////// 以下 可能全部废弃

// MARK: - 缓存

//- (void)addCookie:(NSHTTPCookie *)cookie;

@optional

// MARK: - JS 通信
@property (nonatomic, strong) id<ALSJavaScriptMediatorProtocol> mediator; 
@property (nonatomic, weak) id tempBrowser; // 暂时策略

- (id<ALSJavaScriptMessageHandler>)callbackWith:(id)data;

- (void)evaluateJavaScript:(NSString *)code completion:(void (^)(id completion, NSError *error))completionHandler;

@end
