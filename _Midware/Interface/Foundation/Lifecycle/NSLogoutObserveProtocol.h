//
//  NSLogoutObserveProtocol.h
//  NewStructure
//
//  Created by 7 on 03/01/2018.
//  Copyright © 2018 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSLogoutObserveProtocol <NSObject>

/**
 *  可自动收到 登出 通知
 */
- (void)onLogout;

@end
