
#import <_Foundation/_Foundation.h>

// ----------------------------------
// Macro
// ----------------------------------

#undef  app_initializer
#define app_initializer [_AppInit sharedInstance]

// ----------------------------------
// Class Definition
// ----------------------------------

@interface _AppInit : NSObject

@singleton( _AppInit )

@end
