//
//  _web_browser.m
//  hybrid-web
//
//  Created by 7 on 25/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "_web_browser.h"

@interface _WebBrowser () {
    _WebConfig *_config;
}

@end

@implementation _WebBrowser

// MARK: - Singleton

@dynamic sharedInstance;
- (_WebBrowser *)sharedInstance {
    return [_WebBrowser sharedInstance];
}
+ (_WebBrowser *)sharedInstance {
    static dispatch_once_t once;
    static __strong id __singleton__ = nil;
    dispatch_once( &once, ^{ __singleton__ = [[_WebBrowser alloc] init]; } );
    return __singleton__;
}

// MARK: - Initializer

- (instancetype)init {
    if (self = [super init]) {
        _config = [_WebConfig new];
        
        if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {
            _config.enabledWKWebView = YES;
        } else {
            _config.enabledWKWebView = NO;
        }
    }
    
    return self;
}

// MARK: - Property

- (_WebConfig *)config {
    return _config;
}

@end
