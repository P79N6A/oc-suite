//
//  ALShareImpl.m
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "ALShareImpl.h"
#import "ALShareUtilityImpl.h"

@interface ALShareImpl ()

@property (nonatomic, strong) id<_ShareUtilityProtocol> utility;

@end

@implementation ALShareImpl
@synthesize config;
@synthesize platform;

// MARK: - Initializer

- (instancetype)init {
    if (self = [super init]) {
        self.utility = [ALShareUtilityImpl new];
    }
    
    return self;
}

// MARK: - Public Method

- (void)shareWithParam:(id<_ShareParamProtocol>)param
               success:(void (^)(void))successHandler
               failure:(void (^)(NSError *))failureHandler {
#if __has_ALSShareService
    ALSShareContext *context = nil;
    ALSShareObject *object = nil;
    
    NSUInteger platform = [self.utility typeOfPlatform:param.type];
    
    NSAssert(param.title, @"title 不能为空");
    NSAssert(param.detail, @"detail 不能为空");
    NSAssert(param.thumb, @"thumb 不能为空");
    NSAssert(param.url, @"title 不能为空");
    
    ALSShareScene scene = (ALSShareScene)param.scene;
    
    object = [ALSShareObject shareObjectWithTitle:param.title
                                      description:param.detail
                                    thumbImageUrl:[[NSURL alloc] initWithString:(NSString *)param.thumb]
                                        urlString:param.url];
    
    context = [[ALSShareContext alloc]
               initWithPlatform:(ALSSharePlatform)platform
               scene:scene
               shareObject:object];
    
    [[ALSShareService globalService] startShare:context withResponse:^(ALSShareResponse *resp) {
        if (resp.error) {
            failureHandler(resp.error);
        } else {
            successHandler();
        }
    }];
#endif
}

@end
