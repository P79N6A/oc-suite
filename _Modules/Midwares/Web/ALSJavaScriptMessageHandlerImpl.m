//
//  ALSJavaScriptMessageHandlerImpl.m
//  wesg
//
//  Created by 7 on 27/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "ALSJavaScriptMessageHandlerImpl.h"
#import "ALSJavaScriptMessageImpl.h"

@interface ALSJavaScriptMessageHandlerImpl ()

@property (nonatomic, weak) id<_BrowserProtocol> browser;

@end

@implementation ALSJavaScriptMessageHandlerImpl
@synthesize message;

+ (instancetype)withRaw:(NSDictionary *)data browser:(id<_BrowserProtocol>)browser {
    ALSJavaScriptMessageImpl *message = [ALSJavaScriptMessageImpl with:data];
    
    if (!message) {
        return nil;
    }
    
    ALSJavaScriptMessageHandlerImpl *callback = [ALSJavaScriptMessageHandlerImpl new];
    
    callback.message = message;
    
    return callback;
}

- (BOOL)invokeSuccess {
    return [self invoke:self.message.successCode];
}

- (BOOL)invokeFailure {
    return [self invoke:self.message.failureCode];
}

- (BOOL)invoke:(NSString *)handlerCode {
    if (!handlerCode || ![handlerCode isKindOfClass:[NSString class]] || handlerCode == 0) {
        return NO;
    }
    
#if __has_ALSWebViewController
    [self.browser evaluateJavaScript:handlerCode completion:^(id completion, NSError *error) {
        NSLog(@"Callback:%@, \n error:%@", completion,  error);
    }];
#endif
    
    return YES;
}

@end
