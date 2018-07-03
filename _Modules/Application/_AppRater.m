//
//  AppRater.m
//  consumer
//
//  Created by fallen.ink on 18/10/2016.
//
//

#import "_app_rater.h"

#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
#pragma clang diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
#pragma clang diagnostic ignored "-Wpartial-availability"
#pragma clang diagnostic ignored "-Wunused-macros"
#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wformat-nonliteral"
#pragma clang diagnostic ignored "-Wdouble-promotion"
#pragma clang diagnostic ignored "-Wselector"
#pragma clang diagnostic ignored "-Wgnu"


NSUInteger const _AppRaterAppStoreGameGenreID = 6014;
NSString *const _AppRaterErrorDomain = @"_AppRaterErrorDomain";


NSString *const _AppRaterMessageTitleKey = @"_AppRaterMessageTitle";
NSString *const _AppRaterAppMessageKey = @"_AppRaterAppMessage";
NSString *const _AppRaterGameMessageKey = @"_AppRaterGameMessage";
NSString *const _AppRaterUpdateMessageKey = @"_AppRaterUpdateMessage";
NSString *const _AppRaterCancelButtonKey = @"_AppRaterCancelButton";
NSString *const _AppRaterRemindButtonKey = @"_AppRaterRemindButton";
NSString *const _AppRaterRateButtonKey = @"_AppRaterRateButton";

NSString *const _AppRaterCouldNotConnectToAppStore = @"_AppRaterCouldNotConnectToAppStore";
NSString *const _AppRaterDidDetectAppUpdate = @"_AppRaterDidDetectAppUpdate";
NSString *const _AppRaterDidPromptForRating = @"_AppRaterDidPromptForRating";
NSString *const _AppRaterUserDidAttemptToRateApp = @"_AppRaterUserDidAttemptToRateApp";
NSString *const _AppRaterUserDidDeclineToRateApp = @"_AppRaterUserDidDeclineToRateApp";
NSString *const _AppRaterUserDidRequestReminderToRateApp = @"_AppRaterUserDidRequestReminderToRateApp";
NSString *const _AppRaterDidOpenAppStore = @"_AppRaterDidOpenAppStore";

static NSString *const _AppRaterAppStoreIDKey = @"_AppRaterAppStoreID";
static NSString *const _AppRaterRatedVersionKey = @"_AppRaterRatedVersionChecked";
static NSString *const _AppRaterDeclinedVersionKey = @"_AppRaterDeclinedVersion";
static NSString *const _AppRaterLastRemindedKey = @"_AppRaterLastReminded";
static NSString *const _AppRaterLastVersionUsedKey = @"_AppRaterLastVersionUsed";
static NSString *const _AppRaterFirstUsedKey = @"_AppRaterFirstUsed";
static NSString *const _AppRaterUseCountKey = @"_AppRaterUseCount";
static NSString *const _AppRaterEventCountKey = @"_AppRaterEventCount";

static NSString *const _AppRaterMacAppStoreBundleID = @"com.apple.appstore";
static NSString *const _AppRaterAppLookupURLFormat = @"https://itunes.apple.com/%@/lookup";

static NSString *const _AppRateriOSAppStoreURLScheme = @"itms-apps";
static NSString *const _AppRateriOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&pageNumber=0&sortOrdering=2&mt=8";
static NSString *const _AppRateriOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@";
static NSString *const _AppRaterMacAppStoreURLFormat = @"macappstore://itunes.apple.com/app/id%@";


#define IOS_7_0 7.0
#define IOS_7_1 7.1


#define SECONDS_IN_A_DAY 86400.0
#define SECONDS_IN_A_WEEK 604800.0
#define MAC_APP_STORE_REFRESH_DELAY 5.0
#define REQUEST_TIMEOUT 60.0


@interface _AppRater ()

@property (nonatomic, strong) id visibleAlert;
@property (nonatomic, assign) BOOL checkingForPrompt;
@property (nonatomic, assign) BOOL checkingForAppStoreID;

@end


@implementation _AppRater

@def_singleton(_AppRater)

- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString {
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:__FILENAME__ ofType:@"bundle"];
        if (self.useAllAvailableLanguages)
        {
            bundle = [NSBundle bundleWithPath:bundlePath];
            NSString *language = [[NSLocale preferredLanguages] count]? [NSLocale preferredLanguages][0]: @"en";
            
            NSLog(@"localizations = %@", [bundle localizations]);
            /**
              * 系统语言编码：
             
              * 英文：en-CN
              * 简体中文：zh-Hans-CN
              * 繁体中文：zh-Hant-CN
              * 繁体中文-香港：zh-Hant-HK
              * 繁体中文-台湾：zh-Hant-TW
              * 繁体中文-澳门：zh-Hant-MO
             
              * 中文处理：
             
              * 简体：zh-Hans-CN
              * 繁体：zh
              */
            
            if (![[bundle localizations] containsObject:language])
            {
                language = [language componentsSeparatedByString:@"-"][0];
            }
            if ([[bundle localizations] containsObject:language])
            {
                bundlePath = [bundle pathForResource:language ofType:@"lproj"];
            }
        }
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

- (_AppRater *)init {
    if ((self = [super init])) {
        
#if TARGET_OS_IPHONE
        
        //register for iphone application events
        if (&UIApplicationWillEnterForegroundNotification) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationWillEnterForeground)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
        }
        
#endif
        
        //get country
        self.appStoreCountry = [(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        if ([self.appStoreCountry isEqualToString:@"150"]) {
            self.appStoreCountry = @"eu";
        } else if (!self.appStoreCountry || [[self.appStoreCountry stringByReplacingOccurrencesOfString:@"[A-Za-z]{2}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, 2)] length]) {
            self.appStoreCountry = @"us";
        } else if ([self.appStoreCountry isEqualToString:@"GI"]) {
            self.appStoreCountry = @"GB";
        }
        
        //application version (use short version preferentially)
        self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if ([self.applicationVersion length] == 0) {
            self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleVersionKey];
        }
        
        //localised application name
        self.applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if ([self.applicationName length] == 0) {
            self.applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
        }
        
        //bundle id
        self.applicationBundleID = [[NSBundle mainBundle] bundleIdentifier];
        
        //default settings
        self.useAllAvailableLanguages = YES;
        self.promptForNewVersionIfUserRated = NO;
        self.onlyPromptIfLatestVersion = YES;
        self.onlyPromptIfMainWindowIsAvailable = YES;
        self.promptAtLaunch = YES;
        self.usesUntilPrompt = 10;
        self.eventsUntilPrompt = 10;
        self.daysUntilPrompt = 10.0;
        self.usesPerWeekForPrompt = 0.0;
        self.remindPeriod = 1.0;
        self.verboseLogging = NO;
        self.previewMode = NO;
        
#if DEBUG
        
        //enable verbose logging in debug mode
        self.verboseLogging = YES;
        NSLog(@"_AppRater verbose logging enabled.");
        
#endif
        
        //app launched
        dispatch_async(dispatch_get_main_queue(), ^{
            [self applicationLaunched];
        });
    }
    return self;
}

- (id<_AppRaterDelegate>)delegate
{
    if (_delegate == nil)
    {
        
#if TARGET_OS_IPHONE
#define APP_CLASS UIApplication
#else
#define APP_CLASS NSApplication
#endif
        
        _delegate = (id<_AppRaterDelegate>)[(APP_CLASS *)[APP_CLASS sharedApplication] delegate];
    }
    return _delegate;
}

- (NSString *)messageTitle {
    return [_messageTitle ?: [self localizedStringForKey:_AppRaterMessageTitleKey withDefault:@"Rate %@"] stringByReplacingOccurrencesOfString:@"%@" withString:self.applicationName];
}

- (NSString *)message {
    NSString *message = _message;
    if (!message)
    {
        message = (self.appStoreGenreID == _AppRaterAppStoreGameGenreID)? [self localizedStringForKey:_AppRaterGameMessageKey withDefault:@"If you enjoy playing %@, would you mind taking a moment to rate it? It won’t take more than a minute. Thanks for your support!"]: [self localizedStringForKey:_AppRaterAppMessageKey withDefault:@"If you enjoy using %@, would you mind taking a moment to rate it? It won’t take more than a minute. Thanks for your support!"];
    }
    return [message stringByReplacingOccurrencesOfString:@"%@" withString:self.applicationName];
}

- (NSString *)updateMessage
{
    NSString *updateMessage = _updateMessage;
    if (!updateMessage)
    {
        updateMessage = [self localizedStringForKey:_AppRaterUpdateMessageKey withDefault:self.message];
    }
    return [updateMessage stringByReplacingOccurrencesOfString:@"%@" withString:self.applicationName];
}

- (NSString *)cancelButtonLabel
{
    return _cancelButtonLabel ?: [self localizedStringForKey:_AppRaterCancelButtonKey withDefault:@"No, Thanks"];
}

- (NSString *)rateButtonLabel
{
    return _rateButtonLabel ?: [self localizedStringForKey:_AppRaterRateButtonKey withDefault:@"Rate It Now"];
}

- (NSString *)remindButtonLabel
{
    return _remindButtonLabel ?: [self localizedStringForKey:_AppRaterRemindButtonKey withDefault:@"Remind Me Later"];
}

- (NSURL *)ratingsURL
{
    if (_ratingsURL)
    {
        return _ratingsURL;
    }
    
    if (!self.appStoreID && self.verboseLogging)
    {
        NSLog(@"_AppRater could not find the App Store ID for this application. If the application is not intended for App Store release then you must specify a custom ratingsURL.");
    }
    
    NSString *URLString;
    
#if TARGET_OS_IPHONE
    
    float iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (iOSVersion >= IOS_7_0 && iOSVersion < IOS_7_1)
    {
        URLString = _AppRateriOS7AppStoreURLFormat;
    }
    else
    {
        URLString = _AppRateriOSAppStoreURLFormat;
    }
    
#else
    
    URLString = _AppRaterMacAppStoreURLFormat;
    
#endif
    
    return [NSURL URLWithString:[NSString stringWithFormat:URLString, @(self.appStoreID)]];
    
}

- (NSUInteger)appStoreID
{
    return _appStoreID ?: [[[NSUserDefaults standardUserDefaults] objectForKey:_AppRaterAppStoreIDKey] unsignedIntegerValue];
}

- (NSDate *)firstUsed
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_AppRaterFirstUsedKey];
}

- (void)setFirstUsed:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:_AppRaterFirstUsedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)lastReminded
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_AppRaterLastRemindedKey];
}

- (void)setLastReminded:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:_AppRaterLastRemindedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)usesCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:_AppRaterUseCountKey];
}

- (void)setUsesCount:(NSUInteger)count
{
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)count forKey:_AppRaterUseCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)eventCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:_AppRaterEventCountKey];
}

- (void)setEventCount:(NSUInteger)count
{
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)count forKey:_AppRaterEventCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)usesPerWeek
{
    return (float)self.usesCount / ([[NSDate date] timeIntervalSinceDate:self.firstUsed] / SECONDS_IN_A_WEEK);
}

- (BOOL)declinedThisVersion
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:_AppRaterDeclinedVersionKey] isEqualToString:self.applicationVersion];
}

- (void)setDeclinedThisVersion:(BOOL)declined
{
    [[NSUserDefaults standardUserDefaults] setObject:(declined? self.applicationVersion: nil) forKey:_AppRaterDeclinedVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)declinedAnyVersion
{
    return [(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:_AppRaterDeclinedVersionKey] length] != 0;
}

- (BOOL)ratedVersion:(NSString *)version
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:_AppRaterRatedVersionKey] isEqualToString:version];
}

- (BOOL)ratedThisVersion
{
    return [self ratedVersion:self.applicationVersion];
}

- (void)setRatedThisVersion:(BOOL)rated
{
    [[NSUserDefaults standardUserDefaults] setObject:(rated? self.applicationVersion: nil) forKey:_AppRaterRatedVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)ratedAnyVersion
{
    return [(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:_AppRaterRatedVersionKey] length] != 0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)incrementUseCount
{
    self.usesCount ++;
}

- (void)incrementEventCount
{
    self.eventCount ++;
}

- (BOOL)shouldPromptForRating
{
    //preview mode?
    if (self.previewMode)
    {
        NSLog(@"_AppRater preview mode is enabled - make sure you disable this for release");
        return YES;
    }
    
    //check if we've rated this version
    else if (self.ratedThisVersion)
    {
        if (self.verboseLogging)
        {
            NSLog(@"_AppRater did not prompt for rating because the user has already rated this version");
        }
        return NO;
    }
    
    //check if we've rated any version
    else if (self.ratedAnyVersion && !self.promptForNewVersionIfUserRated)
    {
        if (self.verboseLogging)
        {
            NSLog(@"_AppRater did not prompt for rating because the user has already rated this app, and promptForNewVersionIfUserRated is disabled");
        }
        return NO;
    }
    
    //check if we've declined to rate the app
    else if (self.declinedAnyVersion)
    {
        if (self.verboseLogging)
        {
            NSLog(@"_AppRater did not prompt for rating because the user has declined to rate the app");
        }
        return NO;
    }
    
    //check how long we've been using this version
    else if ([[NSDate date] timeIntervalSinceDate:self.firstUsed] < self.daysUntilPrompt * SECONDS_IN_A_DAY)
    {
        if (self.verboseLogging)
        {
            NSLog(@"_AppRater did not prompt for rating because the app was first used less than %g days ago", self.daysUntilPrompt);
        }
        return NO;
    }
    
    //check how many times we've used it and the number of significant events
    else if (self.usesCount < self.usesUntilPrompt && self.eventCount < self.eventsUntilPrompt)
    {
        if (self.verboseLogging)
        {
            NSLog(@"_AppRater did not prompt for rating because the app has only been used %@ times and only %@ events have been logged", @(self.usesCount), @(self.eventCount));
        }
        return NO;
    }
    
    //check if usage frequency is high enough
    else if (self.usesPerWeek < self.usesPerWeekForPrompt)
    {
        if (self.verboseLogging)
        {
            NSLog(@"_AppRater did not prompt for rating because the app has only been used %g times per week on average since it was installed", self.usesPerWeek);
        }
        return NO;
    }
    
    //check if within the reminder period
    else if (self.lastReminded != nil && [[NSDate date] timeIntervalSinceDate:self.lastReminded] < self.remindPeriod * SECONDS_IN_A_DAY)
    {
        if (self.verboseLogging)
        {
            NSLog(@"_AppRater did not prompt for rating because the user last asked to be reminded less than %g days ago", self.remindPeriod);
        }
        return NO;
    }
    
    //lets prompt!
    return YES;
}

- (NSString *)valueForKey:(NSString *)key inJSON:(id)json
{
    if ([json isKindOfClass:[NSString class]])
    {
        //use legacy parser
        NSRange keyRange = [json rangeOfString:[NSString stringWithFormat:@"\"%@\"", key]];
        if (keyRange.location != NSNotFound)
        {
            NSInteger start = keyRange.location + keyRange.length;
            NSRange valueStart = [json rangeOfString:@":" options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
            if (valueStart.location != NSNotFound)
            {
                start = valueStart.location + 1;
                NSRange valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
                if (valueEnd.location != NSNotFound)
                {
                    NSString *value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    while ([value hasPrefix:@"\""] && ![value hasSuffix:@"\""])
                    {
                        if (valueEnd.location == NSNotFound)
                        {
                            break;
                        }
                        NSInteger newStart = valueEnd.location + 1;
                        valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(newStart, [(NSString *)json length] - newStart)];
                        value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    }
                    
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                    value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\f" withString:@"\f"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\b" withString:@"\f"];
                    
                    while (YES)
                    {
                        NSRange unicode = [value rangeOfString:@"\\u"];
                        if (unicode.location == NSNotFound || unicode.location + unicode.length == 0)
                        {
                            break;
                        }
                        
                        uint32_t c = 0;
                        NSString *hex = [value substringWithRange:NSMakeRange(unicode.location + 2, 4)];
                        NSScanner *scanner = [NSScanner scannerWithString:hex];
                        [scanner scanHexInt:&c];
                        
                        if (c <= 0xffff)
                        {
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C", (unichar)c]];
                        }
                        else
                        {
                            //convert character to surrogate pair
                            uint16_t x = (uint16_t)c;
                            uint16_t u = (c >> 16) & ((1 << 5) - 1);
                            uint16_t w = (uint16_t)u - 1;
                            unichar high = 0xd800 | (w << 6) | x >> 10;
                            unichar low = (uint16_t)(0xdc00 | (x & ((1 << 10) - 1)));
                            
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C%C", high, low]];
                        }
                    }
                    return value;
                }
            }
        }
    }
    else
    {
        return json[key];
    }
    return nil;
}

- (void)setAppStoreIDOnMainThread:(NSString *)appStoreIDString
{
    _appStoreID = [appStoreIDString integerValue];
    [[NSUserDefaults standardUserDefaults] setInteger:_appStoreID forKey:_AppRaterAppStoreIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)connectionSucceeded
{
    if (self.checkingForAppStoreID)
    {
        //no longer checking
        self.checkingForPrompt = NO;
        self.checkingForAppStoreID = NO;
        
        //open app store
        [self openRatingsPageInAppStore];
    }
    else if (self.checkingForPrompt)
    {
        //no longer checking
        self.checkingForPrompt = NO;
        
        //confirm with delegate
        if ([self.delegate respondsToSelector:@selector(whenShouldPromptForRating)] && ![self.delegate whenShouldPromptForRating])
        {
            if (self.verboseLogging)
            {
                NSLog(@"_AppRater did not display the rating prompt because the _AppRaterShouldPromptForRating delegate method returned NO");
            }
            return;
        }
        
        //prompt user
        [self promptForRating];
    }
}

- (void)connectionError:(NSError *)error
{
    if (self.checkingForPrompt || self.checkingForAppStoreID)
    {
        //no longer checking
        self.checkingForPrompt = NO;
        self.checkingForAppStoreID = NO;
        
        //log the error
        if (error)
        {
            NSLog(@"_AppRater rating process failed because: %@", [error localizedDescription]);
        }
        else
        {
            NSLog(@"_AppRater rating process failed because an unknown error occured");
        }
        
        //could not connect
        if ([self.delegate respondsToSelector:@selector(whenCouldNotConnectToAppStore:)])
        {
            [self.delegate whenCouldNotConnectToAppStore:error];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:_AppRaterCouldNotConnectToAppStore
                                                            object:error];
    }
}

- (void)checkForConnectivityInBackground
{
    
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0) \
|| (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_10)
#define IRATE_BACKGROUND_QUEUE QOS_CLASS_BACKGROUND
#else
#define IRATE_BACKGROUND_QUEUE DISPATCH_QUEUE_PRIORITY_BACKGROUND
#endif
    
    dispatch_async(dispatch_get_global_queue(IRATE_BACKGROUND_QUEUE, 0), ^{
        [self checkForConnectivity];
    });
}

- (void)checkForConnectivity
{
    @autoreleasepool
    {
        //first check iTunes
        NSString *iTunesServiceURL = [NSString stringWithFormat:_AppRaterAppLookupURLFormat, self.appStoreCountry];
        if (_appStoreID) //important that we check ivar and not getter in case it has changed
        {
            iTunesServiceURL = [iTunesServiceURL stringByAppendingFormat:@"?id=%@", @(_appStoreID)];
        }
        else
        {
            iTunesServiceURL = [iTunesServiceURL stringByAppendingFormat:@"?bundleId=%@", self.applicationBundleID];
        }
        
        if (self.verboseLogging)
        {
            NSLog(@"_AppRater is checking %@ to retrieve the App Store details...", iTunesServiceURL);
        }
        
        NSError *error = nil;
        NSURLResponse *response = nil;
        NSURL *url = [NSURL URLWithString:iTunesServiceURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIMEOUT];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
#pragma clang diagnostic pop
        
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (data && statusCode == 200)
        {
            //in case error is garbage...
            error = nil;
            
            id json = nil;
            if ([NSJSONSerialization class])
            {
                json = [[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&error][@"results"] lastObject];
            }
            else
            {
                //convert to string
                json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            
            if (!error)
            {
                //check bundle ID matches
                NSString *bundleID = [self valueForKey:@"bundleId" inJSON:json];
                if (bundleID)
                {
                    if ([bundleID isEqualToString:self.applicationBundleID])
                    {
                        //get genre
                        if (self.appStoreGenreID == 0)
                        {
                            self.appStoreGenreID = [[self valueForKey:@"primaryGenreId" inJSON:json] integerValue];
                        }
                        
                        //get app id
                        if (!_appStoreID)
                        {
                            NSString *appStoreIDString = [self valueForKey:@"trackId" inJSON:json];
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self setAppStoreIDOnMainThread:appStoreIDString];
                            });
                            
                            if (self.verboseLogging)
                            {
                                NSLog(@"_AppRater found the app on iTunes. The App Store ID is %@", appStoreIDString);
                            }
                        }
                        
                        //check version
                        if (self.onlyPromptIfLatestVersion && !self.previewMode)
                        {
                            NSString *latestVersion = [self valueForKey:@"version" inJSON:json];
                            if ([latestVersion compare:self.applicationVersion options:NSNumericSearch] == NSOrderedDescending)
                            {
                                if (self.verboseLogging)
                                {
                                    NSLog(@"_AppRater found that the installed application version (%@) is not the latest version on the App Store, which is %@", self.applicationVersion, latestVersion);
                                }
                                
                                error = [NSError errorWithDomain:_AppRaterErrorDomain code:_AppRaterErrorApplicationIsNotLatestVersion userInfo:@{NSLocalizedDescriptionKey: @"Installed app is not the latest version available"}];
                            }
                        }
                    }
                    else
                    {
                        if (self.verboseLogging)
                        {
                            NSLog(@"_AppRater found that the application bundle ID (%@) does not match the bundle ID of the app found on iTunes (%@) with the specified App Store ID (%@)", self.applicationBundleID, bundleID, @(self.appStoreID));
                        }
                        
                        error = [NSError errorWithDomain:_AppRaterErrorDomain code:_AppRaterErrorBundleIdDoesNotMatchAppStore userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Application bundle ID does not match expected value of %@", bundleID]}];
                    }
                }
                else if (_appStoreID || !self.ratingsURL)
                {
                    if (self.verboseLogging)
                    {
                        NSLog(@"_AppRater could not find this application on iTunes. If your app is not intended for App Store release then you must specify a custom ratingsURL. If this is the first release of your application then it's not a problem that it cannot be found on the store yet");
                    }
                    if (!self.previewMode)
                    {
                        error = [NSError errorWithDomain:_AppRaterErrorDomain
                                                    code:_AppRaterErrorApplicationNotFoundOnAppStore
                                                userInfo:@{NSLocalizedDescriptionKey: @"The application could not be found on the App Store."}];
                    }
                }
                else if (!_appStoreID && self.verboseLogging)
                {
                    NSLog(@"_AppRater could not find your app on iTunes. If your app is not yet on the store or is not intended for App Store release then don't worry about this");
                }
            }
        }
        else if (statusCode >= 400)
        {
            //http error
            NSString *message = [NSString stringWithFormat:@"The server returned a %@ error", @(statusCode)];
            error = [NSError errorWithDomain:@"HTTPResponseErrorDomain" code:statusCode userInfo:@{NSLocalizedDescriptionKey: message}];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //handle errors (ignoring sandbox issues)
            if (error && !(error.code == EPERM && [error.domain isEqualToString:NSPOSIXErrorDomain] && self->_appStoreID))
            {
                [self connectionError:error];
            }
            else if (self.appStoreID || self.previewMode)
            {
                //show prompt
                [self connectionSucceeded];
            }
        });
    }
}

- (void)promptIfNetworkAvailable
{
    if (!self.checkingForPrompt && !self.checkingForAppStoreID)
    {
        self.checkingForPrompt = YES;
        [self checkForConnectivityInBackground];
    }
}

- (void)promptIfAllCriteriaMet
{
    if ([self shouldPromptForRating])
    {
        [self promptIfNetworkAvailable];
    }
}

- (BOOL)showRemindButton
{
    return [self.remindButtonLabel length];
}

- (BOOL)showCancelButton
{
    return [self.cancelButtonLabel length];
}

- (void)promptForRating
{
    if (!self.visibleAlert)
    {
        NSString *message = self.ratedAnyVersion? self.updateMessage: self.message;
        
#if TARGET_OS_IPHONE
        
        UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
        while (topController.presentedViewController)
        {
            topController = topController.presentedViewController;
        }
        
        if ([UIAlertController class] && topController && self.useUIAlertControllerIfAvailable)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.messageTitle message:message preferredStyle:UIAlertControllerStyleAlert];
            
            //rate action
            [alert addAction:[UIAlertAction actionWithTitle:self.rateButtonLabel style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                [self didDismissAlert:alert withButtonAtIndex:0];
            }]];
            
            //cancel action
            if ([self showCancelButton])
            {
                [alert addAction:[UIAlertAction actionWithTitle:self.cancelButtonLabel style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action) {
                    [self didDismissAlert:alert withButtonAtIndex:1];
                }]];
            }
            
            //remind action
            if ([self showRemindButton])
            {
                [alert addAction:[UIAlertAction actionWithTitle:self.remindButtonLabel style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                    [self didDismissAlert:alert withButtonAtIndex:[self showCancelButton]? 2: 1];
                }]];
            }
            
            self.visibleAlert = alert;
            
            //get current view controller and present alert
            [topController presentViewController:alert animated:YES completion:NULL];
        }
        else
        {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.messageTitle
                                                            message:message
                                                           delegate:(id<UIAlertViewDelegate>)self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:self.rateButtonLabel, nil];
#pragma clang diagnostic pop
            
            if ([self showCancelButton])
            {
                [alert addButtonWithTitle:self.cancelButtonLabel];
                alert.cancelButtonIndex = 1;
            }
            
            if ([self showRemindButton])
            {
                [alert addButtonWithTitle:self.remindButtonLabel];
            }
            
            self.visibleAlert = alert;
            [self.visibleAlert show];
        }
        
#else
        
        //only show when main window is available
        if (self.onlyPromptIfMainWindowIsAvailable && ![[NSApplication sharedApplication] mainWindow])
        {
            [self performSelector:@selector(promptForRating) withObject:nil afterDelay:0.5];
            return;
        }
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = self.messageTitle;
        alert.informativeText = message;
        [alert addButtonWithTitle:self.rateButtonLabel];
        if ([self showCancelButton])
        {
            [alert addButtonWithTitle:self.cancelButtonLabel];
        }
        if ([self showRemindButton])
        {
            [alert addButtonWithTitle:self.remindButtonLabel];
        }
        
        self.visibleAlert = alert;
        
#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9
        
        if (![alert respondsToSelector:@selector(beginSheetModalForWindow:completionHandler:)])
        {
            [alert beginSheetModalForWindow:(__nonnull id)[NSApplication sharedApplication].mainWindow
                              modalDelegate:self
                             didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                contextInfo:nil];
        }
        else
            
#endif
            
        {
            [alert beginSheetModalForWindow:(__nonnull id)[NSApplication sharedApplication].mainWindow completionHandler:^(NSModalResponse returnCode) {
                [self didDismissAlert:alert withButtonAtIndex:returnCode - NSAlertFirstButtonReturn];
            }];
        }
        
#endif
        
        //inform about prompt
        if ([self.delegate respondsToSelector:@selector(whenDidPromptForRating)])
        {
            [self.delegate whenDidPromptForRating];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:_AppRaterDidPromptForRating
                                                            object:nil];
    }
}

- (void)applicationLaunched
{
    //check if this is a new version
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUsedVersion = [defaults objectForKey:_AppRaterLastVersionUsedKey];
    if (!self.firstUsed || ![lastUsedVersion isEqualToString:self.applicationVersion])
    {
        [defaults setObject:self.applicationVersion forKey:_AppRaterLastVersionUsedKey];
        if (!self.firstUsed || [self ratedAnyVersion])
        {
            //reset defaults
            [defaults setObject:[NSDate date] forKey:_AppRaterFirstUsedKey];
            [defaults setInteger:0 forKey:_AppRaterUseCountKey];
            [defaults setInteger:0 forKey:_AppRaterEventCountKey];
            [defaults setObject:nil forKey:_AppRaterLastRemindedKey];
            [defaults synchronize];
        }
        else if ([[NSDate date] timeIntervalSinceDate:self.firstUsed] > (self.daysUntilPrompt - 1) * SECONDS_IN_A_DAY)
        {
            //if was previously installed, but we haven't yet prompted for a rating
            //don't reset, but make sure it won't rate for a day at least
            self.firstUsed = [[NSDate date] dateByAddingTimeInterval:(self.daysUntilPrompt - 1) * -SECONDS_IN_A_DAY];
        }
        
        //inform about app update
        if ([self.delegate respondsToSelector:@selector(whenDidDetectAppUpdate)])
        {
            [self.delegate whenDidDetectAppUpdate];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:_AppRaterDidDetectAppUpdate
                                                            object:nil];
    }
    
    [self incrementUseCount];
    [self checkForConnectivityInBackground];
    if (self.promptAtLaunch)
    {
        [self promptIfAllCriteriaMet];
    }
}

- (void)didDismissAlert:(__unused id)alertView withButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //get button indices
        NSInteger rateButtonIndex = 0;
        NSInteger cancelButtonIndex = [self showCancelButton]? 1: 0;
        NSInteger remindButtonIndex = [self showRemindButton]? cancelButtonIndex + 1: 0;
        
        if (buttonIndex == rateButtonIndex)
        {
            [self rate];
        }
        else if (buttonIndex == cancelButtonIndex)
        {
            [self declineThisVersion];
        }
        else if (buttonIndex == remindButtonIndex)
        {
            [self remindLater];
        }
        
        //release alert
        self.visibleAlert = nil;
    });
}

#if TARGET_OS_IPHONE

- (void)applicationWillEnterForeground
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        [self incrementUseCount];
        [self checkForConnectivityInBackground];
        if (self.promptAtLaunch)
        {
            [self promptIfAllCriteriaMet];
        }
    }
}

- (void)openRatingsPageInAppStore
{
    if (!_ratingsURL && !self.appStoreID)
    {
        self.checkingForAppStoreID = YES;
        if (!self.checkingForPrompt)
        {
            [self checkForConnectivityInBackground];
        }
        return;
    }
    
    NSString *cantOpenMessage = nil;
    
#if TARGET_IPHONE_SIMULATOR
    
    if ([[self.ratingsURL scheme] isEqualToString:_AppRateriOSAppStoreURLScheme])
    {
        cantOpenMessage = @"_AppRater could not open the ratings page because the App Store is not available on the iOS simulator";
    }
    
#elif DEBUG
    
    if (![[UIApplication sharedApplication] canOpenURL:self.ratingsURL])
    {
        cantOpenMessage = [NSString stringWithFormat:@"_AppRater was unable to open the specified ratings URL: %@", self.ratingsURL];
    }
    
#endif
    
    void (^handler)(NSString *errorMessage) = ^(NSString *errorMessage)
    {
        if (errorMessage)
        {
            NSLog(@"%@", errorMessage);
            NSError *error = [NSError errorWithDomain:_AppRaterErrorDomain code:_AppRaterErrorCouldNotOpenRatingPageURL userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            if ([self.delegate respondsToSelector:@selector(whenCouldNotConnectToAppStore:)])
            {
                [self.delegate whenCouldNotConnectToAppStore:error];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:_AppRaterCouldNotConnectToAppStore
                                                                object:error];
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(whenDidOpenAppStore)])
            {
                [self.delegate whenDidOpenAppStore];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:_AppRaterDidOpenAppStore
                                                                object:nil];
        }
    };
    
    if (cantOpenMessage)
    {
        handler(cantOpenMessage);
    }
    else
    {
        if (self.verboseLogging)
        {
            NSLog(@"_AppRater will open the App Store ratings page using the following URL: %@", self.ratingsURL);
        }
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
        
        [[UIApplication sharedApplication] openURL:self.ratingsURL options:@{} completionHandler:^(BOOL success){
            if (success)
            {
                handler(nil);
            }
            else
            {
                handler([NSString stringWithFormat:@"_AppRater was unable to open the specified ratings URL: %@", self.ratingsURL]);
            }
        }];
#else
        [[UIApplication sharedApplication] openURL:self.ratingsURL];
        handler(nil);
#endif
        
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self didDismissAlert:alertView withButtonAtIndex:buttonIndex];
}
#pragma clang diagnostic pop

#else

- (void)openAppPageWhenAppStoreLaunched
{
    //check if app store is running
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications])
    {
        if ([app.bundleIdentifier isEqualToString:_AppRaterMacAppStoreBundleID])
        {
            //open app page
            [[NSWorkspace sharedWorkspace] performSelector:@selector(openURL:) withObject:self.ratingsURL afterDelay:MAC_APP_STORE_REFRESH_DELAY];
            return;
        }
    }
    
    //try again
    [self performSelector:@selector(openAppPageWhenAppStoreLaunched) withObject:nil afterDelay:0.0];
}

- (void)openRatingsPageInAppStore
{
    if (!_ratingsURL && !self.appStoreID)
    {
        self.checkingForAppStoreID = YES;
        if (!self.checkingForPrompt)
        {
            [self checkForConnectivityInBackground];
        }
        return;
    }
    
    if (self.verboseLogging)
    {
        NSLog(@"_AppRater will open the App Store ratings page using the following URL: %@", self.ratingsURL);
    }
    
    [[NSWorkspace sharedWorkspace] openURL:self.ratingsURL];
    [self openAppPageWhenAppStoreLaunched];
    if ([self.delegate respondsToSelector:@selector(_AppRaterDidOpenAppStore)])
    {
        [self.delegate _AppRaterDidOpenAppStore];
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(__unused void *)contextInfo
{
    [self didDismissAlert:alert withButtonAtIndex:returnCode - NSAlertFirstButtonReturn];
}

#endif

- (void)logEvent:(BOOL)deferPrompt
{
    [self incrementEventCount];
    if (!deferPrompt)
    {
        [self promptIfAllCriteriaMet];
    }
}

#pragma mark - User's actions

- (void)declineThisVersion
{
    //ignore this version
    self.declinedThisVersion = YES;
    
    //log event
    if ([self.delegate respondsToSelector:@selector(whenUserDidDeclineToRateApp)])
    {
        [self.delegate whenUserDidDeclineToRateApp];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:_AppRaterUserDidDeclineToRateApp
                                                        object:nil];
}

- (void)remindLater
{
    //remind later
    self.lastReminded = [NSDate date];
    
    //log event
    if ([self.delegate respondsToSelector:@selector(whenUserDidRequestReminderToRateApp)])
    {
        [self.delegate whenUserDidRequestReminderToRateApp];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:_AppRaterUserDidRequestReminderToRateApp
                                                        object:nil];
}

- (void)rate
{
    //mark as rated
    self.ratedThisVersion = YES;
    
    //log event
    if ([self.delegate respondsToSelector:@selector(whenUserDidAttemptToRateApp)])
    {
        [self.delegate whenUserDidAttemptToRateApp];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:_AppRaterUserDidAttemptToRateApp
                                                        object:nil];
    
    // if the delegate has not implemented the method, or if it returns YES
    if (![self.delegate respondsToSelector:@selector(whenShouldOpenAppStore)] || [self.delegate whenShouldOpenAppStore])
    {
        //launch mac app store
        [self openRatingsPageInAppStore];
    }
}

@end
