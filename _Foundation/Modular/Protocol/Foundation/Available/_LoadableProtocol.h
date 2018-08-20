#import "_Protocol.h"

@protocol _LoadableProtocol <_Protocol>

/**
 *  可自动收到 app加载时机 / 取代类加载时机
 *
 *  @desc 在AppDelegate加载之前调用
 */
+ (void)onLoad;

@end
