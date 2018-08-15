//
//  _StatusBarController.h
//  _Building
//
//  Created by 7 on 2018/8/12.
//

#import <Foundation/Foundation.h>

// ----------------------------------
// MARK: Interface
// ----------------------------------

@interface _StatusBarController : NSObject

// 以下两个方法，必须成对出现！
+ (void)lockStatusBar;
+ (void)unlockStatusBar;

+ (void)setStatusBarBackgroundColor:(UIColor *)color;

@end

