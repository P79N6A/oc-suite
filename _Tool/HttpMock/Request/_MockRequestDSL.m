#import "_MockRequestDSL.h"
#import "_MockRequest.h"
#import "_MockResponse.h"
#import "_Matcher.h"
#import "_MockResponseDSL.h"
#import "_HttpMock.h"

@implementation _MockRequestDSL

- (id)initWithRequest:(_MockRequest *)request {
    self = [super init];
    if (self) {
        _request = request;
    }
    return self;
}
- (WithHeadersMethod)withHeaders {
    return ^(NSDictionary *headers) {
        for (NSString *header in headers) {
            NSString *value = [headers objectForKey:header];
            [self.request setHeader:header value:value];
        }
        return self;
    };
}

- (isUpdatePartResponseBody)isUpdatePartResponseBody {
    return ^(BOOL isUpdate) {
        self.request.isUpdatePartResponseBody = isUpdate;
        return self;
    };
}

- (WithBodyMethod)withBody {
    return ^(id body) {
        self.request.body = [_Matcher matcherWithObject:body];
        
        return self;
    };
}

- (WithSerializationTypeMethod)withSerializationType {
    return ^(HttpSerializationType type) {
        self.request.serializationType = type;
        
        return self;
    };
}

- (AtReturnMethod)atReturn {
    return ^(NSInteger statusCode) {
        self.request.response = [[_MockResponse alloc] initWithStatusCode:statusCode];
        _MockResponseDSL *responseDSL = [[_MockResponseDSL alloc] initWithResponse:self.request.response];
        return responseDSL;
    };
}


- (AtFailWithErrorMethod)atFailWithError {
    return ^(NSError *error) {
        self.request.response = [[_MockResponse alloc] initWithError:error];
    };
}

@end

_MockRequestDSL *mockRequest(NSString *method, id url) {
    _MockRequest *request = [[_MockRequest alloc] initWithMethod:method urlMatcher:[_Matcher matcherWithObject:url]];
    _MockRequestDSL *dsl = [[_MockRequestDSL alloc] initWithRequest:request];
    [[_HttpMock sharedInstance] addMockRequest:request];
    [[_HttpMock sharedInstance] startMock];
    return dsl;
}
