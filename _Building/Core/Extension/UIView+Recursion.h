//
//  UIView+Recursion.h
//  JKCategories
//
//  Created by Jakey on 15/6/23.
//  Copyright © 2015年 www.skyfox.org. All rights reserved.
//

#import "_Precompile.h"

@interface UIView ( Recursion )

/**
 *  @brief  寻找子视图
 *
 *  @param recurse 回调
 *
 *  @return  Return YES from the block to recurse into the subview.
 Set stop to YES to return the subview.
 */
- (UIView *)findViewRecursively:(BOOL(^)(UIView* subview, BOOL* stop))recurse;

- (void)runBlockOnAllSubviews:(ObjectBlock)block;
- (void)runBlockOnAllSuperviews:(ObjectBlock)block;
- (void)enableAllControlsInViewHierarchy;
- (void)disableAllControlsInViewHierarchy;

@end
