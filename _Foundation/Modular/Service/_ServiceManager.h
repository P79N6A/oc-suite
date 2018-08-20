#import "_Foundation.h"

@interface _ServiceManager : NSObject

@singleton( _ServiceManager )

@prop_readonly( NSArray *, services )
    
- (id)service:(Class)classType;
    
@end
