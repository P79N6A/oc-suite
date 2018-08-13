//
//  _Layout.h
//  _Building
//
//  Created by 7 on 2018/8/12.
//

#import <Foundation/Foundation.h>

@interface _Layout : NSObject

@end

// MARK: -

@interface UIView (AutoLayout)

- (BOOL)resetFirstLayoutAttribute:(NSLayoutAttribute)attribute withConstant:(CGFloat)constant;

@end

