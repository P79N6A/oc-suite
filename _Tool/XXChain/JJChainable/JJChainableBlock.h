//
//  JJChainableBlock.h
//  JJChainableExample
//
//  Created by JJ on 2017/2/18.
//  Copyright © 2017年 JJ. All rights reserved.
//

@import UIKit;

@class JJChainableKit;

#ifndef JJChainableKit_ChainableBlock_h
#define JJChainableKit_ChainableBlock_h

typedef JJChainableKit* (^ChainableView)(UIView *view);
#define ChainableView(view) ^JJChainableKit* (UIView *view)

typedef JJChainableKit* (^ChainableString)(NSString *string);
#define ChainableString(string) ^JJChainableKit* (NSString *string)

typedef JJChainableKit* (^ChainableAttributedString)(NSAttributedString *attributedText);
#define ChainableAttributedString(attributedText) ^JJChainableKit* (NSAttributedString *attributedText)

typedef JJChainableKit* (^ChainableFont)(UIFont *font);
#define ChainableFont(font) ^JJChainableKit* (UIFont *font)

typedef JJChainableKit* (^ChainableColor)(UIColor *color);
#define ChainableColor(color) ^JJChainableKit* (UIColor *color)

typedef JJChainableKit* (^ChainableRect)(CGFloat x, CGFloat y, CGFloat width, CGFloat height);
#define ChainableRect(x, y, width, height) ^JJChainableKit* (CGFloat x, CGFloat y, CGFloat width, CGFloat height)

typedef JJChainableKit* (^ChainablePoint)(CGFloat x, CGFloat y);
#define ChainablePoint(x, y) ^JJChainableKit* (CGFloat x, CGFloat y)

typedef JJChainableKit* (^ChainableSize)(CGFloat width, CGFloat height);
#define ChainableSize(width, height) ^JJChainableKit* (CGFloat width, CGFloat height)

typedef JJChainableKit* (^ChainableFloat)(CGFloat f);
#define ChainableFloat(f) ^JJChainableKit* (CGFloat f)

typedef JJChainableKit* (^ChainableInteger)(NSInteger i);
#define ChainableInteger(i) ^JJChainableKit* (NSInteger i)


#endif
