//
//  JTSegmentArrowView.h
//  AiXinDemo
//
//  Created by shaofa on 14-2-17.
//  Copyright (c) 2014年 shaofa. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 正常态 与 选中态，由来SelectedIndex确定
 
 * 选中态中又分为两种状态
 
 * normal, up\down
 
 * normal, down
 */
typedef enum {
    SegmentArrowNormalStates    = 0,
    SegmentArrowSelectedStates  = 1,
    SegmentArrowDownStates      = SegmentArrowSelectedStates,
    SegmentArrowUpStates        = 2,
} JTSegmentArrowStates;

typedef void(^ StateHadChangedBlock)(JTSegmentArrowStates state);

@interface JTSegmentArrowView : UIImageView

@property (nonatomic, strong) NSArray *images;

@property(nonatomic, assign) JTSegmentArrowStates states;
@property(nonatomic, assign) BOOL isSelected;

@property(nonatomic, copy) StateHadChangedBlock block;

@end
