//
//  ALSharesProtocol.h
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_ShareProtocol.h"
#import "_ShareUtilityProtocol.h"
#import "_ShareParamProtocol.h"

@protocol _SharesProtocol <NSObject>

@property (nonatomic, strong) id<_ShareProtocol> wechat;
@property (nonatomic, strong) id<_ShareProtocol> weibo;
@property (nonatomic, strong) id<_ShareProtocol> tencent;

@property (nonatomic, strong) id<_ShareParamProtocol> param;

@property (nonatomic, strong) id<_ShareUtilityProtocol> utility;

@property (nonatomic, strong) void (^ afterProcessHandler)(id<_ShareParamProtocol> param);

- (void)shareSuccess:(void(^)(void))successHandler
             failure:(void(^)(NSError *error))failureHandler;

@end
