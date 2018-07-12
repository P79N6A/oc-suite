//
//  ComponentMqtt.m
//  component
//
//  Created by qingqing on 16/1/12.
//  Copyright © 2016年 OpenTeam. All rights reserved.
//

#import "MQTTService.h"
#import "MQCache.h"
#import "MQService.h"

// for now!!!todo-li: handle it.
static NSString * const kErrorDomain_GetMQTTConfig = @"kErrorDomain_GetMQTTConfig";

@implementation MQTTService

@def_singleton( MQTTService )

- (RACSignal *)mqttConfigForLoginUserSignal {
    INFO(@"获取mqtt配置信息");
    if (![MQService sharedInstance].mqttConfigRequesting) {
        [MQService sharedInstance].mqttConfigRequesting = YES;
        __unused NSString *urlStr = [NSString stringWithFormat:@"%@?client=%@&client_version=%@", @"kMqtt_Config_UrlString",@"iph", app_version];
//        return [[[[SignalFromRequest signalFromPBRequestWithApiPath:urlStr
//                                                     withHttpMethod:@"GET"
//                                                          pbMessage:nil
//                                                       withUserInfo:@{@"mqtt config key":@"MQTT config request"}]
//                  deliverOn:RACScheduler.mainThreadScheduler]
//                 flattenMap:^RACStream *(id value) {
//                     return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//                         //配置请求结束
//                         [MQService sharedInstance].mqttConfigRequesting = NO;
//
//                         NSError *errorPtr = nil;
//                         GPBConnectionInfoResponse *resp = [GPBConnectionInfoResponse parseFromData:value error:&errorPtr];
//                         if (resp.response.errorCode == 0) {//成功
//                             
//                             DDLogInfo(@"配置信息获取成功  clientID=%@,userID=%@,tk=%@,keepAliveSeconds=%d,ismqtt=%d",resp.clientId,resp.userId,resp.tk,resp.keepAliveSeconds,resp.isMqtt);
//                             // 保存配置信息
//                             _mqttConnectionInfo = resp;
//                             //连接mqtt
//                             [[MQService sharedInstance] patchConnect];
//                             
//                             if (resp.isMqtt) {
//                                 //删除过期消息
//                                 [[MQCache sharedInstance] handleExpiredMqttMessage];
//                                 //定时断线重练
//                                 [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disConnectMqtt) object:nil];
//                                 [self performSelector:@selector(disConnectMqtt) withObject:nil afterDelay:resp.reconnectMinute*60];
//                             }
//                             
//                             //发送通知进入注册流程步骤获取
//                             [subscriber sendNext:[NSNumber numberWithBool:YES]];
//                             [subscriber sendCompleted];
//                             NSLog(@"mqttConfigForLoginUserSignal %@ %@ %@",resp.clientId,resp.userId,resp.tk);
//                         } else {
//                             DDLogInfo(@"配置信息获取失败");
//                             
//                             TODO("nil ?")
//                             
//                             [subscriber sendError:nil];
//                         }
//                         return nil;
//                     }];
//                 }] doError:^(NSError *error) {
//                     [MQService sharedInstance].mqttConfigRequesting = NO;
//                 }];
        return [RACSignal empty];
    } else {
        return [RACSignal empty];
    }
}

- (void)disConnectMqtt {
    INFO(@"定期断线重练了");
    
    // 反订阅MQtt消息
    [[MQService sharedInstance] unpackSubscribes];
    // 断开连接
    [[MQService sharedInstance] patchDisconnect];
}

- (void)getMQTTConfigForRegisterUser {
    @weakify(self);
    [[[self mqttConfigForLoginUserSignal] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeError:^(NSError *error) {
         @strongify(self);
         int timeToConnect = arc4random()%3;
         [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getMQTTConfigForRegisterUser) object:nil];
         [self performSelector:@selector(getMQTTConfigForRegisterUser) withObject:nil afterDelay:timeToConnect+1];
     }];
}

@end
