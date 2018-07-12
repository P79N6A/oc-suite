//
//  APNService.h
//  hairdresser
//
//  Created by fallen.ink on 6/6/16.
//
//

#import "_module_x.h"

#if defined( __IPHONE_10_0 ) && ( __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 )
#import <UserNotifications/UserNotifications.h>
#endif

// ----------------------------------
// @knowledge
//
// 配置：
// 1. 音频文件为：sound.caf
// 2. 客户端配置：http://docs.jiguang.cn/client/ios_tutorials/#_8
// 2.1 Xcode 中修改应用的 Capabilities 开启Remote notifications
// 2.2
// 3. PushServiceKey：一个JPush 应用必须的,唯一的标识.
// 4. PushServiceChannel：发布渠道. 可选.
// 5. PushSereviceAdvertisingId：广告标识符（IDFA） 如果不需要使用IDFA，传nil.
//
// JPush diagram：
//     集成方                                   极光 云                       苹果推送服务器&苹果设备
//  ___________                                       _____________
// | Developer |                                     | APNs Sender |           _____________
// | App Server|                  ___________  ----->|_____________|--------> |    Apple    |
// |___________| --------------> |           |                                | APNs Server |
//                               | JPush API |                                |_____________|
//  ___________  --------------> |___________| -----> _____________                  |
// |   JPush   |                                     |    Conn     | JPush           |
// | Web Portal|                                     |_____________|---------->  ___\|/___
// |___________|                                                      TCP       |  Apple  |
//                                                                              |  Device |
//                                                                              |_________|
//
// 流程片段：
// 1. 应用启动配置
// 1.1 配置用户通知的类型、类别
// 1.2 传入
//
// 2. DeviceToken
// 2.1 当didRegisterForRemoteNotificationsWithDeviceToken，注册
//
// 3. 收取通知信息
// 3.1 当didReceiveRemoteNotification，调用handle remode notification
//
// 4. 改变服务端badge值
// 4.1 [JPUSHService setBadge:value];
//
// 5. 设置本地推送
// 5.1 (UILocalNotification *)setLocalNotification:(NSDate *)fireDate
//
// 6. 用户标签与别名：http://docs.jiguang.cn/client/ios_api/#api-ios
// 6.1 别名 alias
//      为安装了应用程序的用户，取个别名来标识。以后给该用户 Push 消息时，就可以用此别名来指定。
//      每个用户只能指定一个别名。
// 6.2 标签 tag
//      为安装了应用程序的用户，打上标签。其目的主要是方便开发者根据标签，来批量下发 Push 消息。
//      可为每个用户打多个标签
// ----------------------------------

EXTERN NSString *PushServiceKey;
EXTERN NSString *PushServiceChannel;
EXTERN NSString *PushSereviceAdvertisingId;

#pragma mark -

@protocol APNServiceDelegate;

@interface APNService : _Service

@singleton( APNService )

// ----------------------------------
// app 生命周期 相关操作
// ----------------------------------

+ (void)setupWhenApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions clearBadge:(BOOL)bClearBadge; // 在应用启动的时候调用

+ (void)handleWhenApplication:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

+ (void)handleWhenApplication:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

+ (void)handleWhenApplication:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;

+ (void)handleRemoteNotification:(NSDictionary *)userInfo completion:(void (^)(UIBackgroundFetchResult))completion; // ios7以后，才有completion，否则传nil

+ (void)showLocalNotificationAtFront:(UILocalNotification *)notification; // 显示本地通知在最前面

// ------- ios 10

#if defined( __IPHONE_10_0 ) && ( __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 )

// 应用在前台收到通知
+ (void)handleWhenUserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;

// 点击通知进入应用
+ (void)handleWhenUserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler;

#endif

// ----------------------------------
// sdk 网络连接状态
// ----------------------------------

@property (nonatomic, weak) id<APNServiceDelegate> delegate;

// ----------------------------------
// 角标管理
// ----------------------------------

- (void)setBadge:(NSInteger)value;

// ----------------------------------
// 本地通知信息管理
// ----------------------------------

- (UILocalNotification *)setLocalNotification:(NSDate *)fireDate
                                    alertBody:(NSString *)alertBody
                                        badge:(int)badge
                                  alertAction:(NSString *)alertAction
                                identifierKey:(NSString *)notificationKey
                                     userInfo:(NSDictionary *)userInfo
                                    soundName:(NSString *)soundName;

- (void)deleteLocalNotification:(UILocalNotification *)localNotification;

- (void)clearAllLocalNotifications;

@end

/**
 
 iOS API                            http://docs.jiguang.cn/client/ios_api/#apns
 
 标签与别名 API (iOS)
 获取 APNs（通知） 推送内容
 获取自定义消息推送内容
 获取 RegistrationID                  http://docs.jiguang.cn/client/ios_api/#registrationid
 页面的统计
 获取 OpenUDID
 设置Badge
 NSURLErrorDomain codes
 本地通知
 日志等级设置
 地理位置统计
 崩溃日志统计
 客户端错误码定义

 */

/** 要注意
 
 http://docs.jiguang.cn/server/rest_api_v3_push/
 
 服务端发送消息串:
 
 {
    "notification" : {
        "ios" : {
            "alert" : "hello, JPush!",
            "sound" : "sound.caf",
            "badge" : 1,
            "extras" : {
                "news_id" : 134,
                "my_key" : "a value"
            }
        }
    }
 }
 
 客户端收到apns:
 
 {
    "_j_msgid" = 813843507;
    aps =     {
        alert = "hello,JPush!";
        badge = 1;
        sound = "sound.caf";
    };
    "my_key" = "a value";
    "news_id" = 134;
 }
 
 */

@protocol APNServiceDelegate <NSObject>

/**
 *  集成了 JPush SDK 的应用程序在第一次成功注册到 JPush 服务器时，JPush 服务器会给客户端返回一个唯一的该设备的标识 - RegistrationID。JPush SDK 会以广播的形式发送 RegistrationID 到应用程序。
 
    应用程序可以把此 RegistrationID 保存以自己的应用服务器上，然后就可以根据 RegistrationID 来向设备推送消息或者通知。
 *
 *  @param registrationId ...
 */
- (void)onReceiveRegistrationId:(NSString *)registrationId;

/**
 *  只有在前端运行的时候才能收到自定义消息的推送。
 
 从jpush服务器获取用户推送的自定义消息内容和标题以及附加字段等。
 
 *
 *  @param notification ...
 */
- (void)onRecieveMessage:(NSDictionary *)notification;

//OS 设备收到一条推送（APNs），用户点击推送通知打开应用时，应用程序根据状态不同进行处理需在 AppDelegate 中的以下两个方法中添加代码以获取apn内容
//
//如果 App 状态为未运行，此函数将被调用，如果launchOptions包含UIApplicationLaunchOptionsRemoteNotificationKey表示用户点击apn 通知导致app被启动运行；如果不含有对应键值则表示 App 不是因点击apn而被启动，可能为直接点击icon被启动或其他。
//
//(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions; // apn 内容获取：NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey]
//基于iOS 6 及以下的系统版本，如果 App状态为正在前台或者点击通知栏的通知消息，那么此函数将被调用，并且可通过AppDelegate的applicationState是否为UIApplicationStateActive判断程序是否在前台运行。此种情况在此函数中处理：
//
//(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo; // apn内容为userInfo
//基于iOS 7 及以上的系统版本，如果是使用 iOS 7 的 Remote Notification 特性那么处理函数需要使用
//
//(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler; // apn内容为userInfo

- (void)onRecieveRemoteNotification:(NSDictionary *)notification;

@end

#pragma mark - 

@namespace( service , apns, APNService )
