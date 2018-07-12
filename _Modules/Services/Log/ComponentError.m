//
//  ComponentError.m
// fallen.ink
//
//  Created by fallen.ink on 12/21/15.
//
//

#import "ComponentError.h"
#import "LogFileManager.h"

const NSString *kContextAccount                 = @"{account}";             // 账号相关

const NSString *kContextRobOrder                = @"{rob order}";             // 订单相关
const NSString *kContextChangeOrder             = @"{change order}";
const NSString *kContextRenewOrder              = @"{renew order}";
const NSString *kContextNewOrder                = @"{new order}";

const NSString *kContextPercentage              = @"{percentage}";              // 分成

const NSString *kContextChat                    = @"{chatting}";              // 聊天功能
const NSString *kContextRecommendTeacher        = @"{recommend teacher}";


@implementation ComponentError

@def_singleton( ComponentError )

+ (void)load {
    [LogFileManager sharedInstance];
}

/*
 2015/12/28 10:55:17:084 threadID:1836070 E: fileName:LoginVM line:116  {account}, error=Error Doma2015/12/28 10:55:17:084 threadID:1836070 E: fileName:LoginVM line:116  {account}, error=Error Domain=kErrorDomainPB_LoginRequest Code=1003 "(null)" UserInfo={errorkey=username or password error}
 貌似有多线程问题 lumberjack
 */

@end
