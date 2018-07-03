//
//  ALSharesProtocol.h
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALShareProtocol.h"
#import "ALShareUtilityProtocol.h"
#import "ALShareParamProtocol.h"

@protocol ALSharesProtocol <NSObject>

@property (nonatomic, strong) id<ALShareProtocol> wechat;
@property (nonatomic, strong) id<ALShareProtocol> weibo;
@property (nonatomic, strong) id<ALShareProtocol> tencent;

@property (nonatomic, strong) id<ALShareParamProtocol> param;

@property (nonatomic, strong) id<ALShareUtilityProtocol> utility;

@property (nonatomic, strong) void (^ afterProcessHandler)(id<ALShareParamProtocol> param);

- (void)shareSuccess:(void(^)(void))successHandler
             failure:(void(^)(NSError *error))failureHandler;

@end
