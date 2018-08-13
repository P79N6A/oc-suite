//
//  ALSerializationProtocol.h
//  NewStructure
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSProtocol.h"

@protocol ALSerializationProtocol <ALSProtocol>

// 至少支持NSDictionary
- (id)modelWithJSON:(id)json class:(Class)cls;
- (NSArray *)modelsWithJSON:(id)json class:(Class)cls;

@end
