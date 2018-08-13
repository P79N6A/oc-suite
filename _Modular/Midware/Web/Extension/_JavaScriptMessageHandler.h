//
//  ALSJavaScriptMessageHandler.h
//  wesg
//
//  Created by 7 on 27/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSJavaScriptMessage.h"

@protocol ALSBrowserProtocol;

@protocol ALSJavaScriptMessageHandler <NSObject>

@property (nonatomic, strong) id<ALSJavaScriptMessage> message;

+ (instancetype)withRaw:(NSDictionary *)data browser:(id<ALSBrowserProtocol>)browser;

- (BOOL)invokeSuccess;
- (BOOL)invokeFailure;

- (BOOL)invoke:(NSString *)handlerCode;

@end
