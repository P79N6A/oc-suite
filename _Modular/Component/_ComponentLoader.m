//
//  _component_loader.m
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import "_component_loader.h"
#import "_component.h"

@implementation _ComponentLoader {
    NSMutableDictionary * _components;
}

@def_singleton( _ComponentLoader )

@def_prop_dynamic( NSArray *, components );

- (id)init {
    self = [super init];
    if ( self ) {
        _components = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_components removeAllObjects];
    _components = nil;
}

- (void)installComponents {
//#if __SAMURAI_SERVICE__
//    
    for ( NSString * className in [_Component subClasses] ) {
        Class classType = NSClassFromString( className );
        if ( nil == classType )
            continue;
        
        fprintf( stderr, "  Loading component '%s'\n", [[classType description] UTF8String] );
        
        _Component * component = [self component:classType];
        if ( component && [component autoinstall]) {
            [component install];
        }
    }
    
    fprintf( stderr, "\n" );
    
//#endif
}

- (void)uninstallComponents {
    for ( _Component * component in _components ) {
        [component uninstall];
    }
    
    [_components removeAllObjects];
}

- (NSArray *)components {
    return [_components allValues];
}

- (id)component:(Class)classType {
    _Component * component = [_components objectForKey:[classType description]];
    
    if ( nil == component ) {
        component = [[classType alloc] init];
        if ( component ) {
            [_components setObject:component forKey:[classType description]];
        }
        
        if ( [component conformsToProtocol:@protocol(ManagedComponent)] ) {
            [component powerOn];
        }
    }
    
    return component;
}

@end
