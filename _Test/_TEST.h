//
//  John.h
//  log_test_with_framework
//
//  Created by 7 on 05/09/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

/**
 XCT测试套件
 */
#import <XCTest/XCTest.h>
/**
 部分宏定义
 */
#import "MACRO.h"
/**
 部分api重命名
 */
#import "ALIAS.h"

/**
 用于串行、并发测试
 */
#import "CONCTEST.h"
/**
 用于监测、统计性能
 */
#import "PERFTEST.h"
/**
 用于mock接口，测试连通性（需要获取网络性能时，不可使用该模块）
 */
#import "HTTPMOCK.h"

#import "DUMP.h"


/**
 * 代码建议
 
 1. 用例代码分段
 
 * Given-When-Then
 
 ```
 // given
 _sut.collectionType = 1;
 NSIndexPath *path1 = [NSIndexPath indexPathForRow:1 inSection:1];
 
 // when
 BOOL needToShow1 = [_sut needToShowRow:path1];
 
 // then
 assertThatBool(needToShow1,isTrue());
 ```
 
 or
 
 ```
 // Definition or declaration
 
 BOOL needToShow1 = NO;
 
 _sut.collectionType = 1;
 NSIndexPath *path1 = [NSIndexPath indexPathForRow:1 inSection:1];
 
 {
 needToShow1 = [_sut needToShowRow:path1]; // Simulation
 }
 
 {
 assertThatBool(needToShow1,isTrue()); // Verify
 }
 ```
 
 2. 用例单一职责
 
 * There is no 'if…else…'
 
 3. 测试类单一职责
 
 * 当前可能做不到, If could, weh use 'uto' as tested class instance.
 
 4. 不可测试私有属性、方法、变量
 
 * If must, use category !
 
 
 */
