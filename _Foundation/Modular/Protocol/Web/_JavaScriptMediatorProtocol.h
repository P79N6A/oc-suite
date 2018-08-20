#import <Foundation/Foundation.h>
#import "_JavaScriptMessageHandler.h"

// JavaScript handler 's dispatcher & callback 【ALSJavaScriptMessageDispatcher】
//
// [IN/OUT] 信息载体 Command [OC] / Message (JS)
// [Message 的 执行者] Performer
// [Message 的 回调者] Handler
// []

@protocol _JavaScriptMessagePerformer;

@protocol _JavaScriptMediatorProtocol <NSObject>

// -

- (BOOL)dispatch:(id<_JavaScriptMessageHandler>)handler;

- (void)observeWith:(id<_JavaScriptMessagePerformer>)performer;

- (void)unobserveWith:(id<_JavaScriptMessagePerformer>)performer;

// -

- (BOOL)doCallBack:(NSString *)call;

@end
