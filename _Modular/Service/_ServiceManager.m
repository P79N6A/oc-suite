#import "_Service.h"
#import "_ServiceManager.h"

@implementation _ServiceManager {
    NSMutableDictionary * _services;
}
    
@def_singleton( _ServiceManager )

@def_prop_dynamic( NSArray *, services );
    
- (id)init {
    self = [super init];
    if ( self ) {
        _services = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}
    
- (void)dealloc {
    [_services removeAllObjects];
    _services = nil;
}
    
- (NSArray *)components {
    return [_services allValues];
}
    
- (id)service:(Class)classType {
    _Service * service = [_services objectForKey:[classType description]];
    
    if ( nil == service ) {
        service = [[classType alloc] init];
        if ( service ) {
            [_services setObject:service forKey:[classType description]];
        }
        
//        if ( [service conformsToProtocol:@protocol(ManagedComponent)] ) {
//            [service powerOn];
//        }
    }
    
    return service;
}


@end
