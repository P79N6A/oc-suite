#import "_NetHost.h"
#import "NSString+NetworkLit.h"

@interface _NetRequest ()

@property (readwrite) NSHTTPURLResponse *response;
@property (readwrite) NSData *responseData;
@property (readwrite) NSError *error;
@property (readwrite) NetRequestState state;
@property (readwrite) NSURLSessionTask *task;

- (void)setProgressValue:(CGFloat)updatedValue;

@end

@interface _NetHost () <NSURLSessionDelegate>

@property (readonly) NSURLSession *defaultSession;

@property dispatch_queue_t runningTasksSynchronizingQueue;
@property NSMutableArray *activeTasks;

@end

@implementation _NetHost

- (NSURLSession *)defaultSession {
    static dispatch_once_t onceToken;
    static NSURLSessionConfiguration *defaultSessionConfiguration;
    static NSURLSession *defaultSession;
    dispatch_once(&onceToken, ^{
        defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration
                                                      delegate:self
                                                 delegateQueue:[NSOperationQueue mainQueue]];
    });

    return defaultSession;
}

- (instancetype)init {
    if(self = [super init]) {

    self.runningTasksSynchronizingQueue = dispatch_queue_create("com.mknetworkkit.cachequeue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(self.runningTasksSynchronizingQueue, ^{
          self.activeTasks = [NSMutableArray array];
        });
    }

    return self;
}

- (instancetype)initWithHostName:(NSString *)hostName {
    _NetHost *engine = [[_NetHost alloc] init];
    engine.hostName = hostName;
    
    return engine;
}

// MARK: - 请求管理

- (void)startUploadRequest:(_NetRequest *)request {
  if(!request || !request.request) {
    NSAssert((request && request.request),
             @"Request is nil, check your URL and other parameters you use to build your request");
    return;
  }
  
  request.task = [self.defaultSession uploadTaskWithRequest:request.request
                                                      fromData:request.multipartFormData];
  dispatch_sync(self.runningTasksSynchronizingQueue, ^{
    [self.activeTasks addObject:request];
  });
  request.state = NetRequestStateStarted;
}

- (void)startDownloadRequest:(_NetRequest*) request {
    static dispatch_once_t onceToken;
    static BOOL methodImplemented = YES;
    dispatch_once(&onceToken, ^{
    methodImplemented = [[[UIApplication sharedApplication] delegate]
                         respondsToSelector:
                         @selector(application:handleEventsForBackgroundURLSession:completionHandler:)];
    });

    if(!methodImplemented) {

        NSLog(@"application:handleEventsForBackgroundURLSession:completionHandler: is not implemented in your application delegate. Download tasks might not work properly. Implement the method and set the completionHandler value to _NetHost backgroundSessionCompletionHandler");
    }

    if(!request || !request.request) {

        NSLog(@"Request is nil, check your URL and other parameters you use to build your request");
        return;
    }

    request.task = [self.defaultSession downloadTaskWithRequest:request.request];
    dispatch_sync(self.runningTasksSynchronizingQueue, ^{
        [self.activeTasks addObject:request];
    });
    request.state = NetRequestStateStarted;
}

- (void)startRequest:(_NetRequest *)request {
    if(!request || !request.request) {
        NSLog(@"Request is nil, check your URL and other parameters you use to build your request");
        return;
    }
  
  NSURLSession *sessionToUse = self.defaultSession;
  NSURLSessionDataTask *task =
    [sessionToUse
     dataTaskWithRequest:request.request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            [self handle:request data:data response:response error:error];
        }];
  
  request.task = task;
  
  dispatch_sync(self.runningTasksSynchronizingQueue, ^{
    [self.activeTasks addObject:request];
  });
  
  request.state = NetRequestStateStarted;
}

- (_NetRequest *)requestWithURLString:(NSString *)urlString {
    _NetRequest *request = [[_NetRequest alloc]
                            initWithURLString:urlString
                            params:nil
                            bodyData:nil
                            httpMethod:@"GET"];
    return request;
}

- (_NetRequest *)requestWithPath:(NSString *)path {
    return [self requestWithPath:path params:nil httpMethod:@"GET" body:nil ssl:self.secureHost];
}

- (_NetRequest *)requestWithPath:(NSString *)path
                          params:(NSDictionary *)params {
    return [self requestWithPath:path params:params httpMethod:@"GET" body:nil ssl:self.secureHost];
}

- (_NetRequest *)requestWithPath:(NSString *)path
                          params:(NSDictionary *)params
                      httpMethod:(NSString *)httpMethod {
    return [self requestWithPath:path
                          params:params
                      httpMethod:httpMethod
                            body:nil
                             ssl:self.secureHost];
}

- (_NetRequest *)requestWithPath:(NSString *)path
                          params:(NSDictionary *)params
                      httpMethod:(NSString *)httpMethod
                            body:(NSData *)bodyData
                             ssl:(BOOL) useSSL {
    if(self.hostName == nil) {
        NSLog(@"Hostname is nil, use requestWithURLString: method to create absolute URL operations");
        return nil;
    }

    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@://%@",
                                useSSL ? @"https" : @"http",
                                self.hostName];

    if(self.port != 0) [urlString appendFormat:@":%lu", (unsigned long)self.port];

    if(self.path) [urlString appendFormat:@"/%@", self.path];

    if(![path isEqualToString:@"/"]) { // fetch for root?

        if(path.length > 0 && [path characterAtIndex:0] == '/') // if user passes /, don't prefix a slash
            [urlString appendFormat:@"%@", path];
        else if (path != nil)
            [urlString appendFormat:@"/%@", path];
    }

    _NetRequest *request = [[_NetRequest alloc] initWithURLString:urlString
                                                           params:params
                                                         bodyData:bodyData
                                                       httpMethod:httpMethod.uppercaseString];

    request.parameterEncoding = self.defaultParameterEncoding;
    [request addHeaders:self.defaultHeaders];
    
    return request;
}

- (NSError *)errorForCompletedRequest:(_NetRequest *)completedRequest {
  // to be overridden by subclasses to tweak error objects by parsing the response body
  return completedRequest.error;
}

- (void)handle:(_NetRequest *)request data:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    if (request.state == NetRequestStateCancelled) {
        request.response = (NSHTTPURLResponse *)response;
        if (error) {
            request.error = error;
        }
        
        if (data) {
            request.responseData = data;
        }
        
        return;
    }
    if (!response) {
        request.response = (NSHTTPURLResponse*) response;
        request.error = error;
        request.responseData = data;
        request.state = NetRequestStateError;
        return;
    }
    
    request.response = (NSHTTPURLResponse*) response;
    
    if (request.response.statusCode >= 200 && request.response.statusCode < 300) {
        request.responseData = data;
        request.error = error;
    } else if(request.response.statusCode == 304) {
        
        // don't do anything
        
    } else if(request.response.statusCode >= 400) {
        request.responseData = data;
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if(response) userInfo[@"response"] = response;
        if(error) userInfo[@"error"] = error;
        
        NSError *httpError = [NSError errorWithDomain:@"com.mknetworkkit.httperrordomain"
                                                 code:request.response.statusCode
                                             userInfo:userInfo];
        request.error = httpError;
        
        // if subclass of host overrides errorForRequest: they can provide more insightful error objects by parsing the response body.
        // the super class implementation just returns the same error object set in previous line
        request.error = [self errorForCompletedRequest:request];
    }
    
    if (!request.error) {
        dispatch_sync(self.runningTasksSynchronizingQueue, ^{
            [self.activeTasks removeObject:request];
        });
        
        request.state = NetRequestStateCompleted;
    } else {
        dispatch_sync(self.runningTasksSynchronizingQueue, ^{
            [self.activeTasks removeObject:request];
        });
        request.state = NetRequestStateError;
        
        NSLog(@"%@", request);
    }
}

// MARK: - NSURLSession (Download/Upload) Progress notification delegates

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    __block _NetRequest *matchingRequest = nil;
    [self.activeTasks enumerateObjectsUsingBlock:^(_NetRequest *request, NSUInteger idx, BOOL *stop) {
        if([request.task isEqual:task]) {
            request.responseData = nil;
            request.response = (NSHTTPURLResponse *)task.response;
            request.error = error;
            
            if(error) {
                request.state = NetRequestStateError;
            } else {
                request.state = NetRequestStateCompleted;
            }
            
            *stop = YES;
        }
    }];

    dispatch_sync(self.runningTasksSynchronizingQueue, ^{
        [self.activeTasks removeObject:matchingRequest];
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    float progress = (float)(((float)totalBytesSent) / ((float)totalBytesExpectedToSend));
    [self.activeTasks enumerateObjectsUsingBlock:^(_NetRequest *request, NSUInteger idx, BOOL *stop) {

        if([request.task isEqual:task]) {
            [request setProgressValue:progress];
            *stop = YES;
        }
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    [self.activeTasks enumerateObjectsUsingBlock:^(_NetRequest *request, NSUInteger idx, BOOL *stop) {

        if([request.task.currentRequest.URL.absoluteString isEqualToString:downloadTask.currentRequest.URL.absoluteString]) {
          
            NSError *error = nil;
            if(![[NSFileManager defaultManager] moveItemAtPath:location.path toPath:request.downloadPath error:&error]) {

                NSLog(@"Failed to save downloaded file at requested path [%@] with error %@", request.downloadPath, error);
            }

            *stop = YES;
        }
    }];

    // call completion handler if the app was resumed and got connected again to our background session
    [self.defaultSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSUInteger count = dataTasks.count + uploadTasks.count + downloadTasks.count;

        if (count == 0) {
          void (^backgroundSessionCompletionHandlerCopy)(void) = self.backgroundSessionCompletionHandler;
          
          if (self.backgroundSessionCompletionHandler) {
            self.backgroundSessionCompletionHandler = nil;
            backgroundSessionCompletionHandlerCopy();
          }
        }
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  
    float progress = (float)(((float)totalBytesWritten) / ((float)totalBytesExpectedToWrite));
    [self.activeTasks enumerateObjectsUsingBlock:^(_NetRequest *request, NSUInteger idx, BOOL *stop) {

        if([request.task.currentRequest.URL.absoluteString isEqualToString:downloadTask.currentRequest.URL.absoluteString]) {
            [request setProgressValue:progress];
        }
    }];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
  if(session == self.defaultSession) {
    
    NSLog(@"Session became invalid with error: %@", error);
  }
}

@end
