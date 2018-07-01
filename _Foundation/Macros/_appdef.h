
#define app_build                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define app_version                 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define app_display_name            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
#define app_bundle_name             [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]
#define app_bundle_id               [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey]

#define app_device_name             [[UIDevice currentDevice] name]
#define app_device_model            [[UIDevice currentDevice] model]
#define app_device_system_version   [[UIDevice currentDevice] systemVersion]

#define app_window                  [[UIApplication sharedApplication].delegate window]
#define app_window_is_landscape     UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
#define app_window_is_portrait      !app_window_is_landscape
#define app_window_current_width    (app_window_is_landscape ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)
#define app_window_current_height   (app_window_is_landscape ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define app_window_current_size     CGSizeMake(app_window_current_width, app_window_current_height)

// 横竖屏
#define is_landscape                app_window_is_landscape
#define is_portrait                 app_window_is_portrait
