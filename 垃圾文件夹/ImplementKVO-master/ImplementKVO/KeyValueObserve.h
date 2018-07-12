//
//  NSObject+KVO.h
//  ImplementKVO
//
//  Created by Peng Gu on 2/26/15.
//  Copyright (c) 2015 Peng Gu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ ObservingBlock)(id obj, NSString *key, id oldValue, id newValue);

@interface NSObject (KVO)

- (void)observe:(NSObject *)observe
            for:(NSString *)key
           with:(ObservingBlock)block;

- (void)unobserve:(NSObject *)observe
              for:(NSString *)key;

@end
