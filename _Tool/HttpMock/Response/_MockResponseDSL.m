#import "_MockResponseDSL.h"
#import "_MockResponse.h"
#import "_MockStringUtil.h"

@implementation _MockResponseDSL

- (id)initWithResponse:(_MockResponse *)response {
    self = [super init];
    if (self) {
        _response = response;
    }
    return self;
}

- (ResponseWithHeaderMethod)withHeader {
    return ^(NSString * header, NSString * value) {
        [self.response setHeader:header value:value];
        return self;
    };
}

- (ResponseWithHeadersMethod)withHeaders; {
    return ^(NSDictionary *headers) {
        for (NSString *header in headers) {
            NSString *value = [headers objectForKey:header];
            [self.response setHeader:header value:value];
        }
        return self;
    };
}

- (ResponseWithBodyMethod)withBody {
    return ^(NSString *body) {
        NSString *bodyString = body;
        
        if ([body hasSuffix:@".json"]) {
            NSString *name = [body substringToIndex:body.length-5];
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString *path = [bundle pathForResource:name ofType:@"json"];
            NSAssert(path.length, @"file:%@ not exist",body);
            bodyString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        }
        
        self.response.body = [bodyString data];
        
        //校验
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:self.response.body options:NSJSONReadingMutableContainers error:&error];
        if (!json) {
            NSAssert(json, @"response string is invaild json");
        }
        return self;
    };
}

- (ResponseWithDelayMethod)withDelay {
    return ^(NSTimeInterval delayInterval) {
        
        self.response.delayInterval = delayInterval;
        
        return self;
    };
}

@end
