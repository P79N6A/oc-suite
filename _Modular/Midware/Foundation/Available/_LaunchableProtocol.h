#import "_Protocol.h"

@protocol NSLaunchableProtocol <_Protocol>

/**
 *  可自动收到 app launch
 *
 *  @desc 在AppDelegate didFinishLaunching 后段调用
 */
+ (void)onLaunch;

@end
