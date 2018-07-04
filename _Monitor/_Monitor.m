//
//  _debuggy.m
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import "_debuggy.h"
#import "_module_x.h"

@implementation _Debuggy

@def_singleton_autoload( _Debuggy )

- (instancetype)init {
    if (self = [super init]) {
        [self install];
    }
    
    return self;
}

- (void)dealloc {
    [self uninstall];
}

- (void)install {
    [[_ComponentLoader sharedInstance] installComponents];
    
    [self observeNotification:UIApplicationDidFinishLaunchingNotification];
    [self observeNotification:UIApplicationWillTerminateNotification];
}

- (void)uninstall {
    [[_ComponentLoader sharedInstance] uninstallComponents];
}

#pragma mark -

- (void)handleNotification:(NSNotification *)notification {
    if ([notification is:UIApplicationDidFinishLaunchingNotification]) {
        dispatch_after_foreground( 1.0f, ^{
            [[_DockerManager sharedInstance] installDockers];
        });
    } else if ([notification is:UIApplicationWillTerminateNotification]) {
        [[_DockerManager sharedInstance] uninstallDockers];
    }
}

@end
