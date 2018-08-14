//
//  UILabel+Extension.m
//  component
//
//  Created by fallen.ink on 4/11/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "UILabel+Extension.h"
#import "NSString+Size.h"
#import "_Foundation.h"

@implementation UILabel ( AttributeText )

- (void)setAttributedText:(NSString *)originText
              withKeyText:(NSString *)keyText
             keyTextColor:(UIColor *)textColor {
    do {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:originText];
        
        if (!keyText) break;
        if (![keyText length]) break;
        
        NSRange keyRange   = [originText rangeOfString:keyText];
        if (keyRange.location == NSNotFound) break;
        
        // Attribute setting
        while (keyRange.location != NSNotFound) {
            [attributedText addAttribute:NSForegroundColorAttributeName
                                   value:textColor
                                   range:keyRange];
            
            // find next sub string
            NSUInteger nextIndex   = keyRange.location+keyRange.length;
            keyRange    = [originText rangeOfString:keyText
                                            options:NSLiteralSearch
                                              range:NSMakeRange(nextIndex, originText.length-nextIndex)];
        }
        
        
        self.attributedText = attributedText;
        
        return;
    } while (NO);
    
    // Normal setting
    self.text   = originText;
}

@end

#pragma mark -

@implementation UILabel ( Instance )

+ (instancetype)instance {
    return [self instanceWithFont:font_normal_15 color:color_black];
}

+ (instancetype)instanceWithFont:(UIFont *)font color:(UIColor *)color {
    return [self instanceWithFont:font color:color alignment:NSTextAlignmentLeft];
}

+ (instancetype)instanceWithFont:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment {
    UILabel *label = [UILabel new];
    label.font = font;
    label.textColor = color;
    label.textAlignment = alignment;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail; // Set left words '...'
    
    return label;
}

@end

#pragma mark - UILabel + ContentSize

@implementation UILabel ( ContentSize )

- (CGSize)contentSizeForWidth:(CGFloat)width {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.alignment = self.textAlignment;
    
    CGRect contentFrame = [self.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : self.font } context:nil];
    return contentFrame.size;
}

- (CGSize)contentSize {
    return [self contentSizeForWidth:CGRectGetWidth(self.bounds)];
}

#pragma mark - 

- (CGFloat)heightWithLimitWidth:(CGFloat)width {
    return [self contentSizeForWidth:width].height;
}

- (CGFloat)heightWithLineSpace:(CGFloat)space value:(NSString *)value font:(UIFont *)font width:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = space;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
                          };
    
    CGSize size = [value boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}

- (int)lineCountWithLimitWidth:(CGFloat)width {
    int lineNum = [self.text linesWithFont:self.font constrainedToWidth:width];
    return lineNum;
}

- (BOOL)isTruncated {
    CGSize size = [self.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:nil].size;
    
    return (size.height > self.frame.size.height);
}

- (CGFloat)sizeToFitWithMaximumNumberOfLines:(NSInteger)lines {
    return [self sizeOfSizeToFitWithMaximumNumberOfLines:lines].height;
}


- (CGSize)sizeOfSizeToFitWithMaximumNumberOfLines:(NSInteger)lines {
    self.numberOfLines = lines;
    CGSize maxSize = CGSizeMake(self.frame.size.width, lines * self.font.lineHeight);
    /////////edit by Altair, 20150320, for iOS 7+
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    context.minimumScaleFactor = 1.0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.font, NSFontAttributeName,
                               paragraphStyle, NSParagraphStyleAttributeName, nil];
    CGSize size = [self.text boundingRectWithSize:maxSize
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:attribute
                                          context:nil].size;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
    return size;
}


@end

#pragma mark - System Adapt

@implementation UILabel ( Adapt )

- (void)adapted {
    
//    UIButton显示不全，加上sizeToFit 就可以解决
//    
//    [myBtn sizeToFit];
    
    if (IOS10_OR_LATER) {
//        UILable 显示不全，iOS10提供一个属性adjustsFontForContentSizeCategory
//        = YES来设置
//        
//        myLable.adjustsFontForContentSizeCategory
//        = YES
        self.adjustsFontSizeToFitWidth = YES;
    }
}

@end

#pragma mark - Line space

@implementation UILabel ( LineSpace )

- (void)setLineSpace:(CGFloat)space withValue:(NSString *)value withFont:(UIFont *)font {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = space; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    
    // 如果要设置字间距 NSKernAttributeName:@1.f
    
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle};
    
    if (value) {
        NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:value attributes:dic];
        self.attributedText = attributeStr;
    } else {
        self.text = nil;
        self.attributedText = nil;
    }
    
}

@end

#pragma mark - 

@implementation UILabel (Corner)

+(UILabel *) cornerLabel:(UIColor *) bgColor
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    return label;
    
}
@end
