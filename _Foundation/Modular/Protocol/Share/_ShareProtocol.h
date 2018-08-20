#import "_ShareConfigProtocol.h"
#import "_ShareParamProtocol.h"

@protocol _ShareProtocol <NSObject>

@property (nonatomic, assign) _SharePlatformType platform;

@property (nonatomic, strong) id<_ShareConfigProtocol> config;

// Share to single session
- (void)shareWithParam:(id<_ShareParamProtocol>)param
               success:(void(^)(void))successHandler
               failure:(void(^)(NSError *error))failureHandler;

@end
