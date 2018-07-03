//
//  ALSBusinessObject.h
//  wesg
//
//  Created by 7 on 04/12/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "ALSModule.h"
#import "NSLoadableProtocol.h"
#import "NSSessionObserveProtocol.h"
#import "NSAppLifeCycleObserveProtocol.h"

/**
 *  @brief 牛逼的业务对象，继承它能获得基本的功能性
 
 *  通用业务对象、业务模块对象
 */
@interface ALSBusinessObject : ALSModule <
    NSLoadableProtocol,
    NSAppLifeCycleObserveProtocol,
    NSSessionObserveProtocol
>

@end
