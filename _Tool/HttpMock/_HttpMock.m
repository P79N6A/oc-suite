#import "_HttpMock.h"
#import "_NSURLConnectionHook.h"
#import "_NSURLSessionHook.h"
#import "_HttpClientHook.h"
#import "_Foundation.h"

static _HttpMock *sharedInstance = nil;

@implementation _HttpMock

@def_singleton(_HttpMock)

- (id)init {
    self = [super init];
    if (self) {
        _stubbedRequests = [NSMutableArray array];
        _hooks = [NSMutableArray array];
        
        [self registerHook:[[_NSURLConnectionHook alloc] init]];
        
        if (NSClassFromString(@"NSURLSession") != nil) {
            [self registerHook:[[_NSURLSessionHook alloc] init]];
        }
    }
    return self;
}

- (void)startMock {
    if (!self.isStarted){
        [self loadHooks];
        self.started = YES;
    }
}

- (void)stopMock {
    [self unloadHooks];
    self.started = NO;
    [self clearMocks];
}

- (void)clearMocks {
    @synchronized(_stubbedRequests) {
        [_stubbedRequests removeAllObjects];
    }
}

- (void)addMockRequest:(_MockRequest *)request {
    @synchronized(_stubbedRequests) {
        [self.stubbedRequests addObject:request];
    }
}

- (void)registerHook:(_HttpClientHook *)hook {
    if (![self hookWasRegistered:hook]) {
        @synchronized(_hooks) {
            [_hooks addObject:hook];
        }
    }
}

- (BOOL)hookWasRegistered:(_HttpClientHook *)aHook {
    @synchronized(_hooks) {
        for (_HttpClientHook *hook in _hooks) {
            if ([hook isMemberOfClass: [aHook class]]) {
                return YES;
            }
        }
        return NO;
    }
}

- (_MockResponse *)responseForRequest:(id<_HTTPRequest>)request {
    @synchronized(_stubbedRequests) {
        
        invoke_nullable_block(self.logBlock, [NSString stringWithFormat:@"\n---------- Match begin ----------\n(%@)", request.description])
        
        for(_MockRequest *someStubbedRequest in _stubbedRequests) {
            
            invoke_nullable_block(self.logBlock, [NSString stringWithFormat:@"-> (%@)", someStubbedRequest.description])
            
            if ([someStubbedRequest matchesRequest:request]) {
                someStubbedRequest.response.isUpdatePartResponseBody = someStubbedRequest.isUpdatePartResponseBody;
                
                invoke_nullable_block(self.logBlock, @"--------- Match end success ------------ ")
                
                return someStubbedRequest.response;
            }
        }
        
        invoke_nullable_block(self.logBlock, @"Match end failed ------------ ")
        
        return nil;
    }
    
}

- (void)loadHooks {
    @synchronized(_hooks) {
        for (_HttpClientHook *hook in _hooks) {
            [hook load];
        }
    }
}

- (void)unloadHooks {
    @synchronized(_hooks) {
        for (_HttpClientHook *hook in _hooks) {
            [hook unload];
        }
    }
}

- (void)log:(NSString *)fmt, ... {
    if (!fmt || !self.logBlock) {
        return;
    }
    
    NSString *msg = nil;
    va_list args;
    va_start(args, fmt);
    msg = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    
    self.logBlock(msg);
}

@end
