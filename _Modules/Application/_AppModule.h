
#import <_Foundation/_Foundation.h>

// ----------------------------------
// Macro
// ----------------------------------

#undef  app_module
#define app_module  [_AppModule sharedInstance]

// ----------------------------------
// Class Definition
// ----------------------------------

@interface _AppModule : NSObject

@singleton(_AppModule)

- (void)initComponents;

- (void)initServices;

@end
