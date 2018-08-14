//
//  ALSBrowserImpl.m
//  NewStructure
//
//  Created by 7 on 17/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "ALSBrowserImpl.h"
#import "ALSJavaScriptMessageHandlerImpl.h"

@interface ALSBrowserImpl ()

@property (nonatomic, strong) NSHashTable<id<_BrowserService>> *extensions;

@property (nonatomic, strong) NSHashTable<id<_JavaScriptMessagePerformer>> *performers;

@end

@implementation ALSBrowserImpl
@synthesize config;
@synthesize tempBrowser;
@synthesize extensions;
@synthesize mediator;

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        self.extensions = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        self.performers = [NSHashTable  hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    
    return self;
}

#pragma mark - Extension

- (void)addExtension:(id<_BrowserService>)e {
    NSAssert(e, @"e 空异常");
    
    [self.extensions addObject:e];
}

- (void)removeExtension:(id<_BrowserService>)e {
    NSAssert(e, @"e 空异常");
    
    [self.extensions removeObject:e];
}

- (void)eachExtension:(void (^)(id<_BrowserService>))handler {
    NSAssert(handler, @"handler 空异常");
    
    NSEnumerator<id<_BrowserService>> *iterator= self.extensions.objectEnumerator;
    
    [iterator.allObjects enumerateObjectsUsingBlock:^(id<_BrowserService>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        handler(obj);
    }];
}

#pragma mark - Performer

- (void)addPerformer:(id<_JavaScriptMessagePerformer>)p {
    NSAssert(p, @"p 空异常");
    
    [self.performers addObject:p];
}

- (void)removePerformer:(id<_JavaScriptMessagePerformer>)p {
    NSAssert(p, @"p 空异常");
    
    [self.performers removeObject:p];
}

- (void)eachPerformer:(BOOL (^)(id<_JavaScriptMessagePerformer>))handler {
    NSAssert(handler, @"handler 空异常");
    
    NSEnumerator<id<_JavaScriptMessagePerformer>> *iterator= self.performers.objectEnumerator;
    
    [iterator.allObjects enumerateObjectsUsingBlock:^(id<_JavaScriptMessagePerformer>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (! handler(obj)) *stop = YES;
    }];
}

#pragma mark -

- (id<_JavaScriptMessageHandler>)callbackWith:(id)data {
    return [ALSJavaScriptMessageHandlerImpl withRaw:data browser:self];
}

- (void)evaluateJavaScript:(NSString *)code completion:(void (^)(id, NSError *))completionHandler {
    
#if __has_ALSWebViewController
    [self.tempBrowser evaluateJavaScript:code completionHandler:^(id completion, NSError *error) {
        NSLog(@"Callback:%@, \n error:%@", completion,  error);
    }];
#endif
}

@end
