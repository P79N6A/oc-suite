#import <Foundation/Foundation.h>
#import "_HttpMockDef.h"

@interface _MockResponse : NSObject

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSData *body;
@property (nonatomic, strong) NSMutableDictionary *headers;

@property (nonatomic, assign) BOOL shouldFail;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign) BOOL isUpdatePartResponseBody;

@property (nonatomic, assign) BOOL shouldNotMockAgain;

/**
 @brief 延迟响应，方便测试接口的取消
 */
@property (nonatomic, assign) NSTimeInterval delayInterval;

- (id)initWithError:(NSError *)error;
- (id)initWithStatusCode:(NSInteger)statusCode;
- (id)initDefaultResponse;
- (void)setHeader:(NSString *)header value:(NSString *)value;

@end
