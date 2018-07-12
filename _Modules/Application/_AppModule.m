
#import <_Modules/ComponentMap.h>
#import <_Modules/APNService.h>
#import <_Modules/LocationService.h>

#import "_AppModule.h"
#import "_AppConfig.h"

@interface _AppModule ()

/**
 *  初始化数据库
 */
- (void)initDatabase;

/**
 *  初始化崩溃日志管理
 */
- (void)initFabric;
- (void)fabric_RecordError:(NSError *)error;

/**
 *  初始化网络模块
 */
- (void)initNetwork;

/**
 *  初始化一系列组件
 */
- (void)initComponent;

/**
 *  配置图片缓存
 */
- (void)initImageCache;

/**
 *  初始化键盘管理器
 */
- (void)initKeyBoardManager;

/**
 *  初始化定位服务
 */
- (void)initLocationComponent;

/**
 *  初始化远程通知
 */
- (void)initRemoteNotification;

/**
 *  初始化社交分享
 */
- (void)initSnshare;

#pragma mark -

/**
 *  清理磁盘缓存
 */
- (void)clearRecordCache;

@end

@implementation _AppModule

@def_singleton(_AppModule)

- (void)initServices {
    
}

- (void)initComponents {
    
    // Gao de
    if (! is_empty(app_config.mapApiKey))
    {
        [ComponentMap sharedInstance].config.apiKey = app_config.mapApiKey;
        
        [[ComponentMap sharedInstance] initGDAPIKey];
        
        [service.location powerOn];
    }
    
    //share
//    {
//        [[SNShareService sharedInstance] wechatConfig:^BOOL(SNShareService_Config *config) {
//            config.appId = app_config.wechatAppId;
//            config.scheme = app_config.wechatScheme;
//            
//            config.supported = YES;
//            
//            return YES;
//        } qqConfig:^BOOL(SNShareService_Config *config) {            
//            return NO;
//        } sinaConfig:^BOOL(SNShareService_Config *config) {
//            return NO;
//        } smsConfig:^BOOL(SNShareService_Config *config) {
//            return NO;
//        } emailConfig:^BOOL(SNShareService_Config *config) {
//            return NO;
//        } linkConfig:^BOOL(SNShareService_Config *config) {
//            return NO;
//        }];
//    }
    
    // Init pay module
    {
        
    }
    
    // Init notification module
    {
        PushServiceKey = app_config.pushKey;
        PushServiceChannel = app_config.pushChannel;
        [[APNService sharedInstance] setDelegate:app_config.pushDelegate];
    }
    
}

#pragma mark - Initialize

// FIXME: 需要重写
- (void)initDatabase {
    [self initRealm];
}

- (void)initRealm {
    //    uint64_t newestVersion = 1;
    //
    //    RLMRealmConfiguration *configration = [RLMRealmConfiguration defaultConfiguration];
    //
    //    configration.schemaVersion = newestVersion;
    //
    //    configration.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
    //        // We haven’t migrated anything yet, so oldSchemaVersion == 0
    //        if (oldSchemaVersion < newestVersion) {
    //            // Nothing to do!
    //            // Realm will automatically detect new properties and removed properties
    //            // And will update the schema on disk automatically
    //            // 1. 这只是粗略迁移，
    //            // 2. 如果需要有意义的迁移，如：多个字段合并为同一个字段，则
    //
    //            // The enumerateObjects:block: method iterates
    //            // over every 'Person' object stored in the Realm file
    //            //            [migration enumerateObjects:Person.className
    //            //                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
    //            //
    //            //                                      // combine name fields into a single field
    //            //                                      newObject[@"fullName"] = [NSString stringWithFormat:@"%@ %@",
    //            //                                                                oldObject[@"firstName"],
    //            //                                                                oldObject[@"lastName"]];
    //            //                                  }];
    //
    //
    //            // 3. 一般model向下面这么写：
    //            // v0
    //            // @interface Person : RLMObject
    //            // @property NSString *firstName;
    //            // @property NSString *lastName;
    //            // @property int age;
    //            // @end
    //
    //            // v1
    //            // @interface Person : RLMObject
    //            // @property NSString *fullName; // new property
    //            // @property int age;
    //            // @end
    //
    //            // v2
    //            //            @interface Person : RLMObject
    //            //            @property NSString *fullName;
    //            //            @property NSString *email;   // new property
    //            //            @property int age;
    //            //            @end
    //
    //            //            [migration enumerateObjects:Person.className
    //            //                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
    //            //                                      // Add the 'fullName' property only to Realms with a schema version of 0
    //            //                                      if (oldSchemaVersion < 1) {
    //            //                                          newObject[@"fullName"] = [NSString stringWithFormat:@"%@ %@",
    //            //                                                                    oldObject[@"firstName"],
    //            //                                                                    oldObject[@"lastName"]];
    //            //                                      }
    //            //
    //            //                                      // Add the 'email' property to Realms with a schema version of 0 or 1
    //            //                                      if (oldSchemaVersion < 2) {
    //            //                                          newObject[@"email"] = @"";
    //            //                                      }
    //            //                                  }];
    //        }
    //    };
    //
    //    // fallenink，待写完
    //    //    configration.path = [[configration.path stringByAppendingString:@"username"] stringByAppendingPathExtension:@"realm"];
    //
    //    // 还未做数据迁移
    //
    //    [RLMRealmConfiguration setDefaultConfiguration:configration];
}

- (void)initFabric {
    // 启动监测crash
    //    CrashlyticsKit.delegate = self;
    //    __unused id obj = [Fabric with:@[CrashlyticsKit]];
}

- (void)fabric_RecordError:(NSError *)error {
    //    [CrashlyticsKit recordError:error];
}

- (void)initNetwork {
    //    [_Network sharedInstance].config.timeoutInterval = 30;
    //    [_Network sharedInstance].config.retryCount = 1;
    //    [_Network sharedInstance].config.baseUrl = Host_Api;
    //    [_Network sharedInstance].config.imageUrl = Host_ImageSource;
    //    [_Network sharedInstance].config.imageStoreUrl = Host_ImageStore;
    //
    //    [_Network sharedInstance].config.advertiseHtmlUrl = Host_AdvertiseHtml;
    //    [_Network sharedInstance].config.staticHtmlUrl = Host_Html;
    //
    //    [_Network sharedInstance].config.reachableMonitorHostname = @"www.baidu.com";
    //    [_Network sharedInstance].config.reachableMonitorTimeout = 5.f;
    //    [_Network sharedInstance].config.reachableMonitorInterval = 1.f;
    //
    //    // 打开cache
    ////    [[_Network sharedInstance] enableNetCache];
    //
    //    // 系统偏好设置
    //#ifdef DEBUG
    //    {
    //        // 此处只是方便配置DEBUG版本中旧的二进制协议服务器IP地址
    //        NSString *serverIPInSettings = [[NSUserDefaults standardUserDefaults] objectForKey:@"base_url_preference"];
    //        if ((serverIPInSettings.length > 0) && [serverIPInSettings isIPAddress]) {
    //            [_Network sharedInstance].config.baseUrl = [NSString stringWithFormat:@"http://%@:8080", serverIPInSettings];
    //            [_Network sharedInstance].config.staticHtmlUrl = [NSString stringWithFormat:@"http://%@:80", serverIPInSettings];
    //        }
    //        NSString *imageServerIPInSettings = [[NSUserDefaults standardUserDefaults] objectForKey:@"image_url_preference"];
    //        if ((imageServerIPInSettings.length > 0) && [imageServerIPInSettings isIPAddress]) {
    //            [_Network sharedInstance].config.imageUrl = [NSString stringWithFormat:@"http://%@:8080", imageServerIPInSettings];
    //            [_Network sharedInstance].config.imageStoreUrl = [NSString stringWithFormat:@"http://%@:80", imageServerIPInSettings];
    //            [_Network sharedInstance].config.advertiseHtmlUrl = [NSString stringWithFormat:@"http://%@:80", imageServerIPInSettings];
    //        }
    //    }
    //#endif
}

- (void)initComponent {
    
    // Gao de
    //    if (![AppConfig sharedInstance].isMasterApp) {
    //        [[ComponentMap sharedInstance] initGDAPIKey];
    //    }
    
    // Init pay module
    
}

- (void)initImageCache {
    //    [SDImageCache sharedImageCache].maxMemoryCost = 256 * 1024 * 1024;   // 256M内存缓存，非精确值
    //    [SDImageCache sharedImageCache].maxCacheAge = [[NSDate distantFuture] timeIntervalSince1970];  // 永远不过期，通过下面的缓存大小限制，减轻服务器压力
    //    [SDImageCache sharedImageCache].maxCacheSize = 512 * 1024 * 1024;    // 512M磁盘缓存，精确值
}

- (void)initKeyBoardManager {
    //    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    //    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:NO];
}

- (void)initLocationComponent {
    //    if (![AppConfig sharedInstance].isMasterApp) {
    //        // 定位服务
    //        [LocationService sharedInstance];
    //    }
}

- (void)initRemoteNotification {
    //    UIApplication *application = [UIApplication sharedApplication];
    //
    //    //iOS 10 before
    //#if defined( __IPHONE_10_0 ) && ( __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 )
    //    if (IOS10_OR_LATER) {
    //        //__IPHONE_10_0
    //        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
    //            if (!error) {
    //                LOG(@"request authorization succeeded!");
    //            }
    //        }];
    //    } else
    //#endif
    //    {
    //        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    //            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    //            [application registerUserNotificationSettings:settings];
    //        } else {
    //            [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    //        }
    //    }
}

- (void)initSnshare {
    //    __block NSString *wechatAppId = nil;
    //    __block NSString *wechatScheme = nil;
    //    __block NSString *qqAppId = nil;
    //    __block NSString *qqScheme = nil;
    //
    //    [AppConfig adapterAppHairDresser:^{
    //        wechatAppId = AppShare_Hairdresser_WechatAppId;
    //        wechatScheme = AppShare_Hairdresser_WechatAppId;
    //
    //        qqAppId = AppShare_Teacher_TencentAppId;
    //        qqScheme = AppShare_Teacher_TencentAppId;
    //    } appCustomer:^{
    //        wechatAppId = AppShare_Customer_WechatAppId;
    //        wechatScheme = AppShare_Customer_WechatAppId;
    //
    //        qqAppId = AppShare_Student_TencentAppId;
    //        qqScheme = AppShare_Student_TencentAppId;
    //    } appMaster:^{
    //        wechatAppId = AppShare_Customer_WechatAppId;
    //        wechatScheme = AppShare_Customer_WechatAppId;
    //
    //        qqAppId = AppShare_Student_TencentAppId;
    //        qqScheme = AppShare_Student_TencentAppId;
    //    }];
    //
    //    [[SNShareService sharedInstance] wechatConfig:^BOOL(SNShareService_Config *config) {
    //        config.appId = wechatAppId;
    //        config.scheme = wechatScheme;
    //
    //        config.supported = YES;
    //
    //        return YES;
    //    } qqConfig:^BOOL(SNShareService_Config *config) {
    //        config.appId = qqAppId;
    //        config.scheme = qqScheme;
    //
    //        config.supported = YES;
    //
    //        return YES;
    //    } sinaConfig:^BOOL(SNShareService_Config *config) {
    //        return NO;
    //    } smsConfig:^BOOL(SNShareService_Config *config) {
    //        return NO;
    //    } emailConfig:^BOOL(SNShareService_Config *config) {
    //        return NO;
    //    } linkConfig:^BOOL(SNShareService_Config *config) {
    //        return NO;
    //    }];
}

#pragma mark -

- (void)clearRecordCache {
    //    TODO("get service name") // 不同的service、不同的文件夹，比如多个用户不能全删！！！
    //
    //    // 清理图片缓存
    //    [[SDImageCache sharedImageCache] clearMemory];
    //    [[SDImageCache sharedImageCache] clearDisk];
}

#pragma mark - crash handler delegate

//- (void)crashlyticsDidDetectReportForLastExecution:(CLSReport *)report completionHandler:(void (^)(BOOL))completionHandler {
//    // Use this opportinity to take synchronous action on a crash. See Crashlytics.h for
//    // details and implications.
//
//    // Maybe consult NSUserDefaults or show a UI prompt.
//    //    NSDictionary* logDic = [NSDictionary dictionaryWithObjectsAndKeys:@10000, @"logtype", @"o_quit_app", @"eventcode", nil];
//    //    [[DataCollectionService sharedInstance] sendDataByDictionary:logDic];
//
//    // But, make ABSOLUTELY SURE you invoke completionHandler, as the SDK
//    // will not submit the report until you do. You can do this from any
//    // thread, but that's optional. If you want, you can just call the
//    // completionHandler and return.
////    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
////        completionHandler(YES);
////    }];
//}


@end
