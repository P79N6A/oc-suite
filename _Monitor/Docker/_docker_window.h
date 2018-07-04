//
//  _docker_window.h
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import "_docker_view.h"

@interface _DockerWindow : UIWindow

- (void)addDockerView:(_DockerView *)docker;
- (void)removeDockerView:(_DockerView *)docker;
- (void)removeAllDockerViews;

- (void)relayoutAllDockerViews;

@end
