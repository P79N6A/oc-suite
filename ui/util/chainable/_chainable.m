#import "_chainable.h"
#import "_foundation.h"

@implementation _Chainable

- (ChainableView)addToSuperview {
    weakly(self)
    return ChainableView(view) {
        [view addSubview:_.view];
        return _;
    };
}

#pragma mark - Color

- (ChainableColor)backgroundColor {
    weakly(self)
    return ChainableColor(color) {
        _.view.backgroundColor = color;
        return _;
    };
}

- (ChainableColor)tintColor {
    weakly(self)
    return ChainableColor(color) {
        _.view.tintColor = color;
        return _;
    };
}


#pragma mark - Position

- (ChainableRect)frame {
    weakly(self)
    return ChainableRect(x, y, width, height) {
        _.view.frame = CGRectMake(x, y, width, height);
        return _;
    };
}

- (ChainableRect)bounds {
    __weak _Chainable *weakSelf = self;
    return ChainableRect(x, y, width, height) {
        weakSelf.view.bounds = CGRectMake(x, y, width, height);
        return weakSelf;
    };
}

- (ChainablePoint)origin {
    __weak _Chainable *weakSelf = self;
    return ChainablePoint(x, y) {
        weakSelf.view.frame = CGRectMake(x,
                                         y,
                                         weakSelf.view.frame.size.width,
                                         weakSelf.view.frame.size.height);
        return weakSelf;
    };
}

- (ChainableSize)size {
    __weak _Chainable *weakSelf = self;
    return ChainableSize(width, height) {
        weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x,
                                         weakSelf.view.frame.origin.y,
                                         width,
                                         height);
        return weakSelf;
    };
}

- (ChainablePoint)center {
    __weak _Chainable *weakSelf = self;
    return ChainablePoint(x, y) {
        weakSelf.view.center = CGPointMake(x, y);
        return weakSelf;
    };
}

- (ChainableFloat)x {
    __weak _Chainable *weakSelf = self;
    return ChainableFloat(x) {
        weakSelf.view.frame = CGRectMake(x,
                                         weakSelf.view.frame.origin.y,
                                         weakSelf.view.frame.size.width,
                                         weakSelf.view.frame.size.height);
        return weakSelf;
    };
}

- (ChainableFloat)y {
    __weak _Chainable *weakSelf = self;
    return ChainableFloat(y) {
        weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x,
                                         y,
                                         weakSelf.view.frame.size.width,
                                         weakSelf.view.frame.size.height);
        return weakSelf;
    };
}
- (ChainableFloat)width {
    __weak _Chainable *weakSelf = self;
    return ChainableFloat(width) {
        weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x,
                                         weakSelf.view.frame.origin.y,
                                         width,
                                         weakSelf.view.frame.size.height);
        return weakSelf;
    };
}

- (ChainableFloat)height {
    __weak _Chainable *weakSelf = self;
    return ChainableFloat(height) {
        weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x,
                                         weakSelf.view.frame.origin.y,
                                         weakSelf.view.frame.size.width,
                                         height);
        return weakSelf;
    };
}

- (ChainableFloat)centerX {
    __weak _Chainable *weakSelf = self;
    return ChainableFloat(centerX) {
        weakSelf.view.center = CGPointMake(centerX,
                                           weakSelf.view.center.y);
        return weakSelf;
    };
}

- (ChainableFloat)centerY {
    __weak _Chainable *weakSelf = self;
    return ChainableFloat(centerY) {
        weakSelf.view.center = CGPointMake(weakSelf.view.center.x,
                                           centerY);
        return weakSelf;
    };
}

@end

@implementation _Chainable ( Extension )

- (ChainableString)text {
    weakly(self)
//    __weak _Chainable *weakSelf = self;
    return ChainableString(text) {
        if ([_.view respondsToSelector:@selector(text)])
            [_.view setValue:text forKey:__CMD_NAME__];
//            ((UILabel*)(weakSelf.view)).text = text;
        return _;
    };
}

- (ChainableFont)font {
    weakly(self)
//    __weak _Chainable *weakSelf = self;
    return ChainableFont(font) {
        if ([_.view respondsToSelector:@selector(font)])
            [_.view setValue:font forKey:__CMD_NAME__];
//            ((UILabel*)(weakSelf.view)).font = font;
        return _;
    };
}

- (ChainableColor)textColor {
    weakly(self)
//    __weak _Chainable *weakSelf = self;
    return ChainableColor(textColor) {
        if ([_.view respondsToSelector:@selector(textColor)])
            [_.view setValue:textColor forKey:__CMD_NAME__];
//            ((UILabel*)(weakSelf.view)).textColor = textColor;
        return _;
    };
}

- (ChainableInteger)numberOfLines {
    weakly(self)
//    __weak _Chainable *weakSelf = self;
    return ChainableInteger(numberOfLines) {
        if ([_.view respondsToSelector:@selector(numberOfLines)])
            [_.view setValue:valueof_integer(numberOfLines) forKey:__CMD_NAME__];
//            ((UILabel*)(weakSelf.view)).numberOfLines = numberOfLines;
        return _;
    };
}

- (ChainableColor)shadowColor {
    weakly(self)
//    __weak _Chainable *weakSelf = self;
    return ChainableColor(shadowColor) {
        if ([_.view respondsToSelector:@selector(shadowColor)])
            [_.view setValue:shadowColor forKey:__CMD_NAME__];
//            ((UILabel*)(weakSelf.view)).shadowColor = shadowColor;
        return _;
    };
}

- (ChainableInteger)textAlignment {
    weakly(self)
//    __weak _Chainable *weakSelf = self;
    return ChainableInteger(textAlignment) {
        if ([_.view respondsToSelector:@selector(textAlignment)])
            [_.view setValue:valueof_integer(textAlignment) forKey:__CMD_NAME__];
//            ((UILabel*)(weakSelf.view)).textAlignment = textAlignment;
        return _;
    };
}

- (ChainableInteger)lineBreakMode {
    weakly(self)
//    __weak _Chainable *weakSelf = self;
    return ChainableInteger(lineBreakMode) {
        if ([_.view respondsToSelector:@selector(lineBreakMode)])
            [_.view setValue:valueof_integer(lineBreakMode) forKey:__CMD_NAME__];
//            ((UILabel*)(weakSelf.view)).lineBreakMode = lineBreakMode;
        return _;
    };
}

- (ChainableAttributedString)attributedText {
    weakly(self)
//    __weak _Chainable *weakSelf = self;
    return ChainableAttributedString(attributedText) {
        if ([_.view respondsToSelector:@selector(attributedText)])
            [_.view setValue:attributedText forKey:__CMD_NAME__];
//            ((UILabel*)(weakSelf.view)).attributedText = attributedText;
        return _;
    };
}

- (ChainableFloat)minimumFontSize {
    weakly(self)
    
    return ChainableFloat(minimumFontSize) {
        if ([_.view respondsToSelector:@selector(minimumFontSize)])
            [_.view setValue:valueof_float32(minimumFontSize) forKey:__CMD_NAME__];
        return _;
    };
}

- (ChainableString)placeholder {
    weakly(self)
//    __weak _Chainable *weakSelf = self;
    return ChainableString(placeholder){
        if ([_.view respondsToSelector:@selector(placeholder)])
            [_.view setValue:placeholder forKey:__CMD_NAME__];
//            ((UITextField *)(weakSelf.view)).placeholder=placeholder;
        return _;
    };
}
- (ChainableInteger)borderStyle {
    weakly(self)
    return ChainableInteger(borderStyle) {
        if ([_.view respondsToSelector:@selector(borderStyle)])
            [_.view setValue:valueof_integer(borderStyle) forKey:__CMD_NAME__];
//            ((UITextField *)(weakSelf.view)).borderStyle=borderStyle;
        return _;
    };
}

@end











