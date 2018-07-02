//
//  _component.h
//  component
//
//  Created by fallen.ink on 4/12/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//


/**
 *  业务组件（Business component）
 
 *  1. 组件（component）
 *  2. 流程（process）
 */

#import "_module.h"

#pragma mark -

@protocol ManagedComponent <NSObject>
@end

#pragma mark -

@interface _Component : _Module

+ (instancetype)instance;

- (void)install;
- (void)uninstall;

- (void)powerOn;
- (void)powerOff;

@end
