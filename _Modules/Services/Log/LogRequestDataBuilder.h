//
//  LogRequestDataBuilder.h
// fallen.ink
//
//  Created by qingqing on 15/12/24.
//
//

#import "_precompile.h"
#import "_greats.h"

/**
 *  已经与android端，统一
 */

@interface LogRequestDataBuilder : NSObject

#pragma mark - LogRequestParamKey

@nsstring( Session )                  // ssesion（新增
@nsstring( QingQingUserId )           // QingQing 用户id (新增
@nsstring( UserId )                   // 用户id
@nsstring( DeviceSystemVersion )      // 设备系统版本
@nsstring( DeviceModel )              // 设备模型
@nsstring( ApplicationVersion )       // 应用版本
@nsstring( ApplicationClientType )    // 应用客户端类型
@nsstring( ApplicationFeedbackType )  // 应用反馈类型
@nsstring( ApplicationPlatform )      // 应用运行平台
@nsstring( ApplicationName )          // 应用名称
@nsstring( UserExplain )              // 用户尝试解释原因
@nsstring( UserQuestion )             // 用户选择的问题列表

#pragma mark - 

- (void)setQuestions:(NSString *)questions;
- (void)setExplain:(NSString *)explain;
- (void)setFeedbackType:(int32_t)type;

- (NSDictionary *)generate;

@end
