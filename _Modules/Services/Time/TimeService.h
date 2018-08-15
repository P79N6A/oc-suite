//
//  TimeService.h
//  consumer
//
//  Created by fallen on 16/8/23.
//
//  @feature
//  1. 时区管理
//  2. 时间同步
//  3. 时间展现

#import "_Service.h"
#import "TimePresenter.h"

@interface TimeService : _Service

@singleton( TimeService )

@prop_assign(NSTimeInterval, timeOffset ) // device time - server time

// 时间、时区、时间显示格式、日历

@prop_instance( TimePresenter, presenter )

@end

@namespace( service , time, TimeService )
