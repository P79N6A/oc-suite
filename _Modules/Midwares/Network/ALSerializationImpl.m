//
//  ALSerializationImpl.m
//  NewStructure
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "ALSerializationImpl.h"
#import "_MidwarePrecompile.h"

@implementation ALSerializationImpl

- (id)modelWithJSON:(id)json class:(__unsafe_unretained Class)cls {
#if __has_YYModel
    return [cls yy_modelWithJSON:json];
    
#elif __has_MJExtension
    
    return [cls mj_objectWithKeyValues:json];
    
#else
    
    return nil;
#endif
}

- (NSArray *)modelsWithJSON:(id)json class:(__unsafe_unretained Class)cls {
#if __has_YYModel
    return [NSArray yy_modelArrayWithClass:cls json:json];
    
#elif __has_MJExtension
    
    return [cls mj_objectArrayWithKeyValuesArray:json];
    
#else
    
    return nil;
#endif
}

@end
