#import <Foundation/Foundation.h>
#import "_chainable_typedef.h"

@interface _Chainable : NSObject
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


@interface _Chainable ( Extension ) // UILabel, UITextView

- (ChainableString)text;
- (ChainableFont)font;
- (ChainableColor)textColor;
- (ChainableColor)shadowColor;
- (ChainableInteger)textAlignment;
- (ChainableInteger)lineBreakMode;
- (ChainableAttributedString)attributedText;
- (ChainableInteger)numberOfLines;
- (ChainableFloat)minimumFontSize;

- (ChainableString)placeholder;
- (ChainableInteger)borderStyle;

@end

/**
 Usage
 
 self.view.make.backgroundColor([UIColor purpleColor]);
 
 UIView.make.origin(100, 100).size(50, 50).backgroundColor([UIColor greenColor]).addToSuperview(self.view);
 
 UILabel.make.origin(200,200).size(50,30).backgroundColor([UIColor greenColor]).textAlignment(NSTextAlignmentCenter).lineBreakMode(NSLineBreakByClipping).textColor([UIColor redColor]).numberOfLines(0).text(@"Hello ChainableKit").addToSuperview(self.view);
 UITextField.make.origin(300,300).size(50,30).text(@"test").textAlignment(NSTextAlignmentLeft).placeholder(@"placeholder").textColor([UIColor blueColor]).addToSuperview(self.view);
 */



