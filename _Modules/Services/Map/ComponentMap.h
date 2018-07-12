
#import <_Foundation/_Foundation.h>
#import "ComponentMapConfig.h"
#import "LocationViewController.h"
#import "LocationIndicatorVC.h"
#import "AddressInputHintViewController.h"

@class ComponentMapConfig;

@interface ComponentMap : NSObject

@singleton( ComponentMap )

@prop_instance( ComponentMapConfig, config)

- (void)initGDAPIKey;

@end
