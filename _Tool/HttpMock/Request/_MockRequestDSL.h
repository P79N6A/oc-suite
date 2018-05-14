#import <Foundation/Foundation.h>
#import "_HttpMockDef.h"

@class _MockRequestDSL;
@class _MockResponseDSL;
@class _MockRequest;

@protocol _HTTPBody;

typedef _MockRequestDSL *(^WithHeadersMethod)(NSDictionary *);
typedef _MockRequestDSL *(^isUpdatePartResponseBody)(BOOL);
typedef _MockRequestDSL *(^WithBodyMethod)(id);
typedef _MockRequestDSL *(^WithSerializationTypeMethod)(HttpSerializationType);

typedef _MockResponseDSL *(^AtReturnMethod)(NSInteger);
typedef void (^AtFailWithErrorMethod)(NSError *error);

@interface _MockRequestDSL : NSObject

- (id)initWithRequest:(_MockRequest *)request;

@property (nonatomic, strong) _MockRequest *request;

@property (nonatomic, strong, readonly) WithHeadersMethod withHeaders;
@property (nonatomic, strong, readonly) isUpdatePartResponseBody isUpdatePartResponseBody;
@property (nonatomic, strong, readonly) WithBodyMethod withBody;
@property (nonatomic, strong, readonly) WithSerializationTypeMethod withSerializationType;

@property (nonatomic, strong, readonly) AtReturnMethod atReturn;
@property (nonatomic, strong, readonly) AtFailWithErrorMethod atFailWithError;

@end

#ifdef __cplusplus
extern "C" {
#endif
    
    _MockRequestDSL * mockRequest(NSString *method, id url);
    
#ifdef __cplusplus
}
#endif
