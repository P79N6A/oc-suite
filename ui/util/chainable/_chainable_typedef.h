@import UIKit;

@class _Chainable;

typedef _Chainable* (^ChainableView)(UIView *view);
#define ChainableView(view) ^_Chainable* (UIView *view)

typedef _Chainable* (^ChainableString)(NSString *string);
#define ChainableString(string) ^_Chainable* (NSString *string)

typedef _Chainable* (^ChainableAttributedString)(NSAttributedString *attributedText);
#define ChainableAttributedString(attributedText) ^_Chainable* (NSAttributedString *attributedText)

typedef _Chainable* (^ChainableFont)(UIFont *font);
#define ChainableFont(font) ^_Chainable* (UIFont *font)

typedef _Chainable* (^ChainableColor)(UIColor *color);
#define ChainableColor(color) ^_Chainable* (UIColor *color)

typedef _Chainable* (^ChainableRect)(CGFloat x, CGFloat y, CGFloat width, CGFloat height);
#define ChainableRect(x, y, width, height) ^_Chainable* (CGFloat x, CGFloat y, CGFloat width, CGFloat height)

typedef _Chainable* (^ChainablePoint)(CGFloat x, CGFloat y);
#define ChainablePoint(x, y) ^_Chainable* (CGFloat x, CGFloat y)

typedef _Chainable* (^ChainableSize)(CGFloat width, CGFloat height);
#define ChainableSize(width, height) ^_Chainable* (CGFloat width, CGFloat height)

typedef _Chainable* (^ChainableFloat)(CGFloat f);
#define ChainableFloat(f) ^_Chainable* (CGFloat f)

typedef _Chainable* (^ChainableInteger)(NSInteger i);
#define ChainableInteger(i) ^_Chainable* (NSInteger i)

