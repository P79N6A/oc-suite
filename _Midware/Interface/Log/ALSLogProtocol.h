//
//  ALSLogProtocol.h
//  wesg
//
//  Created by 7 on 22/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSLogConfigureProtocol.h"

@protocol ALSLogProtocol <NSObject>

@property (nonatomic, strong) id<ALSLogConfigureProtocol> configure;

@end
