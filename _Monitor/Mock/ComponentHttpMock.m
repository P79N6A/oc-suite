//
//  ComponentHttpMock.m
//  kata
//
//  Created by fallen on 17/3/6.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import "ComponentHttpMock.h"
#import "GYHttpMock.h"

@implementation ComponentHttpMock

- (void)install {
    [super install];
}

- (void)uninstall {
    [super uninstall];
}

- (void)powerOn {
    [super powerOn];
}

- (void)powerOff {
    [super powerOff];
}

#pragma mark -

- (void)whenDockerOpen {
    [[GYHttpMock sharedInstance] startMock];
}

- (void)whenDockerClose {
    [[GYHttpMock sharedInstance] stopMock];
}

@end
