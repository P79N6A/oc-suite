#import <UIKit/UIKit.h>
#import "_Protocol.h"

@protocol _LaunchableProtocol <_Protocol>

/**
 *  可自动收到 app launch
 *
 *  @desc 在AppDelegate didFinishLaunching 后段调用
 */
+ (void)onLaunch:(UIApplication *)application options:(NSDictionary *)options;

@end
