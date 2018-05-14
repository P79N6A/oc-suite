#import <Foundation/Foundation.h>

#import "_Foundation.h"
#import "_HttpMockDef.h"
#import "_MockRequest.h"
#import "_HttpClientHook.h"
#import "_MockResponse.h"

#import "_MockRequestDSL.h"
#import "_MockResponseDSL.h"
#import "_MockStringUtil.h"

#import "_TransformUtil.h"

// -------------------------------------------
// Interface
// -------------------------------------------

@interface _HttpMock : NSObject

@property (nonatomic, strong) NSMutableArray *stubbedRequests;
@property (nonatomic, strong) NSMutableArray *hooks;
@property (nonatomic, assign, getter = isStarted) BOOL started;
/**
 自定义log日志输出方法
 */
@property (nonatomic, copy) void (^logBlock)(NSString *logStr);

@singleton(_HttpMock)

- (void)startMock;
- (void)stopMock;

- (_MockResponse *)responseForRequest:(id<_HTTPRequest>)request;
- (void)addMockRequest:(_MockRequest *)request;

- (void)log:(NSString *)fmt, ...;

@end
