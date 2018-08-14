
#import "_LoadableProtocol.h"
#import "_LaunchableProtocol.h"

// 模块化协议
@protocol _ModulableProtocol <_LoadableProtocol, _LaunchableProtocol>

+ (NSString *)moduleDescription; // 模块描述

@end
