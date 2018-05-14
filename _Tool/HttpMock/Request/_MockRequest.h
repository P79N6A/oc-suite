#import <Foundation/Foundation.h>
#import "_HttpMockDef.h"

@class _MockResponse;
@class _Matcher;

@protocol _HTTPRequest <NSObject> // 设计为 等同于 NSURLRequest

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSString *method;
@property (nonatomic, strong, readonly) NSDictionary *headers;
@property (nonatomic, strong, readonly) NSData *body;

- (NSString *)description;

@end

@interface _MockRequest : NSObject

@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) _Matcher *urlMatcher;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong, readwrite) _Matcher *body;
@property (nonatomic, assign, readwrite) BOOL isUpdatePartResponseBody;
@property (nonatomic, assign, readwrite) HttpSerializationType serializationType;

@property (nonatomic, strong) _MockResponse *response;

- (instancetype)initWithMethod:(NSString *)method url:(NSString *)url;
- (instancetype)initWithMethod:(NSString *)method urlMatcher:(_Matcher *)urlMatcher;

- (void)setHeader:(NSString *)header value:(NSString *)value;

- (BOOL)matchesRequest:(id<_HTTPRequest>)request;

@end
