//
//  _web_browser.h
//  hybrid-web
//
//  Created by 7 on 25/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "_web_config.h"

// ----------------------------------
// Macro
// ----------------------------------

#undef  app_browser
#define app_browser     [_WebBrowser sharedInstance]

// ----------------------------------
// Class Definition
// ----------------------------------

@interface _WebBrowser : NSObject

@property (nonatomic, readonly) _WebConfig *config;

@property (nonatomic, readonly) _WebBrowser *sharedInstance;
- (_WebBrowser *)sharedInstance;
+ (_WebBrowser *)sharedInstance;

@end
