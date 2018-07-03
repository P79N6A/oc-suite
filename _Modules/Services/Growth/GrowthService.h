//
//  GrowthService.h
//  consumer
//
//  Created by fallen on 16/11/23.
//
//  参考：https://help.growingio.com/SDK/iOS.html

#import "growthdef.h"
#import "_service.h"

@interface GrowthService : _Service // 牛逼的‘增长服务’，又名‘埋点服务’

@singleton( GrowthService )

- (void)startWith:(NSString *)what;

// A/B test


// 采集H5页面数据


// 采集GPS数据


// 页面转化
- (void)viewAppearAtIdentifier:(NSString *)identifier;

@end
