//
//  NSString+Size.h
// fallen.ink
//
//  Created by 李杰 on 2/13/15.
//
//

#import "_precompile.h"
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface NSString (Size)

/**
 *  @brief 计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
/**
 *  @brief 计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

/**
 *  @brief 计算文字的大小
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

/**
 *  @brief 计算文字的大小
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

/**
 *  @brief 计算文字的的行数
 *
 *  @param font     字体(默认为系统字体)
 *  @param width    约束宽度
 */
- (int32_t)linesWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

/**
 *  @brief 计算单行文字大小
 *
 *  @param font     字体(默认为系统字体)
 */
- (CGSize)sizeOfConstrainedToSingleLineWithFont:(UIFont *)font;

/**
 *  @brief 计算文字的的行数
 *
 *  @param font     字体(默认为系统字体)
 *  @param size     约束大小
 *  @param lineBreakMode 分行类型
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode DEPRECATED;

- (int)textLineNumWithFont:(UIFont *)font constrainedToSize:(CGSize)size DEPRECATED;

- (CGSize)textSizeForOneLineWithFont:(UIFont *)font DEPRECATED;

@end

@interface NSString (Bounding)

- (CGSize)sizeOfMaxBoundingWidth:(CGFloat)width withLineBreakMode:(NSLineBreakMode)mode font:(UIFont *)font;

- (CGSize)sizeOfMaxBoundingWidth:(CGFloat)width withLineBreakMode:(NSLineBreakMode)mode font:(UIFont *)font maxLine:(NSUInteger)line;

@end


@interface NSAttributedString (Bounding)

- (CGSize)sizeOfAttributedStringWithMaxBoundingWidth:(CGFloat)width LineBreakMode:(NSLineBreakMode)mode Font:(UIFont *)font maxLine:(NSUInteger)line;

@end
