//
//  ALSPayProtocol.h
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "ALSProtocol.h"
#import "ALSPayParamProtocol.h"
#import "ALSPayConfigProtocol.h"

@protocol ALSPayProtocol <ALSProtocol>

@property (nonatomic, assign) BOOL isBusy; // 正在进行购买流程, 当前由使用方去管理

@property (nonatomic, strong) id<ALSPayParamProtocol> param;
@property (nonatomic, strong) id<ALSPayConfigProtocol> config;

- (void)payWithSuccess:(void (^)(void))successHandler failure:(void (^)(NSError *error))failureHandler;

@end
