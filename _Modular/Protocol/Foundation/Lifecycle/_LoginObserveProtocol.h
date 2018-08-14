#import <Foundation/Foundation.h>

@protocol _LoginObserveProtocol <NSObject>

/**
 *  可自动收到 登录 通知
 */
- (void)onLogin:(id)data;

@end
