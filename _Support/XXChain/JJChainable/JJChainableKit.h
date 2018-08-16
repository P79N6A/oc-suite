//
//  JJChainableKit.h
//  JJChainableExample
//
//  Created by JJ on 2017/2/18.
//  Copyright © 2017年 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJChainableBlock.h"

@interface JJChainableKit : NSObject
@property (nonatomic, strong) UIView *view;

- (ChainableView)addToSuperview;

- (ChainableColor)backgroundColor;
- (ChainableColor)tintColor;

- (ChainableRect)frame;
- (ChainableRect)bounds;
- (ChainablePoint)center;
- (ChainablePoint)origin;
- (ChainableSize)size;
- (ChainableFloat)x;
- (ChainableFloat)y;
- (ChainableFloat)width;
- (ChainableFloat)height;
- (ChainableFloat)centerX;
- (ChainableFloat)centerY;

@end


@interface JJChainableKit (UILable)

- (ChainableString)text;
- (ChainableFont)font;
- (ChainableColor)textColor;
- (ChainableColor)shadowColor;
- (ChainableInteger)textAlignment;
- (ChainableInteger)lineBreakMode;
- (ChainableAttributedString)attributedText;
- (ChainableInteger)numberOfLines;
- (ChainableFloat)minimumFontSize;

@end

@interface JJChainableKit (UITextField)
- (ChainableString)text;
- (ChainableColor)textColor;
- (ChainableFont)font;
- (ChainableInteger)textAlignment;
- (ChainableString)placeholder;
- (ChainableInteger)borderStyle;
@end






