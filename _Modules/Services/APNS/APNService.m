
#import "APNService.h"
#import "JPushService.h"
#import "_pragma_push.h"

// ios 10 : http://www.jianshu.com/p/2f3202b5e758
// ios 10 : [玩转 iOS 10 推送 —— UserNotifications Framework（中）](http://www.jianshu.com/p/5a4b88874f3a)

NSString *PushServiceKey = nil;
NSString *PushServiceChannel = nil;
NSString *PushSereviceAdvertisingId = nil;

@interface APNService ()

+ (void)registerDeviceToken:(NSData *)deviceToken; // 在appdelegate注册设备处调用

@end

@implementation APNService

@def_singleton( APNService )

#pragma mark -

+ (void)setupWhenApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions clearBadge:(BOOL)bClearBadge {
    NSAssert(PushServiceKey, @"请初始化 PushServiceKey");
    NSAssert(PushServiceChannel, @"请初始化 PushServiceChannel");
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil]; // 可以添加自定义categories
    } else {
#import "_pragma_push.h"
        [JPUSHService registerForRemoteNotificationTypes:(UNAuthorizationOptionBadge |
                                                          UNAuthorizationOptionSound |
                                                          UNAuthorizationOptionAlert)
                                              categories:nil]; // categories 必须为nil
#import "_pragma_pop.h"
    }
    
#ifdef DEBUG
    BOOL isProductEnvirenment = NO;
#else
    BOOL isProductEnvirenment = YES;
#endif
    
    // 如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:PushServiceKey
                          channel:PushServiceChannel
                 apsForProduction:isProductEnvirenment
            advertisingIdentifier:PushSereviceAdvertisingId];
//    NSLog(@"%@---%@---%d---%@",PushServiceKey,PushServiceChannel,isProductEnvirenment,PushSereviceAdvertisingId);
    // If clear badge
    if (bClearBadge) {
        application.applicationIconBadgeNumber = 0;
    }
    
#if defined( __IPHONE_10_0 ) && ( __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 )
    // Authority print
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        LOG(@"%@", settings);
    }];
#endif
}

+ (void)registerDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

+ (void)handleWhenApplication:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    // Print deviceToken
    LOG(@"device token = %@", [self formatDeviceToken:deviceToken]);
    
    [self registerDeviceToken:deviceToken];
}

+ (void)handleWhenApplication:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

+ (void)handleWhenApplication:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        if (notificationSettings.types != UIUserNotificationTypeNone) {
            [application registerForRemoteNotifications];
        }
    }
}

+ (void)handleRemoteNotification:(NSDictionary *)userInfo completion:(void (^)(UIBackgroundFetchResult))completion {
    [JPUSHService handleRemoteNotification:userInfo];
    
    if (is_method_implemented([APNService sharedInstance].delegate, onRecieveRemoteNotification:)) {
        [[APNService sharedInstance].delegate onRecieveRemoteNotification:userInfo];
    }
    
    if (completion) {
        completion(UIBackgroundFetchResultNewData);
    }
    
    LOG(@"收到通知:%@", [self logDic:userInfo]);
}

+ (void)showLocalNotificationAtFront:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

#pragma mark - iOS 10

#if defined( __IPHONE_10_0 ) && ( __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 )

+ (void)handleWhenUserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}

+ (void)handleWhenUserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // The contents of the push payload will be set as the userInfo for remote notifications.
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    [JPUSHService handleRemoteNotification:userInfo];
    
    if (is_method_implemented([APNService sharedInstance].delegate, onRecieveRemoteNotification:)) {
        [[APNService sharedInstance].delegate onRecieveRemoteNotification:userInfo];
    }
    
    LOG(@"收到通知:%@", [self logDic:userInfo]);
    
    NSString *categoryIdentifier = response.notification.request.content.categoryIdentifier;
    if ([categoryIdentifier isEqualToString:@"handle category"]) {//识别需要被处理的拓展
        if ([response.actionIdentifier isEqualToString:@"input text"]) {//识别用户点击的是哪个 action
            
            //假设点击了输入内容的 UNTextInputNotificationAction 把 response 强转类型
            UNTextInputNotificationResponse *textResponse = (UNTextInputNotificationResponse*)response;
            //获取输入内容
            NSString *userText = textResponse.userText;
            
            UNUSED(userText)
            
            //发送 userText 给需要接收的方法
    //        [ClassName handleUserText: userText];
        }
    }
    
//    [self showAlertView:@"警告" message:@"请fallen处理" cancelButtonName:@"告知fallen"];
    // http://www.jianshu.com/p/5a4b88874f3a
    
    completionHandler();
}

#endif

#pragma mark - Badge management

- (void)setBadge:(NSInteger)value {
    [JPUSHService setBadge:value];
}

#pragma mark - Notification message management

- (UILocalNotification *)setLocalNotification:(NSDate *)fireDate alertBody:(NSString *)alertBody badge:(int)badge alertAction:(NSString *)alertAction identifierKey:(NSString *)notificationKey userInfo:(NSDictionary *)userInfo soundName:(NSString *)soundName {
    return [JPUSHService
            setLocalNotification:fireDate
            alertBody:alertBody
            badge:badge
            alertAction:alertBody
            identifierKey:notificationKey
            userInfo:nil
            soundName:nil];
}

- (void)deleteLocalNotification:(UILocalNotification *)localNotification {
    [JPUSHService deleteLocalNotification:localNotification];
}

- (void)clearAllLocalNotifications {
    [JPUSHService clearAllLocalNotifications];
    
    // [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark - Notification observe JPush SDK status

- (instancetype)init {
    if (self = [super init]) {
        [self initObserver];
    }
    
    return self;
}

- (void)dealloc {
    [self uinitObserver];
}

- (void)initObserver {
    [self observeNotification:kJPFNetworkIsConnectingNotification];
    [self observeNotification:kJPFNetworkDidSetupNotification];
    [self observeNotification:kJPFNetworkDidCloseNotification];
    [self observeNotification:kJPFNetworkDidRegisterNotification];
    [self observeNotification:kJPFNetworkDidLoginNotification];
    [self observeNotification:kJPFNetworkDidReceiveMessageNotification];
    [self observeNotification:kJPFServiceErrorNotification];
}

- (void)uinitObserver {
    [self unobserveAllNotifications];
}

- (void)handleNotification:(NSNotification *)notification {
    if ([notification is:kJPFNetworkIsConnectingNotification]) { // 正在连接中
        LOG(@"正在连接中...");
    } else if ([notification is:kJPFNetworkDidSetupNotification]) { // 建立连接
        LOG(@"建立连接");
    } else if ([notification is:kJPFNetworkDidCloseNotification]) { // 关闭连接
        LOG(@"关闭连接");
    } else if ([notification is:kJPFNetworkDidRegisterNotification]) { // 注册成功
        LOG(@"注册成功");
    } else if ([notification is:kJPFNetworkDidLoginNotification]) { // 登录成功
        LOG(@"登陆成功");
        
        // 获取 RegistrationID
        NSString *registrationId = [JPUSHService registrationID];
        if (is_method_implemented(self.delegate, onReceiveRegistrationId:)) {
            [self.delegate onReceiveRegistrationId:registrationId];
        }
        
    } else if ([notification is:kJPFNetworkDidReceiveMessageNotification]) { // 收到消息(非APNS)
        LOG(@"收到消息");
    
        // 在服务器端需要在极光推送提供的sdk中填写发给app的消息，并不是给apns
        NSDictionary * userInfo = [notification userInfo];

        if (is_method_implemented(self.delegate, onRecieveMessage:)) {
            [self.delegate onRecieveMessage:userInfo];
        }
        
    } else if ([notification is:kJPFServiceErrorNotification]) { // 错误提示
        LOG(@"错误提示, %@", notification.object);
    }
}

#pragma mark - Helper

// 将APNS NSData类型token 格式化成字符串
+ (NSString *)formatDeviceToken:(NSData *)deviceToken {
    return [[[[deviceToken description]
              stringByReplacingOccurrencesOfString: @"<" withString: @""]
             stringByReplacingOccurrencesOfString: @">" withString: @""]
            stringByReplacingOccurrencesOfString: @" " withString: @""];
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
+ (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
//    [NSPropertyListSerialization propertyListFromData:tempData
//                                     mutabilityOption:NSPropertyListImmutable
//                                               format:NULL
//                                     errorDescription:NULL];
    
    [NSPropertyListSerialization propertyListWithData:tempData
                                              options:NSPropertyListImmutable
                                               format:NULL
                                                error:NULL];
    return str;
}

@end

#pragma mark - 

@def_namespace( service, apns, APNService )

#import "_pragma_pop.h"
