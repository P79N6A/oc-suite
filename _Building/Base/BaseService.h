//
//  BaseService.h
//  PingYu
//
//  Created by Qian Ye on 16/3/29.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ SucceedBlock)(NSDictionary *data);
typedef void(^ FailureBlock)(NSError *error);
typedef void(^ NetworkErrorBlcok) (NSError *error);

@interface BaseService : NSObject

@property (nonatomic, strong) SucceedBlock refreshSucceedBlock;

@property (nonatomic, strong) FailureBlock refreshFailedBlock;

@property (nonatomic, strong) NetworkErrorBlcok netErrorBlock;

- (instancetype)initWithView:(UIView *)view;

- (void)startUpdateDataWithSucceed:(void(^)(NSDictionary *data))succeed failure:(void(^)(NSError *error))failure;

- (void)stopUpdateData;

@end
