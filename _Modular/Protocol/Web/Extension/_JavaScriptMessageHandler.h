#import <Foundation/Foundation.h>
#import "_JavaScriptMessage.h"

@protocol _BrowserProtocol;

@protocol _JavaScriptMessageHandler <NSObject>

@property (nonatomic, strong) id<_JavaScriptMessage> message;

+ (instancetype)withRaw:(NSDictionary *)data browser:(id<_BrowserProtocol>)browser;

- (BOOL)invokeSuccess;
- (BOOL)invokeFailure;

- (BOOL)invoke:(NSString *)handlerCode;

@end
