//
//  NSObject+GrowthAttributes.h
//  consumer
//
//  Created by fallen on 16/11/23.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (GrowthAttributes)

/**
 *  设置界面元素ID (UIVIew)
 
 *  0. 建议您对它们设置固定的唯一ID，以保证数据的一致性
 *  1. 请加在viewWillAppear或者时机更早的函数里
 *  2. ID只能设置为字母、数字和下划线的组合
 */
@property (nonatomic, copy) NSString *growthAttributesUniqueTag;

/**
 *  采集广告Banner数据 (主要针对UIView)
 
 *  1. 对不同广告图，广告的唯一ID也不相同
 *  2. 响应点击的控件，与设置ID的控件是同一个
 */
@property (nonatomic, copy) NSString *growthAttributesValue;

/**
 *  页面别名 (主要针对UIViewController)
 
 *  1. 必须在该 UIViewController 的 viewWillAppear 或者更早时机的函数中完成该属性的赋值操作。
 *  2. 页面别名只能设置为字母、数字和下划线的组合。
 *  3. 为查看数据方便，请尽量对iOS和安卓的同功能页面取不同的名称。
 */
@property (nonatomic, copy) NSString *growthAttributesPageName;

/**
 *  忽略某元素
 */
@property (nonatomic, assign) BOOL growthAttributesDonotTrack;

@end
