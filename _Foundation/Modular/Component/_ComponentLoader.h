#import "_Foundation.h"

@interface _ComponentLoader : NSObject

@singleton( _ComponentLoader )

@prop_readonly( NSArray *, components );

- (id)component:(Class)classType;

- (void)installComponents;
- (void)uninstallComponents;

@end
