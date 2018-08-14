//
//  ALSJavaScriptMessage.h
//  wesg
//
//  Created by 7 on 27/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol _JavaScriptMessage <NSObject>

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSDictionary *data;

@property (nonatomic, strong) NSDictionary *param;

@property (nonatomic, strong) NSString *successCode;
@property (nonatomic, strong) NSString *failureCode;

+ (instancetype)with:(NSDictionary *)data;

- (BOOL)is:(NSString *)type; // 判断是否是该方法对应的message

@end
