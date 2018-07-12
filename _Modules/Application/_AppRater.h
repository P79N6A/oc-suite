//
//  AppRater.h
//  consumer
//
//  Created by fallen.ink on 18/10/2016.
//
//  inspired by https://github.com/nicklockwood/iRate
//
//  @Knowledge
//  1. Look up ur app id : http://blog.csdn.net/kesalin/article/details/6605934

#import <Availability.h>
#import <TargetConditionals.h>
#import <_Foundation/_Foundation.h>
#import "_pragma_push.h"

// ----------------------------------
// Macro
// ----------------------------------

#undef weak_delegate
#if __has_feature(objc_arc_weak) && \
(TARGET_OS_IPHONE || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_8)
#define weak_delegate weak
#else
#define weak_delegate unsafe_unretained
#endif

#undef  app_rater
#define app_rater   [_AppRater sharedInstance]

// ----------------------------------
// Const Variable
// ----------------------------------

//! Project version number for _AppRater.
FOUNDATION_EXPORT double _AppRaterVersionNumber;

//! Project version string for _AppRater.
FOUNDATION_EXPORT const unsigned char _AppRaterVersionString[];

EXTERN NSUInteger const _AppRaterAppStoreGameGenreID;
EXTERN NSString *const _AppRaterErrorDomain;

//localisation string keys
EXTERN NSString *const _AppRaterMessageTitleKey; //_AppRaterMessageTitle
EXTERN NSString *const _AppRaterAppMessageKey; //_AppRaterAppMessage
EXTERN NSString *const _AppRaterGameMessageKey; //_AppRaterGameMessage
EXTERN NSString *const _AppRaterUpdateMessageKey; //_AppRaterUpdateMessage
EXTERN NSString *const _AppRaterCancelButtonKey; //_AppRaterCancelButton
EXTERN NSString *const _AppRaterRemindButtonKey; //_AppRaterRemindButton
EXTERN NSString *const _AppRaterRateButtonKey; //_AppRaterRateButton

//notification keys
EXTERN NSString *const _AppRaterCouldNotConnectToAppStore;
EXTERN NSString *const _AppRaterDidDetectAppUpdate;
EXTERN NSString *const _AppRaterDidPromptForRating;
EXTERN NSString *const _AppRaterUserDidAttemptToRateApp;
EXTERN NSString *const _AppRaterUserDidDeclineToRateApp;
EXTERN NSString *const _AppRaterUserDidRequestReminderToRateApp;
EXTERN NSString *const _AppRaterDidOpenAppStore;

// ----------------------------------
// Type Definition
// ----------------------------------

typedef NS_ENUM(NSUInteger, _AppRaterErrorCode) {
    _AppRaterErrorBundleIdDoesNotMatchAppStore = 1,
    _AppRaterErrorApplicationNotFoundOnAppStore,
    _AppRaterErrorApplicationIsNotLatestVersion,
    _AppRaterErrorCouldNotOpenRatingPageURL
};

// ----------------------------------
// Delegate Declaration
// ----------------------------------

@protocol _AppRaterDelegate <NSObject>
@optional

- (void)whenCouldNotConnectToAppStore:(NSError *)error;
- (void)whenDidDetectAppUpdate;
- (BOOL)whenShouldPromptForRating;
- (void)whenDidPromptForRating;
- (void)whenUserDidAttemptToRateApp;
- (void)whenUserDidDeclineToRateApp;
- (void)whenUserDidRequestReminderToRateApp;
- (BOOL)whenShouldOpenAppStore;
- (void)whenDidOpenAppStore;

@end

// ----------------------------------
// Class Definition
// ----------------------------------

@interface _AppRater : NSObject

@singleton(_AppRater)

//app store ID - this is only needed if your
//bundle ID is not unique between iOS and Mac app stores
@property (nonatomic, assign) NSUInteger appStoreID;

//application details - these are set automatically
@property (nonatomic, assign) NSUInteger appStoreGenreID;
@property (nonatomic, copy) NSString *appStoreCountry;
@property (nonatomic, copy) NSString *applicationName;
@property (nonatomic, copy) NSString *applicationVersion;
@property (nonatomic, copy) NSString *applicationBundleID;

//usage settings - these have sensible defaults
@property (nonatomic, assign) NSUInteger usesUntilPrompt;
@property (nonatomic, assign) NSUInteger eventsUntilPrompt;
@property (nonatomic, assign) float daysUntilPrompt;
@property (nonatomic, assign) float usesPerWeekForPrompt;
@property (nonatomic, assign) float remindPeriod;

//message text, you may wish to customise these
@property (nonatomic, copy) NSString *messageTitle;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *updateMessage;
@property (nonatomic, copy) NSString *cancelButtonLabel;
@property (nonatomic, copy) NSString *remindButtonLabel;
@property (nonatomic, copy) NSString *rateButtonLabel;

//debugging and prompt overrides
@property (nonatomic, assign) BOOL useUIAlertControllerIfAvailable;
@property (nonatomic, assign) BOOL useAllAvailableLanguages;
@property (nonatomic, assign) BOOL promptForNewVersionIfUserRated;
@property (nonatomic, assign) BOOL onlyPromptIfLatestVersion;
@property (nonatomic, assign) BOOL onlyPromptIfMainWindowIsAvailable;
@property (nonatomic, assign) BOOL promptAtLaunch;
@property (nonatomic, assign) BOOL verboseLogging;
@property (nonatomic, assign) BOOL previewMode;

//advanced properties for implementing custom behaviour
@property (nonatomic, strong) NSURL *ratingsURL;
@property (nonatomic, strong) NSDate *firstUsed;
@property (nonatomic, strong) NSDate *lastReminded;
@property (nonatomic, assign) NSUInteger usesCount;
@property (nonatomic, assign) NSUInteger eventCount;
@property (nonatomic, readonly) float usesPerWeek;
@property (nonatomic, assign) BOOL declinedThisVersion;
@property (nonatomic, readonly) BOOL declinedAnyVersion;
@property (nonatomic, assign) BOOL ratedThisVersion;
@property (nonatomic, readonly) BOOL ratedAnyVersion;
@property (nonatomic, weak_delegate) id<_AppRaterDelegate> delegate;

//manually control behaviour
- (BOOL)shouldPromptForRating;
- (void)promptForRating;
- (void)promptIfNetworkAvailable;
- (void)promptIfAllCriteriaMet;
- (void)openRatingsPageInAppStore;
- (void)logEvent:(BOOL)deferPrompt;
- (void)remindLater;

@end

/**
 *  Usafe
 *
 *  1. configuration
 *
    [_AppRater sharedInstance].applicationBundleID = @"com.charcoaldesign.rainbowblocks-free";
    [_AppRater sharedInstance].onlyPromptIfLatestVersion = NO;
 
    //enable preview mode
    [_AppRater sharedInstance].previewMode = YES;
 
 
 *  2. recall
    - (BOOL)whenShouldPromptForRating
    {
        if (!self.alertView)
        {
            self.alertView = [[UIAlertView alloc] initWithTitle:@"Rate Me!" message:@"I'm a completely custom rating dialog. Awesome, right?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Rate Now", @"Maybe Later", @"Open Web Page", nil];
 
            [self.alertView show];
        }
        return NO;
    }
 
    - (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
    {
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            //ignore this version
            [_AppRater sharedInstance].declinedThisVersion = YES;
        }
        else if (buttonIndex == 1) // rate now
        {
            //mark as rated
            [_AppRater sharedInstance].ratedThisVersion = YES;
 
            //launch app store
            [[_AppRater sharedInstance] openRatingsPageInAppStore];
        }
        else if (buttonIndex == 2) // maybe later
        {
            //remind later
            [_AppRater sharedInstance].lastReminded = [NSDate date];
        }
        else if (buttonIndex == 3) // open web page
        {
            NSURL *url = [NSURL URLWithString:@"http://www.apple.com"];
            [[UIApplication sharedApplication] openURL:url];
        }
 
        self.alertView = nil;
    }
 */

#import "_pragma_pop.h"
