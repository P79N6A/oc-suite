
#import <_Foundation/_Foundation.h>

// ----------------------------------
// Macro
// ----------------------------------

#undef  app_uninitializer
#define app_uninitializer   [_AppUninit sharedInstance]

// ----------------------------------
// Pre Declaration
// ----------------------------------

@protocol AppUninitDelegate;

// ----------------------------------
// Class Definition
// ----------------------------------

@interface _AppUninit : NSObject

@singleton( _AppUninit )

@prop_weak(id<AppUninitDelegate>, delegate)

- (void)logout;

@end

// ----------------------------------
// Delegate Definition
// ----------------------------------

@protocol AppUninitDelegate <NSObject>

@optional

- (void)onLogout;

@end
