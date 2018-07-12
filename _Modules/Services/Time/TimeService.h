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

#import "_service.h"
#import "TimePresenter.h"

@interface TimeService : _Service

@singleton( TimeService )

// 时间、时区、时间显示格式、日历

@prop_instance( TimePresenter, presenter )

@end
