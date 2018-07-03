//
//  ALSBrowserImpl.m
//  NewStructure
//
//  Created by 7 on 17/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "ALSportsPrecompile.h"
#import "ALSBrowserImpl.h"
#import "ALSJavaScriptMessageHandlerImpl.h"

@interface ALSBrowserImpl ()

@property (nonatomic, strong) NSHashTable<id<ALSBrowserService>> *extensions;

@property (nonatomic, strong) NSHashTable<id<ALSJavaScriptMessagePerformer>> *performers;

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

- (void)addExtension:(id<ALSBrowserService>)e {
    NSAssert(e, @"e 空异常");
    
    [self.extensions addObject:e];
}

- (void)removeExtension:(id<ALSBrowserService>)e {
    NSAssert(e, @"e 空异常");
    
    [self.extensions removeObject:e];
}

- (void)eachExtension:(void (^)(id<ALSBrowserService>))handler {
    NSAssert(handler, @"handler 空异常");
    
    NSEnumerator<id<ALSBrowserService>> *iterator= self.extensions.objectEnumerator;
    
    [iterator.allObjects enumerateObjectsUsingBlock:^(id<ALSBrowserService>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        handler(obj);
    }];
}

#pragma mark - Performer

- (void)addPerformer:(id<ALSJavaScriptMessagePerformer>)p {
    NSAssert(p, @"p 空异常");
    
    [self.performers addObject:p];
}

- (void)removePerformer:(id<ALSJavaScriptMessagePerformer>)p {
    NSAssert(p, @"p 空异常");
    
    [self.performers removeObject:p];
}

- (void)eachPerformer:(BOOL (^)(id<ALSJavaScriptMessagePerformer>))handler {
    NSAssert(handler, @"handler 空异常");
    
    NSEnumerator<id<ALSJavaScriptMessagePerformer>> *iterator= self.performers.objectEnumerator;
    
    [iterator.allObjects enumerateObjectsUsingBlock:^(id<ALSJavaScriptMessagePerformer>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (! handler(obj)) *stop = YES;
    }];
}

#pragma mark -

- (id<ALSJavaScriptMessageHandler>)callbackWith:(id)data {
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
