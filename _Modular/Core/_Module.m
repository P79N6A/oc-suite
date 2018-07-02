//
//  _module.m
//  component
//
//  Created by fallen.ink on 4/12/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_module.h"

@implementation _Module

@def_prop_strong( NSString *,		name );
@def_prop_strong( NSBundle *,		bundle );
@def_prop_assign( BOOL,				running );
@def_prop_assign( BOOL,				installed );

- (id)init {
    self = [super init];
    if ( self ) {
        self.name = NSStringFromClass([self class]);
        self.bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[[self class] description] ofType:@"bundle"] ];
    }
    return self;
}

- (void)dealloc {
    if ( _running ) {
        [self powerOff];
    }
    
    self.bundle = nil;
    self.name = nil;
}

- (BOOL)autoinstall {
    return YES;
}

- (void)install {
    self.installed = YES;
}

- (void)uninstall {
    self.installed = NO;
}

- (void)powerOn {
    self.running = YES;
}

- (void)powerOff {
    self.running = NO;
}


@end
