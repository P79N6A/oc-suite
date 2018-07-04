//
//  _docker_view.h
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//
#import "_precompile.h"
#import "_foundation.h"
#import "_docker_protocol.h"

@interface _DockerView : UIView

@prop_unsafe( id<ManagedDocker>,	handler );

- (void)setImageOpened:(UIImage *)image;
- (void)setImageClosed:(UIImage *)image;

- (void)onOpen;
- (void)onClose;

@end
