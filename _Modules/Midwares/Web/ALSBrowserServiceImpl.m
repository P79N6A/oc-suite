//
//  ALSBrowserServiceImpl.m
//  wesg
//
//  Created by 7 on 30/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "ALSBrowserServiceImpl.h"

@implementation ALSBrowserServiceImpl 
@synthesize mediator;
@synthesize webView;
@synthesize containerView;

- (BOOL)handleMessage:(id<_JavaScriptMessageHandler>)handler {
    return NO;
}

- (void)pageDidLoad:(UIView *)view web:(UIView *)webView {
    
}

- (void)pageDidUnload:(UIView *)view {
    
}

@end
