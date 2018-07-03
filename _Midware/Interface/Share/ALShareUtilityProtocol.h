//
//  ALShareUtilityProtocol.h
//  NewStructure
//
//  Created by 7 on 26/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALShareParamProtocol.h"

@protocol ALShareUtilityProtocol <NSObject>

- (BOOL)availableForPlatform:(ALSharePlatformType)platformType;

- (NSUInteger)typeOfPlatform:(ALSharePlatformType)platformType;
- (NSUInteger)sceneTypeOfPlatform:(ALSharePlatformType)platformType;

@end
