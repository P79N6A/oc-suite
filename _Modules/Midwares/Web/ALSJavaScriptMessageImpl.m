//
//  ALSJavaScriptMessageImpl.m
//  wesg
//
//  Created by 7 on 27/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "ALSJavaScriptMessageImpl.h"

@implementation ALSJavaScriptMessageImpl
@synthesize data;
@synthesize param;
@synthesize successCode;
@synthesize failureCode;
@synthesize type;

+ (instancetype)with:(NSDictionary *)data {
    ALSJavaScriptMessageImpl *message = [ALSJavaScriptMessageImpl new];
    
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    message.type = [data objectForKey:@"method"];
    
    message.param = [data objectForKey:@"parameter"];
    if (![message.param isKindOfClass:[NSDictionary class]]) {
        message.param = nil;
    }
    
    NSDictionary *callBackData = [data objectForKey:@"callback"];
    
    if (!callBackData || ![callBackData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    message.successCode = callBackData[@"success_callback"];
    message.failureCode = callBackData[@"fail_callback"];
    
    return message;
}

- (BOOL)is:(NSString *)type {
    return [self.type hasPrefix:type];
}

@end
