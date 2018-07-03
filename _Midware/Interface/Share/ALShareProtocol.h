//
//  ALShareProtocol.h
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALShareConfigProtocol.h"
#import "ALShareParamProtocol.h"

@protocol ALShareProtocol <NSObject>

@property (nonatomic, assign) ALSharePlatformType platform;

@property (nonatomic, strong) id<ALShareConfigProtocol> config;

// Share to single session
- (void)shareWithParam:(id<ALShareParamProtocol>)param
               success:(void(^)(void))successHandler
               failure:(void(^)(NSError *error))failureHandler;

@end
