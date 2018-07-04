//
//  _docker_manager.m
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import "_docker_manager.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation _Component ( Docker )

- (void)openDocker {
    if ( [self conformsToProtocol:@protocol(ManagedDocker)] ) {
        [[_DockerManager sharedInstance] openDockerForComponent:(_Component<ManagedDocker> *)self];
    }
}

- (void)closeDocker {
    if ( [self conformsToProtocol:@protocol(ManagedDocker)] ) {
        [[_DockerManager sharedInstance] closeDockerForComponent:(_Component<ManagedDocker> *)self];
    }
}

@end

#pragma mark -

@implementation _DockerManager {
    _DockerWindow * _dockerWindow;
}

@def_singleton( _DockerManager )

- (id)init {
    self = [super init];
    if ( self ) {
        
    }
    return self;
}

- (void)dealloc {
    _dockerWindow = nil;
}

- (void)installDockers {
    NSArray * components = [_ComponentLoader sharedInstance].components;
    
    for ( _Component *component in components ) {
        if ( [component conformsToProtocol:@protocol(ManagedDocker)] &&
             [component installed] /** Must be installed! */ ) {
            
            _DockerView * dockerView = [[_DockerView alloc] init];
            
            [dockerView setImageOpened:[component.bundle imageForResource:@"docker-open.png"]];
            [dockerView setImageClosed:[component.bundle imageForResource:@"docker-close.png"]];
            [dockerView setHandler:(id<ManagedDocker>)component];
            
            if ( nil == _dockerWindow ) {
                _dockerWindow = [[_DockerWindow alloc] init];
                _dockerWindow.alpha = 0.0f;
                _dockerWindow.hidden = NO;
            }
            
            [_dockerWindow addDockerView:dockerView];
        }
    }
    
    if ( _dockerWindow ) {
        [_dockerWindow relayoutAllDockerViews];
        //	[_dockerWindow setHidden:NO];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        _dockerWindow.alpha = 1.0f;
        
        [UIView commitAnimations];
    }
}

- (void)uninstallDockers {
    _dockerWindow = nil;
}

- (void)openDockerForComponent:(_Component<ManagedDocker> *)component {
    for ( UIView * subview in _dockerWindow.subviews ) {
        if ( [subview isKindOfClass:[_DockerView class]] ) {
            _DockerView * dockerView = (_DockerView *)subview;
            if ( dockerView.handler == component ) {
                [dockerView onOpen];
            }
        }
    }
}

- (void)closeDockerForComponent:(_Component<ManagedDocker> *)component {
    for ( UIView * subview in _dockerWindow.subviews ) {
        if ( [subview isKindOfClass:[_DockerView class]] ) {
            _DockerView * dockerView = (_DockerView *)subview;
            if ( dockerView.handler == component ) {
                [dockerView onClose];
            }
        }
    }
}


@end
