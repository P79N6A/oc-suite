//
//  NSModulableProtocol.h
//  NewStructure
//
//  Created by 7 on 13/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSLoadableProtocol.h"
#import "NSLaunchableProtocol.h"

// 模块化协议
@protocol NSModulableProtocol <NSLoadableProtocol, NSLaunchableProtocol>

+ (NSString *)moduleDescription; // 模块描述

@end
