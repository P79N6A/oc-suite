#import "_NetHost.h"
#import "_NetRequest.h"
#import "_NetRestful.h"

@interface _NetRestful ()

@property (nonatomic, strong) _NetHost *host;

@end

@implementation _NetRestful

// MARK: -

- (instancetype)initWithHostname:(NSString *)hostname paramEncoding:(NetRequestParameterEncoding)encoding secure:(BOOL)isSecure {
    if (self = [super init]) {
        self.host = [[_NetHost alloc] initWithHostName:hostname];
        
        self.host.defaultHeaders = [self defaultHeader];
        self.host.defaultParameterEncoding = encoding;
        self.host.secureHost = isSecure;
    }
    
    return self;
}

// MARK: -

- (void)GET:(NSString *)path
      param:(NSDictionary *)param
    success:(void (^)(id data))successHandler
    failure:(void (^)(NSError *error))failureHandler {
    NSLog(@"host = %@, api = %@, parameter = %@", self.host.hostName, path, param);
    
    // 显示指示器
    [self showHud];
    
    // 是否有统一添加的参数
    NSMutableDictionary *mutableParameters = [@{} mutableCopy];
    NSDictionary *appendingParameters = [self appendParametersOnApi:path];
    
    if (appendingParameters) {
        [mutableParameters addEntriesFromDictionary:appendingParameters];
    }
    
    if (param) {
        [mutableParameters addEntriesFromDictionary:param];
    }
    
    _NetRequest *request = [self.host requestWithPath:path params:mutableParameters httpMethod:@"GET"];
    NSDictionary *addingHeader = [self constructHeaderWith:request api:path];
    if (addingHeader) [request addHeaders:addingHeader];
    [request addCompletionHandler:^(_NetRequest *completedRequest) {
        
        // 隐藏指示器
        [self dismissHud];
        
        if (completedRequest.error) { // http error
            if (failureHandler) failureHandler(completedRequest.error);
        } else {
            NSDictionary *response = completedRequest.responseAsJSON;
            
            NSLog(@"response = %@", response);
            
            NSError *error = [self checkResponseIfHaveError:response];
            if (error) { // service error
                if (failureHandler) failureHandler(error);
            } else {
                if (successHandler) successHandler([self filteredResponse:response]);
            }
        }
    }];
    
    [self.host startRequest:request];
}


- (void)POST:(NSString *)path
  parameters:(NSDictionary *)param
     headers:(NSDictionary *)headers
     success:(void (^)(id data))successHandler
     failure:(void (^)(NSError *error))failureHandler {
    
    // 是否有统一添加的参数
    
    NSMutableDictionary *mutableParameters = [@{} mutableCopy];
    NSDictionary *appendingParameters = [self appendParametersOnApi:path];
    
    if (appendingParameters) { // 统一追加
        [mutableParameters addEntriesFromDictionary:appendingParameters];
    }
    
    if (param) { // 当前接口参数
        [mutableParameters addEntriesFromDictionary:param];
    }
    
    NSLog(@"host = %@, api = %@, parameter = %@", self.host.hostName, path, mutableParameters);
    
    _NetRequest *request = [self.host requestWithPath:path params:mutableParameters httpMethod:@"POST"];
    if (headers.allKeys.count) {
        [request addHeaders:headers];
    }
    
    NSDictionary *addingHeader = [self constructHeaderWith:request api:path];
    if (addingHeader) [request addHeaders:addingHeader];
    
    [request addCompletionHandler:^(_NetRequest *completedRequest) {
        if (completedRequest.error) { // http error
            
            NSLog(@"api = %@, error = %@", path, completedRequest.error);
            
            if (failureHandler) failureHandler(completedRequest.error);
        } else {
            NSString *responseString = [completedRequest responseAsString];
            
            //            TODO("ugly")
            // map nullable to blank
//            {
//                if ([responseString contains:@"\"(null)\""]) {
//                    responseString = [responseString replaceAll:@"\"(null)\"" with:@"\"\""];
//                }
//                if ([responseString contains:@"(null)"]) { // 这应该是部分替换
//                    responseString = [responseString replaceAll:@"(null)" with:@""];
//                }
//                if ([responseString contains:@"\"null\""]) {
//                    responseString = [responseString replaceAll:@"\"null\"" with:@"\"\""];
//                }
//                if ([responseString contains:@"null"]) {
//                    responseString = [responseString replaceAll:@"null" with:@"\"\""];
//                }
//            }
            
            NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSError *error = [self checkResponseIfHaveError:response];
            if (error) { // service error
                if (failureHandler) failureHandler(error);
            } else {
                if (successHandler) successHandler([self filteredResponse:response]);
            }
        }
    }];
    
    [self.host startRequest:request];
}

// MARK: -

- (void)setHostname:(NSString *)hostname {
    
}

- (NSDictionary *)defaultHeader {
    return @{@"Accept":@"application/json", @"Content-Type":@"application/json;charset=utf-8"};
}

- (NSDictionary *)constructHeaderWith:(id)request api:(NSString *)api {
    if (self.headerAppendHandler) return self.headerAppendHandler(api);
    
    return nil;
}

- (NSDictionary *)appendParametersOnApi:(NSString *)api {
    return nil;
}


- (NSError *)checkResponseIfHaveError:(NSDictionary *)response {
//    NSDictionary *baseResponse = response[@"baseResponse"];
//    NSNumber *errorCode = baseResponse[@"error_code"];
//    NSString *errorMessage = baseResponse[@"error_message"];
//
//    if (errorCode.integerValue == 0) {
//        return nil;
//    } else {
//        return [NSError errorWithDomain:classnameof_Class(self.class) code:errorCode.integerValue userInfo:@{@"error_message":errorMessage}];
//    }
    
    return nil;
}

- (NSDictionary *)filteredResponse:(NSDictionary *)originResponse {
    return originResponse;
}

// MARK: -

- (void)showHud {
    
}

- (void)dismissHud {
    
}

@end
