//
//  ALSPayConfigProtocol.h
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_Protocol.h"

@protocol _PayConfigProtocol <_Protocol>

@property (nonatomic, assign) NSUInteger platform;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *scheme; // 这里要在info.plist 里边写的一样的

@end
