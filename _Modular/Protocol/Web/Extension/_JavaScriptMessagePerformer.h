#import <Foundation/Foundation.h>
#import "_JavaScriptMessageHandler.h"

@protocol _JavaScriptMessagePerformer <NSObject>

/**
 *  @return YES: 继续传递; NO: 停止传递.
 */
- (BOOL)handleMessage:(id<_JavaScriptMessageHandler>)handler;

@end
