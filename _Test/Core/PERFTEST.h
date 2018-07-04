//
//  PERFORMANCE.h
//  log_test_with_framework
//
//  Created by 7 on 11/09/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_Macro.h"

// -------------------------------------------
// 功能
// 1. 追踪代码片段的时间性能
// 2. 追踪异步流程的时间性能
// 3. 是否需要日志数据？
// -------------------------------------------

// -------------------------------------------
// Macro
// -------------------------------------------

#define	PERF_TIME( block )			{ _PERF_ENTER(__PRETTY_FUNCTION__, __LINE__); block; _PERF_LEAVE(__PRETTY_FUNCTION__, __LINE__); }

#define	_PERF_ENTER( func, line )	[[PERFTEST sharedInstance] enter:[NSString stringWithFormat:@"%s#%d", func, line]];

#define	_PERF_LEAVE( func, line )	[[PERFTEST sharedInstance] leave:[NSString stringWithFormat:@"%s#%d", func, line]];

// -------------------------------------------
// Interface
// Block 形式计算时间消耗，不适用异步线程，也不建议使用Block形式技术，根据测试在单纯加减操作情况，时间消耗误差 20% 左右
// -------------------------------------------

@interface PERFTEST : NSObject

@SINGLETON( PERFTEST )

- (void)enter:(NSString *)tag;
- (void)leave:(NSString *)tag;

@end


