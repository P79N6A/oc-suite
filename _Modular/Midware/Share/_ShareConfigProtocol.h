//
//  ALShareConfigProtocol.h
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSProtocol.h"

@protocol ALShareConfigProtocol <ALSProtocol>

@property (nonatomic, strong) NSString *key; // app key
@property (nonatomic, strong) NSString *secret; // app secret
@property (nonatomic, strong) NSString *scheme; // url scheme
@property (nonatomic, strong) NSString *redirect; // redirect url

@end
