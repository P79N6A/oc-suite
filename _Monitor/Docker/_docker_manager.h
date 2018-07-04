//
//  _docker_manager.h
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import "_component.h"
#import "_component_loader.h"
#import "_docker_view.h"
#import "_docker_window.h"

#pragma mark -

@interface _Component ( Docker )

- (void)openDocker;
- (void)closeDocker;

@end

#pragma mark -

@interface _DockerManager : NSObject

@singleton( _DockerManager )

- (void)installDockers;
- (void)uninstallDockers;

- (void)openDockerForComponent:(_Component<ManagedDocker> *)component;
- (void)closeDockerForComponent:(_Component<ManagedDocker> *)component;

@end
