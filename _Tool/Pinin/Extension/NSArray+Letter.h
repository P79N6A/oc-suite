//
//  NSArray+FirstLetterArray.h
//  LetterDescent
//
//  Created by Mr.Yang on 13-8-20.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray ( HTLetter )

/**
 *	通过需要按【首字母分类】的 【姓名数组】 调用此函数
 *
 *	@return	A：以a打头的姓名或者单词
            B：以b打头的姓名或者单词
 */

- (NSDictionary *)sortedDictionary; // k:v 首字母－名字数组

/**
 *  Add by fallenink.
 *
 *  功能与sortedArrayUsingFirstLetter类似
 
 *  但是支持Array中时任意对象，需要提供Key
 */
- (NSDictionary *)sortedDictionaryWithPropertyKey:(NSString *)propertyKey;

/**
 *  排序过的，二维数组：一维是section，第二维是row
 */
- (NSArray *)sortedArrayWithPropertykey:(NSString *)propertyKey;

#pragma mark -

//-----  返回tableview右方indexArray
+(NSMutableArray*)IndexArray:(NSArray*)stringArr;

//-----  返回联系人
+(NSMutableArray*)LetterSortArray:(NSArray*)stringArr;


///----------------------
//返回一组字母排序数组(中英混排)
+(NSMutableArray*)SortArray:(NSArray*)stringArr;

@end

#pragma mark - 拼音匹配

/**
 *  调用该情况的前提：array的基本结构如下
 
 *  @[@"张国荣",
 *    @"刘德华"]
 
 *  实现中会有一层转化，如下
 
 *  @[@[@"zhang", @"guo", @"rong"],
 *    @[@"liu", @"de", @"hua"]]
 
 */


// TODO: 如何支持中英文？？？
// TODO: 速度优化
@interface NSArray ( PinyinMatch )

/**
 *  参考：http://blog.csdn.net/nanman/article/details/6062764
 */

/**
 *  输入：Model数组
 */
- (NSArray *)filteredArrayWithSearchingString:(NSString *)search reduceByPropertyKey:(NSString *)key;

@end

#pragma mark - 模型数组降维

@interface NSArray ( DimensionReduce )

/**
 *  取出模型的某个字段，将数组返回
 */
- (NSArray *)arrayReduceByPropertyKey:(NSString *)propertyKey;

@end
