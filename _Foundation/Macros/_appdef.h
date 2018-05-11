// app 相关
#define app_build       [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define app_version     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define app_display_name    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] // CFBundleDisplayName 这些字符串，在用source code方式打开info.plist文件，可以看到类似的键值

#define app_bundle_name [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey] // 对应 info.plist 中 key 为 bundle name 的value，当前设置的是：$(PRODUCT_NAME)

#define app_bundle_id   [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey] // 对应 info.plist 中 key 为 bundle identifier 的value，当前设置的是：$(PRODUCT_BUNDLE_IDENTIFIER)

// 设备相关
#define device_name             [[UIDevice currentDevice] name]
#define device_model            [[UIDevice currentDevice] model]
#define device_system_version    [[UIDevice currentDevice] systemVersion]

// 根据屏幕旋转方法获得当前屏幕宽度
#define UIScreenCurrentWidth (UIWindowIsLandscape ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)
// 根据屏幕旋转方法获得当前屏幕高度
#define UIScreenCurrentHeight (UIWindowIsLandscape ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
// 根据屏幕旋转方法获得当前屏幕大小
#define UIScreenCurrentSize CGSizeMake(UIScreenCurrentWidth, UIScreenCurrentHeight)

// 判断屏幕是否横屏
#define UIWindowIsLandscape UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)

// 判断屏幕是否竖屏
#define UIWindowIsPortrait !UIWindowIsLandscape

#define UIApplicationWindow [[UIApplication sharedApplication].delegate window]

// 横竖屏
#define is_landscape ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
