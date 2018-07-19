
/*
 *  System Versioning Preprocessor Macros
 */
#define system_version [UIDevice currentDevice].systemVersion

#define system_version_equal_to( _version_ )  ([[[UIDevice currentDevice] systemVersion] compare:_version_ options:NSNumericSearch] == NSOrderedSame)

#define system_version_greater_than( _version_ )              ([[[UIDevice currentDevice] systemVersion] compare:_version_ options:NSNumericSearch] == NSOrderedDescending)

#define system_version_greater_than_or_equal_to( _version_ )  ([[[UIDevice currentDevice] systemVersion] compare:_version_ options:NSNumericSearch] != NSOrderedAscending)

#define system_version_less_than( _version_ )                 ([[[UIDevice currentDevice] systemVersion] compare:_version_ options:NSNumericSearch] == NSOrderedAscending)

#define system_version_less_than_or_equal_to( _version_ )     ([[[UIDevice currentDevice] systemVersion] compare:_version_ options:NSNumericSearch] != NSOrderedDescending)

// 系统版本 常量宏 定义
#define system_version_iOS8_or_later system_version_greater_than_or_equal_to(@"8.0")
#define system_version_iOS9_or_later system_version_greater_than_or_equal_to(@"9.0")
#define system_version_iOS10_or_later system_version_greater_than_or_equal_to(@"10.0")

/*
   Usage sample:

if (SYSTEM_VERSION_LESS_THAN(@"4.0")) {
    ...
}

if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.1.1")) {
    ...
}

*/

#define runloop_run_for_a_while \
        { \
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]; \
        }

/** 是否模拟器 */
#define is_simulator  (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)
#define is_device !is_simulator

/** 是否iPad */
#define is_iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/** 是否iPhone iPod touch */
#define is_iPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

/** 是否高清屏 */
#define is_retina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

/**
 *  判断系统版本宏定义，一般用于判断某段功能代码，是否参与编译
 
     #define __IPHONE_2_0      20000
     #define __IPHONE_2_1      20100
     #define __IPHONE_2_2      20200
     #define __IPHONE_3_0      30000
     #define __IPHONE_3_1      30100
     #define __IPHONE_3_2      30200
     #define __IPHONE_4_0      40000
     #define __IPHONE_4_1      40100
     #define __IPHONE_4_2      40200
     #define __IPHONE_4_3      40300
     #define __IPHONE_5_0      50000
     #define __IPHONE_5_1      50100
     #define __IPHONE_6_0      60000
     #define __IPHONE_6_1      60100
     #define __IPHONE_7_0      70000
     #define __IPHONE_7_1      70100
     #define __IPHONE_8_0      80000
     #define __IPHONE_8_1      80100
     #define __IPHONE_8_2      80200
     #define __IPHONE_8_3      80300
     #define __IPHONE_8_4      80400
     #define __IPHONE_9_0      90000
     #define __IPHONE_9_1      90100
     #define __IPHONE_9_2      90200
     #define __IPHONE_9_3      90300
     #define __IPHONE_10_0    100000
     #define __IPHONE_10_1    100100
     #define __IPHONE_10_2    100200
     #define __IPHONE_10_3    100300
 
 *  __IPHONE_OS_VERSION_MIN_REQUIRED 支持最低的系统版本
 *  __IPHONE_OS_VERSION_MAX_ALLOWED 允许最高的系统版本, 可以代表当前SDK的版本
 */



//frame 未整理 FIXME:
#define XPOINTOF(view) view.frame.origin.x
#define YPOINTOF(view) view.frame.origin.y
#define WIDTHOF(view) view.frame.size.width
#define HEIGHTOF(view) view.frame.size.height

#define MOVEVIEWTOX(view, x) view.frame = CGRectMake(x, YPOINTOF(view), WIDTHOF(view), HEIGHTOF(view))
#define MOVEVIEWTOY(view, y) view.frame = CGRectMake(XPOINTOF(view), y, WIDTHOF(view), HEIGHTOF(view))
#define CHANGEWIDTHOFVIEW(view, width) view.frame = CGRectMake(XPOINTOF(view), YPOINTOF(view), width, HEIGHTOF(view))
#define CHANGEHEIGHTOFVIEW(view, height) view.frame = CGRectMake(XPOINTOF(view), YPOINTOF(view), WIDTHOF(view), height)


//file path
#define FILE_DOCUMENT_PATH(path) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] stringByAppendingPathComponent: (path)]
#define FILE_CACHE_PATH(path) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0] stringByAppendingPathComponent: (path)]

//screen
#define IS_3_7_INCH_SCREEN CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] bounds].size)
#define IS_4_0_INCH_SCREEN CGSizeEqualToSize(CGSizeMake(320, 568), [[UIScreen mainScreen] bounds].size)
#define IS_4_7_INCH_SCREEN CGSizeEqualToSize(CGSizeMake(375, 667), [[UIScreen mainScreen] bounds].size)
#define IS_5_5_INCH_SCREEN CGSizeEqualToSize(CGSizeMake(414, 736), [[UIScreen mainScreen] bounds].size)
