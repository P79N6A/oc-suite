

#import "_AppUninit.h"
#import "_AppContext.h"

@implementation _AppUninit

@def_singleton( _AppUninit )

- (void)logout {
    [app_context.user clear];
    
    if (is_method_implemented(self.delegate, onLogout)) {
        [self.delegate onLogout];
    }
}

@end
