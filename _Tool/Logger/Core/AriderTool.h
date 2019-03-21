//
//  AriderTool.h
//  AriderLog
//
//  Created by junzhan on 14-2-24.
//  Copyright (c) 2014年 Taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ALOG_STATUS_BAR_HEIGHT 20.0f
#define ALOG_SEGMENT_HEIGHT 36.0f
#define ALOG_SUB_COMPONET_VIEW_HEIGHT ([AriderTool screenHeight]-ALOG_STATUS_BAR_HEIGHT-ALOG_SEGMENT_HEIGHT)
// 判断是否是iPhone X
#define isiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)]?CGSizeEqualToSize(CGSizeMake(1125, 2436),[[UIScreen mainScreen] currentMode].size):NO)

@interface AriderTool : NSObject


+ (BOOL)isSystemVersionGreaterThan7;

+ (CGFloat)screenWidth;

+ (CGFloat)screenHeight;
@end
