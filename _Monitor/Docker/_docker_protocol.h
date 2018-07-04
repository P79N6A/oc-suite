//
//  _docker_protocol.h
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ManagedDocker <NSObject>

@optional
- (void)whenDockerOpen;
- (void)whenDockerClose;

@end
