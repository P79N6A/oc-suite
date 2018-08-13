//
//  NSLaunchableProtocol.h
//  NewStructure
//
//  Created by 7 on 03/01/2018.
//  Copyright © 2018 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSLaunchableProtocol <NSObject>

/**
 *  可自动收到 app launch
 *
 *  @desc 在AppDelegate didFinishLaunching 后段调用
 */
+ (void)onLaunch;

@end
