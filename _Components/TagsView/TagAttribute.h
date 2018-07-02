//
//  HXTagAttribute.h
//  HXTagsView https://github.com/huangxuan518/HXTagsView
//  博客地址 http://blog.libuqing.com/
//  Created by Love on 16/6/30.
//  Copyright © 2016年 IT小子. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "_foundation.h"

@class HXTagCollectionViewFlowLayout;

@interface HXTagAttribute : NSObject

@property (nonatomic,assign) CGFloat borderWidth;//标签边框宽度
@property (nonatomic,strong) UIColor *borderColor;//标签边框颜色
@property (nonatomic,assign) CGFloat cornerRadius;//标签圆角大小
@property (nonatomic,strong) UIColor *backgroundColor;//标签背景颜色
@property (nonatomic,assign) CGFloat titleSize;//标签字体大小
@property (nonatomic,strong) UIColor *textColor;//标签字体颜色
@property (nonatomic,strong) UIColor *keyColor;//搜索关键词颜色
@property (nonatomic,assign) CGFloat tagSpace;//标签内部左右间距(标题距离边框2边的距离和)

@prop_class(BOOL, preferredEnabled)
@prop_class(CGSize, preferredItemSize)
@prop_class(UIEdgeInsets, preferredSectionInset)
@prop_class(CGFloat, preferredMinimumInteritemSpacing)
//@property (class, nonatomic, assign) BOOL usingCustomItemSize;
//@property (class, nonatomic, assign) CGSize preferredItemSize;

@property (nonatomic, strong) HXTagCollectionViewFlowLayout *layout;

#pragma mark - State

+ (instancetype)normal;
+ (instancetype)selected;

#pragma mark - Layout

- (HXTagCollectionViewFlowLayout *)tagCellCollectionViewFlowLayout;

@end
