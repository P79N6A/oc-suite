//
//  SingletonExample.h
//  gege
//
//  Created by fallen.ink on 2019/3/14.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

/**
 * Usage
 
    [[SingletonExample sharedInstance] test];
 */

NS_ASSUME_NONNULL_BEGIN

@interface SingletonExample : NSObject

@singleton(SingletonExample)

- (void)test;

@end

NS_ASSUME_NONNULL_END
