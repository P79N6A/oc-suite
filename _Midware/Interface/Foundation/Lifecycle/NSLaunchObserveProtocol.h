//
//  NSLaunchObserveProtocol.h
//  NewStructure
//
//  Created by 7 on 03/01/2018.
//  Copyright © 2018 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSLaunchObserveProtocol <NSObject>

/**
 *  可自动收到 app launch
 */
- (void)onLaunch;

@end
