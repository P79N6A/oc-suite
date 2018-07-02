//
//  JTSegmentArrowView.m
//  AiXinDemo
//
//  Created by shaofa on 14-2-17.
//  Copyright (c) 2014年 shaofa. All rights reserved.
//

#import "JTSegmentArrowView.h"

@implementation JTSegmentArrowView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.states = SegmentArrowNormalStates;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
}

- (void)setStates:(JTSegmentArrowStates)states {
    if (states != _states) {
        _states = states;
    }
    
    if (!self.images) {
        return;
    }
    
    if (_isSelected) {
        if (_states == SegmentArrowUpStates) {
            self.image = [UIImage imageNamed:[self.images objectAtIndex:2]];
        } else if (_states == SegmentArrowDownStates) {
            self.image = [UIImage imageNamed:[self.images objectAtIndex:1]];
        } else if (_states == SegmentArrowNormalStates) {
            self.image = [UIImage imageNamed:[self.images objectAtIndex:0]];
        }
        
        if (self.block != nil) {
            self.block(_states);
        }
    } else {
        if (_states == SegmentArrowUpStates) {
            self.image = [UIImage imageNamed:[self.images objectAtIndex:0]];
        } else if (_states == SegmentArrowDownStates) {
            self.image = [UIImage imageNamed:[self.images objectAtIndex:0]];
        } else if (_states == SegmentArrowNormalStates) {
            self.image = [UIImage imageNamed:[self.images objectAtIndex:0]];
        }
    }
}

@end
