#import <Foundation/Foundation.h>

// 日志模块需要 组件化设计
// Log
// LogConfig
// LogUpload
// CrashReport
@protocol _LogConfigureProtocol <NSObject>

@property (nonatomic, assign) BOOL enabledLocalLog;
@property (nonatomic, assign) BOOL enabledRemoteLog;


@end
