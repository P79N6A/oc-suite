//
//  ALSJavaScriptMediatorProtocol.h
//  wesg
//
//  Created by 7 on 22/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSJavaScriptMessageHandler.h"

// JavaScript handler 's dispatcher & callback 【ALSJavaScriptMessageDispatcher】
//
// [IN/OUT] 信息载体 Command [OC] / Message (JS)
// [Message 的 执行者] Performer
// [Message 的 回调者] Handler
// []

@protocol ALSJavaScriptMessagePerformer;

@protocol ALSJavaScriptMediatorProtocol <NSObject>

// -

- (BOOL)dispatch:(id<ALSJavaScriptMessageHandler>)handler;

- (void)observeWith:(id<ALSJavaScriptMessagePerformer>)performer;

- (void)unobserveWith:(id<ALSJavaScriptMessagePerformer>)performer;

// -

- (BOOL)doCallBack:(NSString *)call;

@end
