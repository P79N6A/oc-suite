//
//  MessageService.m
// fallen.ink
//
//  Created by 李杰 on 2/9/15.
//
//

#import "MQService.h"
#import "MQCache.h"
#import "MQTTService.h"
#import "ReactiveCocoa.h"

@interface MQService ()
#if __has_MQTTSession
@property (nonatomic, strong) MQTTSession *session;
#endif

// 外部信息
@property (nonatomic, assign) BOOL isLogin;

@end

@implementation MQService

- (id)init {
    if (self = [super init]) {
        self.isAlive = NO;//表示mqtt是否已经连接成功
        self.isSubscribe = NO;//表示是否订阅了
        
        //创建消息本地缓存表
        [[MQCache sharedInstance] createMqttMessageTable];
    }
    return self;
}

- (void)dealloc {
    [self unobserveAllNotifications];
}

@def_singleton( MQService )

#pragma mark - Utility

- (NSString *)removeUnescapedCharacter:(NSString *)inputStr {
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    //获取那些特殊字符
    NSRange range = [inputStr rangeOfCharacterFromSet:controlChars];
    //寻找字符串中有没有这些特殊字符
    if (range.location != NSNotFound) {
        NSMutableString *mutable = [NSMutableString stringWithString:inputStr];
        while (range.location != NSNotFound) {
            [mutable deleteCharactersInRange:range]; //去掉这些特殊字符
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        return mutable;
    }
    return inputStr;
}

- (void)dispatchMessage:(NSString *)theMessage {
    LOG(@"%@",theMessage);
    
    NSString *stringWithNonEnd = theMessage;
    NSError *err = nil;
    NSData *data = [stringWithNonEnd dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:kNilOptions
                                                      error:&err]; //json数据当中没有 \n \r \t 等制表符

    
    if (err) {
        LOG(@"%@, %@", NSStringFromSelector(_cmd), err);
        
        NSString *filteredString = [self removeUnescapedCharacter:theMessage]; // json 里面的特殊控制字符，需要过滤
        
        jsonObject = [NSJSONSerialization JSONObjectWithData:[filteredString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    }
    
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)jsonObject;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(MQTTService:didReceiveMessage:)]) {
            [self.delegate MQTTService:self didReceiveMessage:dictionary];
        }
        
    } else if ([jsonObject isKindOfClass:[NSArray class]]) {
        NSArray *nsArray = (NSArray *)jsonObject;
        (void)nsArray;
        
        LOG(@"Dersialized JSON Array = %@", nsArray);
    } else {
        LOG(@"An error happened while deserializing the JSON data.");
    }
}

#pragma mark - 接口实现

- (void)patchConnect {
    if (![MQService sharedInstance].mqttIsConnecting && !self.isAlive) {
        [MQService sharedInstance].mqttIsConnecting = YES;
    }
}

- (void)patchReconnect {
    if (self.isLogin) {
        INFO(@"mqtt服务器断线重连...");

        @weakify(self);
        [[[[MQTTService sharedInstance] mqttConfigForLoginUserSignal] deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeError:^(NSError *error) {
             @strongify(self);
             int timeToConnect = arc4random()%3;
             [self performSelector:@selector(patchReconnect) withObject:nil afterDelay:timeToConnect+1];
         }];
    }
}

- (void)patchDisconnect {
    INFO(@"mqtt主动关闭");
}

- (void)mqttConnect {
    INFO(@"新mqtt开始连接...");
}

/*
 *订阅入口，根据服务器返回的配置来判断客户端订阅使用哪套协议
 */
- (void)patchSubscribes {

}

/*
 *反订阅入口，根据服务器返回的配置来判断客户端反订阅使用哪套协议
 */
- (void)unpackSubscribes {

}

/*
 *mqtt协议订阅
 */
- (void)mqttSubscribe {

}

/*
 *mqtt协议反订阅
 */
- (void)mqttUnsubscribe {

}

#if __has_MQTTSession
#pragma mark - MQTTClientDelegate

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error {
    
    switch (eventCode) {
        case MQTTSessionEventConnected: {
            DDLogInfo(@"新mqtt链接成功");
            self.isAlive = YES;
            [MQService sharedInstance].mqttIsConnecting = NO;
            
            [self patchSubscribes];
        }
            break;
        case MQTTSessionEventConnectionRefused: {
            DDLogInfo(@"新mqtt链接拒绝");
        }
            break;
        case MQTTSessionEventConnectionClosed: {
            DDLogInfo(@"新mqtt链接关闭");
            self.isAlive = NO;
            self.isSubscribe = NO;
            [MQService sharedInstance].mqttIsConnecting = NO;
            if (self.isLogin) {
                int timeToReconnect = arc4random()%3;
                [self performSelector:@selector(patchReconnect) withObject:nil afterDelay:timeToReconnect+1];
            }
        }
            break;
        case MQTTSessionEventConnectionError: {
            DDLogInfo(@"新mqtt链接失败");
        }
            break;
        case MQTTSessionEventProtocolError: {
            DDLogInfo(@"新mqtt protocol error");
        }
            break;
        case MQTTSessionEventConnectionClosedByBroker: {
            DDLogInfo(@"新mqtt MQTTSessionEventConnectionClosedByBroker");
        }
            break;
    }
}

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length])];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    DDLogInfo(@"%@",msg);
    
    NSError *err = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:kNilOptions
                                                      error:&err]; //json数据当中没有 \n \r \t 等制表符
    if (err) {
        NSString *filteredString = [self removeUnescapedCharacter:msg]; // json 里面的特殊控制字符，需要过滤
        jsonObject = [NSJSONSerialization JSONObjectWithData:[filteredString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    }
    
    TestDebugLog2(@"MQTT消息", @"json : %@", jsonObject);
    //过滤重复的消息
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        //解析消息内容
        NSDictionary *messageDic = (NSDictionary *)jsonObject;
        long long messageid = [[messageDic objectForKey:kMessageKeyMessageID] longLongValue];
        long long messageType = [[messageDic objectForKey:kCommandName] longLongValue];
        NSString *messageBody = [messageDic objectForKey:kMessageKeyMessageBody];
        
        if ([[MQCache sharedInstance] mqttMessageExistWithMessageID:messageid]) { //消息已经存在不作处理，丢弃
            //消息更新时间
            [[MQCache sharedInstance] updateMqttmessageWithMessageID:messageid
                                 withMessageTime:[[self TS_CurrentDate] timeIntervalSince1970]];
            return;
        } else { //消息不存在，发送消息回执并且存入数据库，然后分发到各个页面
            //发送消息回执
            [self messageReceiptRequestWithMessageID:messageid];
            //消息插入本地数据库，用于过滤重复消息,时间单位秒
            [[MQCache sharedInstance] insertLocalMqttMessageWithMessageID:messageid
                                      withMessageTime:[[self TS_CurrentDate] timeIntervalSince1970]
                                      withMessageType:messageType
                                      withMessageBody:messageBody];
        }
        
        [[GCDQueue mainQueue] queueBlock:^{
            [self performSelector:@selector(dispatchMessage:) withObject:msg];
        }];
    }
}

#endif

#pragma mark - Message receipt request

- (void)messageReceiptRequestWithMessageID:(long long)messageID {

}

#pragma mark - Property

- (BOOL)isLogin {
    _isLogin    = [self.delegate isUserLogined];
    return _isLogin;
}

- (void)setDelegate:(id<MQTTServiceDelegate>)delegate {
    _delegate   = delegate;
    
    // 必须要检查外界的视线情况
    NSAssert([self.delegate respondsToSelector:@selector(isUserLogined)],
             @"isUserLogined not implement by consignor.");
    NSAssert([self.delegate respondsToSelector:@selector(MQTTService:didConnected:)],
             @"MQTTService:didConnected: not implement by consignor.");
    NSAssert([self.delegate respondsToSelector:@selector(MQTTService:didDisconnected:)],
             @"MQTTService:didDisconnected: not implement by consignor.");
    NSAssert([self.delegate respondsToSelector:@selector(MQTTService:didReceiveMessage:)],
             @"MQTTService:didReceiveMessage: not implement by consignor.");
}

@end
