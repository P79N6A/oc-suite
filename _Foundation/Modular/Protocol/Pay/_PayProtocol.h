#import "_Protocol.h"
#import "_PayParamProtocol.h"
#import "_PayConfigProtocol.h"

@protocol _PayProtocol <_Protocol>

@property (nonatomic, assign) BOOL isBusy; // 正在进行购买流程, 当前由使用方去管理

@property (nonatomic, strong) id<_PayParamProtocol> param;
@property (nonatomic, strong) id<_PayConfigProtocol> config;

- (void)payWithSuccess:(void (^)(void))successHandler failure:(void (^)(NSError *error))failureHandler;

@end
