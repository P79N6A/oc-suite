//
//  BaseService.m
//  PingYu
//
//  Created by Qian Ye on 16/3/29.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import "BaseService.h"

@implementation BaseService

- (instancetype)initWithView:(UIView *)view {
    return [super init];
}

- (void)startUpdateDataWithSucceed:(void (^)(NSDictionary *))succeed failure:(void (^)(NSError *))failure {
    
}


- (void)stopUpdateData {
    
}

@end
