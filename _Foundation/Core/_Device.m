#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "_Foundation.h"
#import "_Keychain.h"

#pragma mark -

NSString * const UUIDForInstallationKey = @"uuidForInstallation";
NSString * const UUIDForDeviceKey = @"uuidForDevice";

#pragma mark -

/**
 *  @author fallenink
 
 *  About error: @""
 
 *  Initialize in Class Method: @"+ (void)initialize"
 *  or change file suffix from "*.m" to "*.mm"
 */

BOOL IOS8 = NO;
BOOL IOS9 = NO;
BOOL iOS10 = NO;
BOOL iOS11 = NO;

BOOL iOS11_or_later = NO;
BOOL IOS10_OR_LATER = NO;
BOOL IOS9_OR_LATER = NO;
BOOL IOS8_OR_LATER = NO;
BOOL IOS7_OR_LATER = NO;
BOOL IOS6_OR_LATER = NO;
BOOL IOS5_OR_LATER = NO;
BOOL IOS4_OR_LATER = NO;
BOOL IOS3_OR_LATER = NO;

BOOL iOS11_or_earlier = NO;
BOOL IOS9_OR_EARLIER = NO;
BOOL IOS8_OR_EARLIER = NO;
BOOL IOS7_OR_EARLIER = NO;
BOOL IOS6_OR_EARLIER = NO;
BOOL IOS5_OR_EARLIER = NO;
BOOL IOS4_OR_EARLIER = NO;
BOOL IOS3_OR_EARLIER = NO;

BOOL IS_SCREEN_35_INCH = NO;
BOOL IS_SCREEN_4_INCH = NO;
BOOL IS_SCREEN_47_INCH = NO;
BOOL IS_SCREEN_55_INCH = NO;
BOOL is_screen_58_inch = NO;

#pragma mark -

@implementation _Device {
    // uuids
    NSString *_uuidForSession;
    NSString *_uuidForInstallation;
}

@def_singleton( _Device );

@def_prop_readonly( NSString *,			osVersion );
@def_prop_readonly( OperationSystem,	osType );
@def_prop_readonly( NSString *,			bundleVersion );
@def_prop_readonly( NSString *,			bundleShortVersion );
@def_prop_readonly( NSString *,			bundleIdentifier );
@def_prop_readonly( NSString *,			urlSchema );
@def_prop_readonly( NSString *,			deviceModel );

@def_prop_readonly( BOOL,				isJailBroken );
@def_prop_readonly( BOOL,				runningOnPhone );
@def_prop_readonly( BOOL,				runningOnPad );
@def_prop_readonly( BOOL,				requiresPhoneOS );

@def_prop_readonly( BOOL,				isScreenPhone );
@def_prop_readonly( BOOL,				isScreen320x480 );
@def_prop_readonly( BOOL,				isScreen640x960 );
@def_prop_readonly( BOOL,				isScreen640x1136 );

@def_prop_readonly( BOOL,				isScreenPad );
@def_prop_readonly( BOOL,				isScreen768x1024 );
@def_prop_readonly( BOOL,				isScreen1536x2048 );

@def_prop_readonly( CGSize,				screenSize );

@def_prop_readonly( double,             totalMemory );
@def_prop_readonly( double,				availableMemory );
@def_prop_readonly( double,				usedMemory );

@def_prop_readonly( double,				availableDisk );

@def_prop_readonly( NSString *,         appSize );

@def_prop_readonly( NSString *,         buildCode );
@def_prop_readonly( int32_t,            intAppVersion );
@def_prop_readonly( NSString *,         appVersion );

@def_prop_readonly( BOOL,               photoCaptureAccessable );
@def_prop_readonly( BOOL,               photoLibraryAccessable );

@def_prop_readonly( NSArray *,          languages );

@def_prop_readonly( NSString *,         uuid );
@def_prop_readonly( NSString *,         uuidForSession );
@def_prop_readonly( NSString *,         uuidForInstallation );
@def_prop_readonly( NSString *,         uuidForVendor );
@def_prop_readonly( NSString *,         uuidForDevice );

+ (void)load {
    [self sharedInstance];
    
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    /**
     *  ios 10.0 新方案：
     *
     *  自从前段时间我们放弃了 iOS 7，我们可以轻易的切换到新的 isOperatingSystemAtLeastVersion: 方法上。其内部实现是通过调用 operatingSystemVersion ，是相当高效的
     */
    // 判断当前系统版本
    IOS8 = [[UIDevice currentDevice].systemVersion floatValue] >= 8.0 && [[UIDevice currentDevice].systemVersion floatValue] < 9.0;
    IOS9 = [[UIDevice currentDevice].systemVersion floatValue] >= 9.0 && [[UIDevice currentDevice].systemVersion floatValue] < 10.0;
    iOS10 = [[UIDevice currentDevice].systemVersion floatValue] >= 10.0 && [[UIDevice currentDevice].systemVersion floatValue] < 11.0;
    iOS11 = [[UIDevice currentDevice].systemVersion floatValue] >= 11.0 && [[UIDevice currentDevice].systemVersion floatValue] < 12.0;

    iOS11_or_later = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0);
    IOS10_OR_LATER = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0);
    IOS9_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0);
    IOS8_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0);
    IOS7_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0);
    IOS6_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0);
    IOS5_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0);
    IOS4_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0);
    IOS3_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0);
    
    iOS11_or_earlier = !iOS11_or_later;
    IOS9_OR_EARLIER = !IOS10_OR_LATER;
    IOS8_OR_EARLIER = !IOS9_OR_LATER;
    IOS7_OR_EARLIER = !IOS8_OR_LATER;
    IOS6_OR_EARLIER = !IOS7_OR_LATER;
    IOS5_OR_EARLIER = !IOS6_OR_LATER;
    IOS4_OR_EARLIER = !IOS5_OR_LATER;
    IOS3_OR_EARLIER = !IOS4_OR_LATER;
    
    /**
     以下数据，来源于 模拟器调试打印
     机型                分辨率          ???             PPI         尺寸          启动图大小
     X              1125x2001       375x812 @3x                     5.8         1125x2436
         - Safe Area
             > 竖屏：UIEdgeInsets(44.0, 0.0, 34.0, 0.0) 上左下右
             > 横屏：UIEdgeInsets(0.0, 44.0, 21.0, 44.0) 上左下右
     SE             640x1136                                        4
     5S             640x1136                                        4
     8P             1242x2208
     7P             1242x2208                                       5.5
     6P             1242x2208
     6SP            1242x2208
     8              750x1334                                        4.7
     7              750x1334
     6S             750x1334
     6              750x1334        375x667 @2x
     4              640x960
     4S             640x960
     */
    IS_SCREEN_4_INCH = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO);
    IS_SCREEN_35_INCH = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO);
    IS_SCREEN_47_INCH = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO);
    IS_SCREEN_55_INCH = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO);
    is_screen_58_inch = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436)/** 如果不适配启动图，那么有效显示区域在中间，上下有黑边，同时这里获取到的height为2001.所以先适配启动图 */, [[UIScreen mainScreen] currentMode].size) : NO);
#else
    // all NO
#endif
}

- (NSString *)now {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)osVersion {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return [NSString stringWithFormat:@"%@ %@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
#else
    return nil;
#endif
}

- (OperationSystem)osType {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return OperationSystem_iOS;
#elif (TARGET_OS_MAC)
    return OperationSystem_Mac;
#else
    return OperationSystem_Unknown;
#endif
}

- (NSString *)bundleVersion {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC)
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
#else
    return nil;
#endif
}

- (NSString *)bundleShortVersion {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC)
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
#else
    return nil;
#endif
}

- (NSString *)bundleIdentifier {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
#else
    return nil;
#endif
}

- (NSString *)urlSchema {
    return [self urlSchemaWithName:nil];
}

- (NSString *)urlSchemaWithName:(NSString *)name {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    NSArray * array = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    for ( NSDictionary * dict in array ) {
        if ( name ) {
            NSString * URLName = [dict objectForKey:@"CFBundleURLName"];
            if ( nil == URLName ) {
                continue;
            }
            
            if ( NO == [URLName isEqualToString:name] ) {
                continue;
            }
        }
        
        NSArray * URLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
        if ( nil == URLSchemes || 0 == URLSchemes.count ) {
            continue;
        }
        
        NSString * schema = [URLSchemes objectAtIndex:0];
        if ( schema && schema.length ) {
            return schema;
        }
    }
    
    return nil;
    
#else
    
    return nil;
    
#endif
}

- (NSString *)deviceModel {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return [UIDevice currentDevice].model;
#else
    return nil;
#endif
}

#pragma mark - JailBroken

- (BOOL)isJailBroken {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    static const char * __jb_apps[] = {
        "/Application/Cydia.app",
        "/Application/limera1n.app",
        "/Application/greenpois0n.app",
        "/Application/blackra1n.app",
        "/Application/blacksn0w.app",
        "/Application/redsn0w.app",
        NULL
    };
    
    // method 1
    
    for ( int i = 0; __jb_apps[i]; ++i ) {
        if ( [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:__jb_apps[i]]] ) {
            return YES;
        }
    }
    
    // method 2
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] ) {
        return YES;
    }
    
    // method 3
    
    //#ifdef __IPHONE_8_0
    //
    //	if ( 0 == posix_spawn("ls") )
    //	{
    //		return YES;
    //	}
    //
    //#else
    //
    //	if ( 0 == system("ls") )
    //	{
    //		return YES;
    //	}
    //
    //#endif
    
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    return NO;
}

#pragma mark - Go on

- (BOOL)runningOnPhone {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    NSString * deviceType = [UIDevice currentDevice].model;
    if ( [deviceType rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch].length > 0 ||
        [deviceType rangeOfString:@"iPod" options:NSCaseInsensitiveSearch].length > 0 ||
        [deviceType rangeOfString:@"iTouch" options:NSCaseInsensitiveSearch].length > 0 ) {
        return YES;
    }
    
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    return NO;
}

- (BOOL)runningOnPad {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    NSString * deviceType = [UIDevice currentDevice].model;
    if ( [deviceType rangeOfString:@"iPad" options:NSCaseInsensitiveSearch].length > 0 ) {
        return YES;
    }
    
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    return NO;
}

- (BOOL)requiresPhoneOS {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    return [[[NSBundle mainBundle].infoDictionary objectForKey:@"LSRequiresIPhoneOS"] boolValue];
    
#else
    
    return NO;
    
#endif
}

- (BOOL)isScreenPhone {
    if ( [self isScreen320x480] || [self isScreen640x960] || [self isScreen640x1136] || [self isScreen750x1334] || [self isScreen1242x2208] || [self isScreen1125x2001] ) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isScreen320x480 {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    if ( [self runningOnPad] ) {
        if ( [self requiresPhoneOS] && [self isScreen768x1024] ) {
            return YES;
        }
        
        return NO;
    } else {
        return [self isScreenSizeEqualTo:CGSizeMake(320, 480)];
    }
    
#endif
    
    return NO;
}

- (BOOL)isScreen640x960 {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    if ( [self runningOnPad] ) {
        if ( [self requiresPhoneOS] && [self isScreen1536x2048] ) {
            return YES;
        }
        
        return NO;
    } else {
        return [self isScreenSizeEqualTo:CGSizeMake(640, 960)];
    }
    
#endif
    
    return NO;
}

- (BOOL)isScreen640x1136 {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    if ( [self runningOnPad] ) {
        return NO;
    } else {
        return [self isScreenSizeEqualTo:CGSizeMake(640, 1136)];
    }
    
#endif
    
    return NO;
}

- (BOOL)isScreen750x1334 {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    if ( [self runningOnPad] ) {
        return NO;
    } else {
        return [self isScreenSizeEqualTo:CGSizeMake(750, 1334)];
    }
    
#endif
    
    return NO;
}

- (BOOL)isScreen1242x2208 {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    if ( [self runningOnPad] ) {
        return NO;
    } else {
        return [self isScreenSizeEqualTo:CGSizeMake(1242, 2208)];
    }
    
#endif
    
    return NO;
}

- (BOOL)isScreen1125x2001 {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    if ( [self runningOnPad] ) {
        return NO;
    } else {
        return [self isScreenSizeEqualTo:CGSizeMake(1125, 2001)];
    }
    
#endif
    
    return NO;
}

- (BOOL)isScreenPad {
    if ( [self isScreen768x1024] || [self isScreen1536x2048] ) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isScreen768x1024 {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    return [self isScreenSizeEqualTo:CGSizeMake(768, 1024)];
    
#endif
    
    return NO;
}

- (BOOL)isScreen1536x2048 {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    return [self isScreenSizeEqualTo:CGSizeMake(1536, 2048)];
    
#endif
    
    return NO;
}

- (CGSize)screenSize {
    return [UIScreen mainScreen].currentMode.size;
}

- (BOOL)isScreenSizeEqualTo:(CGSize)size {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    CGSize size2 = CGSizeMake( size.height, size.width );
    CGSize screenSize = [UIScreen mainScreen].currentMode.size;
    
    if ( CGSizeEqualToSize(size, screenSize) || CGSizeEqualToSize(size2, screenSize) ) {
        return YES;
    }
    
#endif
    
    return NO;
}

- (BOOL)isScreenSizeSmallerThan:(CGSize)size {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    CGSize size2 = CGSizeMake( size.height, size.width );
    CGSize screenSize = [UIScreen mainScreen].currentMode.size;
    
    if ( (size.width > screenSize.width && size.height > screenSize.height) ||
        (size2.width > screenSize.width && size2.height > screenSize.height) ) {
        return YES;
    }
    
#endif
    
    return NO;
}

- (BOOL)isScreenSizeBiggerThan:(CGSize)size {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    CGSize size2 = CGSizeMake( size.height, size.width );
    CGSize screenSize = [UIScreen mainScreen].currentMode.size;
    
    if ( (size.width < screenSize.width && size.height < screenSize.height) ||
        (size2.width < screenSize.width && size2.height < screenSize.height) ) {
        return YES;
    }
    
#endif
    
    return NO;
}

- (BOOL)isOsVersionOrEarlier:(NSString *)ver {
    if ( [[self osVersion] compare:ver] != NSOrderedDescending ) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isOsVersionOrLater:(NSString *)ver {
    if ( [[self osVersion] compare:ver] != NSOrderedAscending ) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isOsVersionEqualTo:(NSString *)ver {
    if ( NSOrderedSame == [[self osVersion] compare:ver] ) {
        return YES;
    } else {
        return NO;
    }	
}

#pragma mark - memory

- (double)totalMemory {
    return [[NSProcessInfo processInfo] physicalMemory]/1024.0/1024.0;
}

- (double)availableMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

- (double)usedMemory {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

#pragma mark - Disk

- (double)availableDisk {
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfFileSystemForPath:path_of_document error:nil];
    
    return [attributes[NSFileSystemFreeSize] unsignedLongLongValue] / (double)0x100000;
}

- (NSString *)appSize {
    unsigned long long docSize   =  [self sizeOfFolder:path_of_document];
    unsigned long long libSize   =  [self sizeOfFolder:path_of_library];
    unsigned long long cacheSize =  [self sizeOfFolder:path_of_cache];
    
    unsigned long long total = docSize + libSize + cacheSize;
    
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:total countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}

- (unsigned long long)sizeOfFolder:(NSString *)folderPath {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long folderSize = 0;
    
    while (file = [contentsEnumurator nextObject]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    return folderSize;
}

#pragma mark -

- (NSString *)buildCode {
    return app_build; // ^_^
}

- (int32_t)intAppVersion {
    NSString *versionStr = app_version;
    NSArray *strVerArr = [versionStr componentsSeparatedByString:@"."];
    NSMutableString *version = [[NSMutableString alloc]init];
    for (int i =0 ; i<strVerArr.count; i++) {
        NSString *str = strVerArr[i];
        if (i == strVerArr.count-1 &&
            str.length == 1) {
            
            str = [NSString stringWithFormat:@"0%@",str];
            [version appendString:str];
        } else {
            [version appendString:str];
        }
    }
    
    return [version intValue];
}

- (NSString *)appVersion {
    return app_version; // ^_^
}

#pragma mark - Accessory

- (BOOL)photoCaptureAccessable {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){// || authStatus == ALAuthorizationStatusNotDetermined) {
        return NO;
    }
    return YES;
}

- (BOOL)photoLibraryAccessable {
    if (floor(NSFoundationVersionNumber) > floor(1047.25)) { // iOS 8+
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if ((status == PHAuthorizationStatusDenied) || (status == PHAuthorizationStatusRestricted)) {
            return NO;
        } else {
            return YES;
        }
    } else {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if ((author == ALAuthorizationStatusDenied) || (author == ALAuthorizationStatusRestricted)) {
            return NO;
        } else {
            return YES;
        }
    }
}

#pragma mark - language

- (NSArray *)languages {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"AppleLanguages"];
}

- (NSString *)currentLanguage{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages firstObject];
    return [NSString stringWithString:currentLanguage];
}

#pragma mark -

- (NSString *)uuid {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    NSString *uuidValue = (__bridge_transfer NSString *)uuidStringRef;
    uuidValue = [uuidValue lowercaseString];
    uuidValue = [uuidValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuidValue;
}

- (NSString *)uuidForSession {
    if( _uuidForSession == nil ){
        _uuidForSession = [self uuid];
    }
    
    return _uuidForSession;
}

- (NSString *)uuidForInstallation {
    if( _uuidForInstallation == nil ){
        _uuidForInstallation = [[NSUserDefaults standardUserDefaults] stringForKey:UUIDForInstallationKey];
        
        if( _uuidForInstallation == nil ){
            _uuidForInstallation = [self uuid];
            
            [[NSUserDefaults standardUserDefaults] setObject:_uuidForInstallation forKey:UUIDForInstallationKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return _uuidForInstallation;
}

- (NSString *)uuidForVendor {
    return [[[[[UIDevice currentDevice] identifierForVendor] UUIDString] lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (NSString *)uuidForDevice {
    //also known as udid/uniqueDeviceIdentifier but this doesn't persists to system reset
    
    return [self uuidForDeviceUsingValue:nil];
}

- (NSString *)uuidForDeviceUsingValue:(NSString *)uuidValue {
    NSString *serviceName = stringify(_System);
    //also known as udid/uniqueDeviceIdentifier but this doesn't persists to system reset
    
    NSString *uuidForDeviceInMemory = _uuidForDevice;
    /*
     //this would overwrite an existing uuid, it could be dangerous
     if( [self uuidValueIsValid:uuidValue] )
     {
     _uuidForDevice = uuidValue;
     }
     */
    if( _uuidForDevice == nil ) {
        _uuidForDevice = [_Keychain passwordForService:serviceName account:UUIDForDeviceKey];
        if( _uuidForDevice == nil ) {
            _uuidForDevice = [[NSUserDefaults standardUserDefaults] stringForKey:UUIDForDeviceKey];
            
            if( _uuidForDevice == nil ) {
                if([self uuidValueIsValid:uuidValue] ) {
                    _uuidForDevice = uuidValue;
                } else {
                    _uuidForDevice = [self uuid];
                }
            }
        }
    }
    
    if([self uuidValueIsValid:uuidValue] && ![_uuidForDevice isEqualToString:uuidValue]) {
        exceptioning(@"Cannot overwrite uuidForDevice, uuidForDevice has already been created and cannot be overwritten.")
    }
    
    if(![uuidForDeviceInMemory isEqualToString:_uuidForDevice])
    {
        [[NSUserDefaults standardUserDefaults] setObject:_uuidForDevice forKey:UUIDForDeviceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [_Keychain setPassword:_uuidForDevice forService:serviceName account:UUIDForDeviceKey];
    }
    
    return _uuidForDevice;
}

- (BOOL)uuidValueIsValid:(NSString *)uuidValue {
    return (uuidValue != nil && (uuidValue.length == 32 || uuidValue.length == 36));
}

- (NSString *)deviceUDID {
    return [self uuidForDevice];
}

/**
 About — prefs:root=General&path=About
 Accessibility — prefs:root=General&path=ACCESSIBILITY
 Airplane Mode On — prefs:root=AIRPLANE_MODE
 Auto-Lock — prefs:root=General&path=AUTOLOCK
 Brightness — prefs:root=Brightness
 Bluetooth — prefs:root=General&path=Bluetooth
 Date & Time — prefs:root=General&path=DATE_AND_TIME
 FaceTime — prefs:root=FACETIME
 General — prefs:root=General
 Keyboard — prefs:root=General&path=Keyboard
 iCloud — prefs:root=CASTLE
 iCloud Storage & Backup — prefs:root=CASTLE&path=STORAGE_AND_BACKUP
 International — prefs:root=General&path=INTERNATIONAL
 Location Services — prefs:root=LOCATION_SERVICES
 Music — prefs:root=MUSIC
 Music Equalizer — prefs:root=MUSIC&path=EQ
 Music Volume Limit — prefs:root=MUSIC&path=VolumeLimit
 Network — prefs:root=General&path=Network
 Nike + iPod — prefs:root=NIKE_PLUS_IPOD
 Notes — prefs:root=NOTES
 Notification — prefs:root=NOTIFICATIONS_ID
 Phone — prefs:root=Phone
 Photos — prefs:root=Photos
 Profile — prefs:root=General&path=ManagedConfigurationList
 Reset — prefs:root=General&path=Reset
 Safari — prefs:root=Safari
 Siri — prefs:root=General&path=Assistant
 Sounds — prefs:root=Sounds
 Software Update — prefs:root=General&path=SOFTWARE_UPDATE_LINK
 Store — prefs:root=STORE
 Twitter — prefs:root=TWITTER
 Usage — prefs:root=General&path=USAGE
 VPN — prefs:root=General&path=Network/VPN
 Wallpaper — prefs:root=Wallpaper
 Wi-Fi — prefs:root=WIFI
 */

- (void)openSettings {
    if (IOS8_OR_LATER) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        NSURL *url = [NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)openWIFI {
    if (IOS8_OR_LATER) {
        //        NSURL *url = [NSURL URLWithString:UIApplicationOpen];
        //        if ([[UIApplication sharedApplication] canOpenURL:url]) {
        //            [[UIApplication sharedApplication] openURL:url];
        //        }
    } else {
        NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (BOOL)call:(NSString *)phone {
    NSString *phoneNumberString = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (phoneNumberString != nil) {
        NSString *urlStr = [[NSString alloc] initWithFormat:@"telprompt://%@", phoneNumberString];
        BOOL isSuccess = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        if (!isSuccess) {
            LOG(@"拨打电话失败:%@", urlStr);
            
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -

+ (NSString*)hardwareString {
    int name[] = {CTL_HW,HW_MACHINE};
    size_t size = 100;
    sysctl(name, 2, NULL, &size, NULL, 0); // getting size of answer
    char *hw_machine = malloc(size);
    
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}

/* This is another way of gtting the system info
 * For this you have to #import <sys/utsname.h>
 */

/*
 NSString* machineName
 {
 struct utsname systemInfo;
 uname(&systemInfo);
 return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
 }
 */

+ (Hardware)hardware {
    NSString *hardware = [self hardwareString];
    if ([hardware isEqualToString:@"iPhone1,1"])    return IPHONE_2G;
    if ([hardware isEqualToString:@"iPhone1,2"])    return IPHONE_3G;
    if ([hardware isEqualToString:@"iPhone2,1"])    return IPHONE_3GS;
    
    if ([hardware isEqualToString:@"iPhone3,1"])    return IPHONE_4;
    if ([hardware isEqualToString:@"iPhone3,2"])    return IPHONE_4;
    if ([hardware isEqualToString:@"iPhone3,3"])    return IPHONE_4_CDMA;
    if ([hardware isEqualToString:@"iPhone4,1"])    return IPHONE_4S;
    
    if ([hardware isEqualToString:@"iPhone5,1"])    return IPHONE_5;
    if ([hardware isEqualToString:@"iPhone5,2"])    return IPHONE_5_CDMA_GSM;
    if ([hardware isEqualToString:@"iPhone5,3"])    return IPHONE_5C;
    if ([hardware isEqualToString:@"iPhone5,4"])    return IPHONE_5C_CDMA_GSM;
    if ([hardware isEqualToString:@"iPhone6,1"])    return IPHONE_5S;
    if ([hardware isEqualToString:@"iPhone6,2"])    return IPHONE_5S_CDMA_GSM;
    
    if ([hardware isEqualToString:@"iPhone7,1"])    return IPHONE_6_PLUS;
    if ([hardware isEqualToString:@"iPhone7,2"])    return IPHONE_6;
    if ([hardware isEqualToString:@"iPhone8,1"])    return IPHONE_6S;
    if ([hardware isEqualToString:@"iPhone8,2"])    return IPHONE_6S_PLUS;
    
    if ([hardware isEqualToString:@"iPhone9,1"])   return HardwareiPhone7;
    if ([hardware isEqualToString:@"iPhone9,2"])   return HardwareiPhone7p;
    
    if ([hardware isEqualToString:@"iPhone10,1"])   return HardwareiPhone8;
    if ([hardware isEqualToString:@"iPhone10,4"])   return HardwareiPhone8;
    if ([hardware isEqualToString:@"iPhone10,2"])   return HardwareiPhone8p;
    if ([hardware isEqualToString:@"iPhone10,5"])   return HardwareiPhone8p;
    
    if ([hardware isEqualToString:@"iPhone10,3"])   return HardwareiPhoneX;
    if ([hardware isEqualToString:@"iPhone10,6"])   return HardwareiPhoneX;
    
    if ([hardware isEqualToString:@"iPod1,1"])      return IPOD_TOUCH_1G;
    if ([hardware isEqualToString:@"iPod2,1"])      return IPOD_TOUCH_2G;
    if ([hardware isEqualToString:@"iPod3,1"])      return IPOD_TOUCH_3G;
    if ([hardware isEqualToString:@"iPod4,1"])      return IPOD_TOUCH_4G;
    if ([hardware isEqualToString:@"iPod5,1"])      return IPOD_TOUCH_5G;
    
    if ([hardware isEqualToString:@"iPad1,1"])      return IPAD;
    if ([hardware isEqualToString:@"iPad1,2"])      return IPAD_3G;
    if ([hardware isEqualToString:@"iPad2,1"])      return IPAD_2_WIFI;
    if ([hardware isEqualToString:@"iPad2,2"])      return IPAD_2;
    if ([hardware isEqualToString:@"iPad2,3"])      return IPAD_2_CDMA;
    if ([hardware isEqualToString:@"iPad2,4"])      return IPAD_2;
    if ([hardware isEqualToString:@"iPad2,5"])      return IPAD_MINI_WIFI;
    if ([hardware isEqualToString:@"iPad2,6"])      return IPAD_MINI;
    if ([hardware isEqualToString:@"iPad2,7"])      return IPAD_MINI_WIFI_CDMA;
    if ([hardware isEqualToString:@"iPad3,1"])      return IPAD_3_WIFI;
    if ([hardware isEqualToString:@"iPad3,2"])      return IPAD_3_WIFI_CDMA;
    if ([hardware isEqualToString:@"iPad3,3"])      return IPAD_3;
    if ([hardware isEqualToString:@"iPad3,4"])      return IPAD_4_WIFI;
    if ([hardware isEqualToString:@"iPad3,5"])      return IPAD_4;
    if ([hardware isEqualToString:@"iPad3,6"])      return IPAD_4_GSM_CDMA;
    if ([hardware isEqualToString:@"iPad4,1"])      return IPAD_AIR_WIFI;
    if ([hardware isEqualToString:@"iPad4,2"])      return IPAD_AIR_WIFI_GSM;
    if ([hardware isEqualToString:@"iPad4,3"])      return IPAD_AIR_WIFI_CDMA;
    if ([hardware isEqualToString:@"iPad4,4"])      return IPAD_MINI_RETINA_WIFI;
    if ([hardware isEqualToString:@"iPad4,5"])      return IPAD_MINI_RETINA_WIFI_CDMA;
    if ([hardware isEqualToString:@"iPad4,6"])      return IPAD_MINI_RETINA_WIFI_CELLULAR_CN;
    if ([hardware isEqualToString:@"iPad4,7"])      return IPAD_MINI_3_WIFI;
    if ([hardware isEqualToString:@"iPad4,8"])      return IPAD_MINI_3_WIFI_CELLULAR;
    if ([hardware isEqualToString:@"iPad5,3"])      return IPAD_AIR_2_WIFI;
    if ([hardware isEqualToString:@"iPad5,4"])      return IPAD_AIR_2_WIFI_CELLULAR;
    
    if ([hardware isEqualToString:@"i386"])         return SIMULATOR;
    if ([hardware isEqualToString:@"x86_64"])       return SIMULATOR;
    if ([hardware hasPrefix:@"iPhone"])             return SIMULATOR;
    if ([hardware hasPrefix:@"iPod"])               return SIMULATOR;
    if ([hardware hasPrefix:@"iPad"])               return SIMULATOR;
    
    //log message that your device is not present in the list
    [self logMessage:hardware];
    
    return NOT_AVAILABLE;
}

+ (NSString*)hardwareDescription {
    NSString *hardware = [self hardwareString];
    if ([hardware isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([hardware isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([hardware isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    
    if ([hardware isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([hardware isEqualToString:@"iPhone3,2"])    return @"iPhone 4 (GSM Rev. A)";
    if ([hardware isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([hardware isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    
    if ([hardware isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([hardware isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (Global)";
    if ([hardware isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([hardware isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (Global)";
    if ([hardware isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([hardware isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (Global)";
    
    if ([hardware isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([hardware isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([hardware isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([hardware isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    if ([hardware isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([hardware isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([hardware isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([hardware isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([hardware isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([hardware isEqualToString:@"iPad1,1"])      return @"iPad (WiFi)";
    if ([hardware isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([hardware isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([hardware isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([hardware isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([hardware isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi Rev. A)";
    if ([hardware isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([hardware isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([hardware isEqualToString:@"iPad2,7"])      return @"iPad Mini (CDMA)";
    if ([hardware isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,2"])      return @"iPad 3 (CDMA)";
    if ([hardware isEqualToString:@"iPad3,3"])      return @"iPad 3 (Global)";
    if ([hardware isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,5"])      return @"iPad 4 (CDMA)";
    if ([hardware isEqualToString:@"iPad3,6"])      return @"iPad 4 (Global)";
    if ([hardware isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([hardware isEqualToString:@"iPad4,2"])      return @"iPad Air (WiFi+GSM)";
    if ([hardware isEqualToString:@"iPad4,3"])      return @"iPad Air (WiFi+CDMA)";
    if ([hardware isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    if ([hardware isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (WiFi+CDMA)";
    if ([hardware isEqualToString:@"iPad4,6"])      return @"iPad Mini Retina (Wi-Fi + Cellular CN)";
    if ([hardware isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (Wi-Fi)";
    if ([hardware isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Wi-Fi + Cellular)";
    if ([hardware isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (Wi-Fi)";
    if ([hardware isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Wi-Fi + Cellular)";
    
    if ([hardware isEqualToString:@"i386"])         return @"Simulator";
    if ([hardware isEqualToString:@"x86_64"])       return @"Simulator";
    if ([hardware hasPrefix:@"iPhone"])             return @"iPhone";
    if ([hardware hasPrefix:@"iPod"])               return @"iPod";
    if ([hardware hasPrefix:@"iPad"])               return @"iPad";
    
    //log message that your device is not present in the list
    [self logMessage:hardware];
    
    return nil;
}

+ (NSString*)hardwareSimpleDescription {
    NSString *hardware = [self hardwareString];
    if ([hardware isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([hardware isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([hardware isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([hardware isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([hardware isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([hardware isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([hardware isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([hardware isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([hardware isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([hardware isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([hardware isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([hardware isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([hardware isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([hardware isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([hardware isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([hardware isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    
    if ([hardware isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([hardware isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([hardware isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([hardware isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    
    if ([hardware isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([hardware isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    
    if ([hardware isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([hardware isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([hardware isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([hardware isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([hardware isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([hardware isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([hardware isEqualToString:@"iPad1,2"])      return @"iPad";
    if ([hardware isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,3"])      return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    if ([hardware isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([hardware isEqualToString:@"iPad2,7"])      return @"iPad Mini";
    if ([hardware isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([hardware isEqualToString:@"iPad3,2"])      return @"iPad 3";
    if ([hardware isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([hardware isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([hardware isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([hardware isEqualToString:@"iPad3,6"])      return @"iPad 4";
    if ([hardware isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([hardware isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([hardware isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([hardware isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina";
    if ([hardware isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina";
    if ([hardware isEqualToString:@"iPad4,6"])      return @"iPad Mini Retina CN";
    if ([hardware isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([hardware isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([hardware isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([hardware isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    if ([hardware isEqualToString:@"i386"])         return @"Simulator";
    if ([hardware isEqualToString:@"x86_64"])       return @"Simulator";
    if ([hardware hasPrefix:@"iPhone"])             return @"iPhone";
    if ([hardware hasPrefix:@"iPod"])               return @"iPod";
    if ([hardware hasPrefix:@"iPad"])               return @"iPad";
    
    //log message that your device is not present in the list
    [self logMessage:hardware];
    
    return nil;
}

+ (float)hardwareNumber:(Hardware)hardware {
    switch (hardware) {
        case IPHONE_2G:                         return 1.1f;
        case IPHONE_3G:                         return 1.2f;
        case IPHONE_3GS:                        return 2.1f;
        case IPHONE_4:                          return 3.1f;
        case IPHONE_4_CDMA:                     return 3.3f;
        case IPHONE_4S:                         return 4.1f;
            
        case IPHONE_5:                          return 5.1f;
        case IPHONE_5_CDMA_GSM:                 return 5.2f;
        case IPHONE_5C:                         return 5.3f;
        case IPHONE_5C_CDMA_GSM:                return 5.4f;
        case IPHONE_5S:                         return 6.1f;
        case IPHONE_5S_CDMA_GSM:                return 6.2f;
            
        case IPHONE_6_PLUS:                     return 7.1f;
        case IPHONE_6:                          return 7.2f;
        case IPHONE_6S:                         return 8.1f;
        case IPHONE_6S_PLUS:                    return 8.2f;
            
        case HardwareiPhone7:                   return 9.1f;
        case HardwareiPhone7p:                  return 9.2f;
        
        case HardwareiPhone8:                   return 10.1f;
        case HardwareiPhone8p:                  return 10.2f;
        
        case HardwareiPhoneX:                   return 10.3f;
            
        case IPOD_TOUCH_1G:                     return 1.1f;
        case IPOD_TOUCH_2G:                     return 2.1f;
        case IPOD_TOUCH_3G:                     return 3.1f;
        case IPOD_TOUCH_4G:                     return 4.1f;
        case IPOD_TOUCH_5G:                     return 5.1f;
            
        case IPAD:                              return 1.1f;
        case IPAD_3G:                           return 1.2f;
        case IPAD_2_WIFI:                       return 2.1f;
        case IPAD_2:                            return 2.2f;
        case IPAD_2_CDMA:                       return 2.3f;
        case IPAD_MINI_WIFI:                    return 2.5f;
        case IPAD_MINI:                         return 2.6f;
        case IPAD_MINI_WIFI_CDMA:               return 2.7f;
        case IPAD_3_WIFI:                       return 3.1f;
        case IPAD_3_WIFI_CDMA:                  return 3.2f;
        case IPAD_3:                            return 3.3f;
        case IPAD_4_WIFI:                       return 3.4f;
        case IPAD_4:                            return 3.5f;
        case IPAD_4_GSM_CDMA:                   return 3.6f;
            
        case IPAD_AIR_WIFI:                     return 4.1f;
        case IPAD_AIR_WIFI_GSM:                 return 4.2f;
        case IPAD_AIR_WIFI_CDMA:                return 4.3f;
        case IPAD_AIR_2_WIFI:                   return 5.3f;
        case IPAD_AIR_2_WIFI_CELLULAR:          return 5.4f;
            
        case IPAD_MINI_RETINA_WIFI:             return 4.4f;
        case IPAD_MINI_RETINA_WIFI_CDMA:        return 4.5f;
        case IPAD_MINI_3_WIFI:                  return 4.6f;
        case IPAD_MINI_3_WIFI_CELLULAR:         return 4.7f;
        case IPAD_MINI_RETINA_WIFI_CELLULAR_CN: return 4.8f;
            
            
        case SIMULATOR:                         return 100.0f;
        case NOT_AVAILABLE:                     return 200.0f;
    }
    return 200.0f; //Device is not available
}

+ (CGSize)backCameraStillImageResolutionInPixels {
    switch ([self hardware]) {
        case IPHONE_2G:
        case IPHONE_3G:
            return CGSizeMake(1600, 1200);
            break;
        case IPHONE_3GS:
            return CGSizeMake(2048, 1536);
            break;
        case IPHONE_4:
        case IPHONE_4_CDMA:
        case IPAD_3_WIFI:
        case IPAD_3_WIFI_CDMA:
        case IPAD_3:
        case IPAD_4_WIFI:
        case IPAD_4:
        case IPAD_4_GSM_CDMA:
            return CGSizeMake(2592, 1936);
            break;
        case IPHONE_4S:
        case IPHONE_5:
        case IPHONE_5_CDMA_GSM:
        case IPHONE_5C:
        case IPHONE_5C_CDMA_GSM:
        case IPHONE_6:
        case IPHONE_6_PLUS:
            return CGSizeMake(3264, 2448);
            break;
            
        case IPOD_TOUCH_4G:
            return CGSizeMake(960, 720);
            break;
        case IPOD_TOUCH_5G:
            return CGSizeMake(2440, 1605);
            break;
            
        case IPAD_2_WIFI:
        case IPAD_2:
        case IPAD_2_CDMA:
            return CGSizeMake(872, 720);
            break;
            
        case IPAD_MINI_WIFI:
        case IPAD_MINI:
        case IPAD_MINI_WIFI_CDMA:
            return CGSizeMake(1820, 1304);
            break;
            
        case IPAD_AIR_2_WIFI:
        case IPAD_AIR_2_WIFI_CELLULAR:
            return CGSizeMake (1536, 2048);
            break;
            
        default:
            NSLog(@"We have no resolution for your device's camera listed in this category. Please, make photo with back camera of your device, get its resolution in pixels (via Preview Cmd+I for example) and add a comment to this repository (https://github.com/InderKumarRathore/UIDeviceUtil) on GitHub.com in format Device = Hpx x Wpx.");
            NSLog(@"Your device is: %@", [self hardwareDescription]);
            break;
    }
    return CGSizeZero;
}

+ (void)logMessage:(NSString *)hardware {
    NSLog(@"This is a device which is not listed in this category. Please visit https://github.com/InderKumarRathore/UIDeviceUtil and add a comment there.");
    NSLog(@"Your device hardware string is: %@", hardware);
}


+ (void)adaptPhone4s:(Block)phone4sBlock phone5s:(Block)phone5sBlock phone6:(Block)phone6Block phone6p:(Block)phone6pBlock {
    
    if ([self hardware]==IPHONE_4 ||
        [self hardware]==IPHONE_4_CDMA ||
        [self hardware]==IPHONE_4S) {
        
        if (phone4sBlock) {
            phone4sBlock();
        }
        
    } else if ([self hardware]==IPHONE_5 ||
               [self hardware]==IPHONE_5_CDMA_GSM ||
               [self hardware]==IPHONE_5C||
               [self hardware]==IPHONE_5C_CDMA_GSM||
               [self hardware]==IPHONE_5S||
               [self hardware]==IPHONE_5S_CDMA_GSM) {
        
        if (phone5sBlock) {
            phone5sBlock();
        }
        
    } else if ([self hardware]==IPHONE_6 ||
               [self hardware] == IPHONE_6S) {
        
        if (phone6Block) {
            phone6Block();
        }
        
    } else if ([self hardware]==IPHONE_6_PLUS ||
               [self hardware] == IPHONE_6S_PLUS) {
        if (phone6pBlock) {
            phone6pBlock();
        }
    }
}

+ (void)adapterPad1024:(Block)pad1024Block pad2048:(Block)pad2048Block {
    NSUInteger hardwareDevice = [self hardware];
    
    switch (hardwareDevice) {
        case IPAD_MINI:
        case IPAD_MINI_WIFI:
        case IPAD_MINI_3_WIFI:
        case IPAD_MINI_WIFI_CDMA:
        case IPAD_MINI_3_WIFI_CELLULAR:
            
        case IPAD:
        case IPAD_2:
        case IPAD_2_CDMA:
        case IPAD_2_WIFI: {
            if (pad1024Block) {
                pad1024Block();
            }
        }
            break;
            
        case IPAD_MINI_RETINA_WIFI:
        case IPAD_MINI_RETINA_WIFI_CDMA:
        case IPAD_MINI_RETINA_WIFI_CELLULAR_CN:
            
        case IPAD_3_WIFI_CDMA:
        case IPAD_3G:
        case IPAD_3_WIFI:
        case IPAD_4:
        case IPAD_4_GSM_CDMA:
        case IPAD_4_WIFI:
        case IPAD_AIR_2_WIFI:
        case IPAD_AIR_2_WIFI_CELLULAR:
        case IPAD_AIR_WIFI:
        case IPAD_AIR_WIFI_CDMA:
        case IPAD_AIR_WIFI_GSM:
        case IPAD_3: {
            if (pad2048Block) {
                pad2048Block();
            }
        }
            break;
            
        default: {
            if (pad2048Block) {
                pad2048Block();
            }
        }
            break;
    }
}

@end
