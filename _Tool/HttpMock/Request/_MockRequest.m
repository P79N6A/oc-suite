#import "_MockRequest.h"
#import "_Matcher.h"
#import "_MockResponse.h"
#import "_MockStringUtil.h"
#import "_TransformUtil.h"

@implementation _MockRequest

- (instancetype)initWithMethod:(NSString *)method url:(NSString *)url {
    return [self initWithMethod:method urlMatcher:[[_Matcher alloc] initWithString:url]];
}

- (instancetype)initWithMethod:(NSString *)method urlMatcher:(_Matcher *)urlMatcher; {
    self = [super init];
    if (self) {
        self.method = method;
        self.urlMatcher = urlMatcher;
        self.headers = [NSMutableDictionary dictionary];
        self.serializationType = HttpSerializationTypeJson;
    }
    return self;
}

- (void)setHeader:(NSString *)header value:(NSString *)value {
    [self.headers setValue:value forKey:header];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"StubRequest:\nMethod: %@\nURL: %@\nHeaders: %@\nBody: %@\nResponse: %@",
            self.method,
            self.urlMatcher,
            self.headers,
            self.body,
            self.response];
}

- (_MockResponse *)response {
    if (!_response) {
        _response = [[_MockResponse alloc] initDefaultResponse];
    }
    return _response;
}

- (BOOL)matchesRequest:(id<_HTTPRequest>)request {
    if ([self matchesMethod:request]
        && [self matchesURL:request]
        && [self matchesHeaders:request]
        && [self matchesBody:request]
        ) {
        return YES;
    }
    return NO;
}

- (BOOL)matchesMethod:(id<_HTTPRequest>)request {
    if (!self.method || [self.method isEqualToString:request.method]) {
        return YES;
    }
    return NO;
}

- (BOOL)matchesURL:(id<_HTTPRequest>)request {
    /**
     * 先改成relativeString
     */
    _Matcher *matcher = [[_Matcher alloc] initWithString:[request.url absoluteString]];
    
    {
        // 如果是GET，则将其URL拼接完整
        if (self.body.matchType == _MatcherTypeString &&
            [self.method isEqualToString:@"GET"]) {
            // 尝试将 string 类型的 body 变成 dictionary
            NSString *json = self.body.string;
            NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            // 尝试进行拼接
            if (dict && dict.allKeys.count) {
                NSMutableArray *pairs = [NSMutableArray new];
                
                for (NSString *key in dict.allKeys) {
                    id value = [dict objectForKey:key];
                    
                    if ([value isKindOfClass:NSString.class]) {
                        [pairs addObject:[NSString stringWithFormat:@"%@=%@", [key URLEncoded], [(NSString *)value URLEncoded]]];
                    } else if ([value isKindOfClass:NSNumber.class]) {
                        [pairs addObject:[NSString stringWithFormat:@"%@=%@", [key URLEncoded], [[(NSNumber *)value stringValue] URLEncoded]]];
                    }
                }
                
                NSString *parametersString = [pairs componentsJoinedByString:@"&"];
                
                NSString *urlWithQueryedParameters = [NSString stringWithFormat:@"%@?%@", self.urlMatcher.string, parametersString];
                
                _Matcher *newMatcher = [_Matcher matcherWithObject:urlWithQueryedParameters];
                
                return [newMatcher match:matcher];
            }
        }
    }
    
    BOOL result = [self.urlMatcher match:matcher];
    return result;
}

- (BOOL)matchesHeaders:(id<_HTTPRequest>)request {
    // 如果没有指定request的头，则不做比较
    if (!self.headers ||
        !self.headers.allKeys.count) {
        return YES;
    }
    
    for (NSString *header in self.headers) {
        if (![[request.headers objectForKey:header] isEqualToString:[self.headers objectForKey:header]]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)matchesBody:(id<_HTTPRequest>)request {
    // Origin request body matcher
    NSData *reqBody = request.body;
    if (!reqBody) {
        return YES;
    }

    NSString *reqBodyString = [[NSString alloc] initWithData:reqBody encoding:NSUTF8StringEncoding];
    reqBodyString = [reqBodyString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSAssert(reqBodyString, @"request body is nil");
    
    // 默认为json字符串，如果是query的，则需要转化一下
    if (self.serializationType == HttpSerializationTypeQuery) {
        NSDictionary *dict =  __DictionaryFromQueryString(reqBodyString);
        
        reqBodyString = __JsonStringFromDictionary(dict, nil);
        
        reqBodyString = [reqBodyString stringByReplacingOccurrencesOfString:@" " withString:@""];
        reqBodyString = [reqBodyString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        reqBodyString = reqBodyString.URLEncoded;
    }
    
    _Matcher *matcher = [[_Matcher alloc] initWithString:reqBodyString];
    
    if (self.body.matchType == _MatcherTypeString) {
        // Mock request body matcher
        NSString *mockBodyString = self.body.string;
        mockBodyString = [mockBodyString stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        _Matcher *mockBodyMatcher = [[_Matcher alloc] initWithString:mockBodyString.URLEncoded];
        
        if (!self.body || [mockBodyMatcher match:matcher]) {
            return YES;
        }
    }
    
    if (!self.body || [self.body match:matcher]) {
        return YES;
    }
    
    return NO;
}

@end
