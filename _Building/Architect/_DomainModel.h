//
//  _domain_model.h
//  student
//
//  Created by fallen.ink on 18/04/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

// controller
// service
// domain model
// dao
// db or storage sys

// 这里，我们可以定义service，也可以定义责任颗粒更小的 ->
// 那么，我们使用，领域模型
// 它
// 1. 封装领域数据聚合
// 2. 封装领域规则
// 3. 如果有DataCenter，则需要做数据分发

@interface _DomainModel : NSObject

@end
