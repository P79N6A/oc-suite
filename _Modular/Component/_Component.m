//
//  _component.m
//  component
//
//  Created by fallen.ink on 4/12/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_component.h"
#import "_component_loader.h"

@implementation _Component

+ (instancetype)instance {
    return [[_ComponentLoader sharedInstance] component:[self class]];
}

- (void)dealloc {
    
}

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

@end
