#import "_Foundation.h"

@interface _ModuleLoader : NSObject

@singleton( _ModuleLoader )

- (void)loadable;

- (void)launchable:(UIApplication *)application options:(NSDictionary *)options;

@end
