//
//  UIView+Creation.h
//  _Building
//
//  Created by 7 on 2018/8/13.
//

#import <UIKit/UIKit.h>

#define UIVIEW_INIT_WITHXIB(Class) \
- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {\
self = [super awakeAfterUsingCoder:aDecoder];\
static BOOL bLoad;\
if (!bLoad) {\
bLoad = YES;\
Class *view = [self getObjectFromNib];\
[view buildSubviews];\
return view;\
}\
bLoad = NO;\
return self;\
}

@interface UIView (Creation)

- (UIView*)duplicate;

/**
 *  从当前view的nib文件加载，理论上不要直接调用，而是在view.m文件中调用“UIVIEW_INIT_WITHXIB(Class)”，并实现"- (void)buildSubviews"
 *
 *  @return 加载nib后生成的类
 */
- (id)getObjectFromNib;

+ (UINib *)nib;

+ (UINib *)nibWithName:(NSString *)name;

@end
