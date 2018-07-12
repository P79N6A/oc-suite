//
//  ComponentSNShare_Config.h
//  component
//
//  Created by fallen.ink on 4/26/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <foundation/foundation.h>

@interface SNShareService_Config : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *appId;

// URL scheme 方便app之间互相调用
@property (nonatomic, strong) NSString *scheme;

// Client to set
@property (nonatomic, assign) BOOL supported;

@end
