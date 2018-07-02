//
//  BadgeView.h
//  BadgeView
//
//  Created by  Soffes on 1/29/11.
//  Copyright 2011-2013  Soffes. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Options for aligning the badge horizontally.
 */
typedef NS_ENUM(NSInteger, BadgeViewAlignment) {
	/** Align badge along the left edge. */
	BadgeViewAlignmentLeft = NSTextAlignmentLeft,

	/** Align badge equally along both sides of the center line. */
	BadgeViewAlignmentCenter = NSTextAlignmentCenter,

	/** Align badge along the right edge. */
	BadgeViewAlignmentRight = NSTextAlignmentRight
};

/**
 Badge view.

 Acts very much like the badges in Mail.app, with the key difference being that Apple uses images and `SSBadgeView` is
 rendered with Core Graphics for improved scrolling performance (although images are supported). This also allows for
 more flexible resizing.
 */

@interface BadgeView : UIView

///--------------------------------
/// @name Accessing the Badge Label
///--------------------------------

/**
 The badge text label.
 */
@property (nonatomic, readonly) UILabel *textLabel;


///-------------------------------------
/// @name Accessing the Badge Attributes
///-------------------------------------

/**
 The badge's background color.

 The default value of this property is grayish blue (that matches Mail.app).

 @see defaultBadgeColor
 */
@property (nonatomic) UIColor *badgeColor;

/**
 The badge's background color while its cell is highlighted.

 The default value of this property is white.
 */
@property (nonatomic) UIColor *highlightedBadgeColor;

/**
 The corner radius used when rendering the badge's outline.

 The default value of this property is 10.
 */
@property (nonatomic) CGFloat cornerRadius;

/**
 The minimum width used when calculating the size of the badge.

 The default value of this property is 30.
 */
@property (nonatomic) CGFloat minWidth;

/**
 Insets from the edges of the badge text label to the badge's outline.

 The default value of this property is (0, 6, 0, 6).
 */
@property (nonatomic) UIEdgeInsets contentInsets;

/**
 The badge's horizontal alignment within the accesoryView frame.

 This will position the badge in the view's bounds accordinly.

 The default value of this property is `SSBadgeViewAlignmentCenter`.
 */
@property (nonatomic) BadgeViewAlignment badgeAlignment;

/**
 A Boolean value indicating whether the receiver should be drawn with a highlight.

 Setting this property causes the receiver to redraw with the appropriate highlight state.

 The default value of this property is `NO`.
 */
@property (nonatomic, getter=isHighlighted) BOOL highlighted;


///---------------------
/// @name Drawing Images
///---------------------

/**
 The badge's background image.

 The default value of this property is `nil`. If the value is non-nil, it will be draw instead of the color.

 Setting a strechable image for this property is recommended.
 */
@property (nonatomic) UIImage *badgeImage;

/**
 The badge's background image while its cell is highlighted.

 The default value of this property is `nil`. If the value is non-nil, it will be draw instead of the color.

 Setting a strechable image for this property is recommended.
 */
@property (nonatomic) UIImage *highlightedBadgeImage;


///---------------
/// @name Defaults
///---------------

/**
 The default badge color.

 @return A color with its value set to the default badge color.
 */
+ (UIColor *)defaultBadgeColor;

@end

/**
 Usage
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
 
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
         
         // Setup cell accessory
         BadgeView *badge = [[BadgeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 55.0f, 20.0f)];
         badge.badgeAlignment = BadgeViewAlignmentRight;
         cell.accessoryView = badge;
    }
     
        BadgeView *badgeView = (BadgeView *)cell.accessoryView;
     
        if (indexPath.section == 0) {
         switch (indexPath.row) {
             case 0: {
                 cell.textLabel.text = @"Default Badge View";
                 badgeView.textLabel.text = @"0";
                 badgeView.badgeColor = [BadgeView defaultBadgeColor];
                 break;
             }
             
             case 1: {
                 cell.textLabel.text = @"Unread Count";
                 badgeView.textLabel.text = @"3";
                 badgeView.badgeColor = [UIColor colorWithRed:0.969f green:0.082f blue:0.078f alpha:1.0f];
                 break;
             }
             
             case 2: {
                 cell.textLabel.text = @"Text Badge";
                 badgeView.textLabel.text = @"New";
                 badgeView.badgeColor = [UIColor colorWithRed:0.388f green:0.686f blue:0.239f alpha:1.0f];
                 break;
             }
             
             case 3: {
                 cell.textLabel.text = @"Nil value";
                 badgeView.textLabel.text = nil;
                 badgeView.badgeColor = [BadgeView defaultBadgeColor];
                 break;
             }
         }
     } else {
         NSNumber *number = [NSNumber numberWithInteger:indexPath.row * 256];
         cell.textLabel.text = [[NSNumberFormatter localizedStringFromNumber:number numberStyle:NSNumberFormatterSpellOutStyle] capitalizedString];
         badgeView.textLabel.text = [NSNumberFormatter localizedStringFromNumber:number numberStyle:NSNumberFormatterDecimalStyle];
         badgeView.badgeColor = [BadgeView defaultBadgeColor];
	}
 
	return cell;
 }
 */
