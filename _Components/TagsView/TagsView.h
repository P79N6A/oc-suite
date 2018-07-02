//
//  HXTagsView.h
//  黄轩 https://github.com/huangxuan518
//
//  Created by 黄轩 on 16/1/13.
//  Copyright © 2015年 IT小子. All rights reserved.
//

#import "TagCollectionViewFlowLayout.h"
#import "TagAttribute.h"

@class HXTagAttribute;

@interface HXTagsView : UIView

@property (nonatomic, strong) NSArray *tags;//传入的标签数组 字符串数组

@property (nonatomic, strong) NSArray *defaultSelectedTags; // 默认传入的标签数组 字符串数组

@property (nonatomic, strong) HXTagCollectionViewFlowLayout *layout;//布局layout
@property (nonatomic, strong) HXTagAttribute *tagAttribute;//按钮样式默认对象
@property (nonatomic, strong) HXTagAttribute *tagSelectedAttribute;//按钮样式选中对象
@property (nonatomic, assign) BOOL isMultiSelect;//是否可以多选 默认:NO 单选
@property (nonatomic, assign) NSUInteger selectCountLimit; // 为多选的时候，上限设置
@property (nonatomic, copy) NSString *key;//搜索关键词

@property (nonatomic, copy) void (^completion)(NSArray *selectTags,NSInteger currentIndex);//选中的标签数组,当前点击的index

// 刷新样式
- (void)setup;

// 刷新界面
- (void)reloadData;

/**
 *  计算Cell的高度
 *
 *  @param tags         标签数组
 *  @param layout       布局样式 默认则传nil
 *  @param tagAttribute 标签样式 默认传nil 涉及到计算的主要是titleSize
 *  @param width        计算的最大范围
 */
+ (CGFloat)getHeightWithTags:(NSArray *)tags layout:(HXTagCollectionViewFlowLayout *)layout tagAttribute:(HXTagAttribute *)tagAttribute width:(CGFloat)width;

@end
