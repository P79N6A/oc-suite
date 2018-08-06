#import "_Component.h"
#import "_ComponentLoader.h"

@implementation _Component

+ (instancetype)instance {
    return [[_ComponentLoader sharedInstance] component:[self class]];
}

- (void)dealloc {
    
}

- (void)install {
    [super install];
}

- (void)uninstall {
    [super uninstall];
}

@end
