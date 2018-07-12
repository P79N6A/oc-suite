//
//  ShareActivityVC.h
//  component
//
//  Created by  on 15/12/2.
//  Copyright © 2015年 OpenTeam. All rights reserved.
//

#import "_greats.h"
#import "ShareParamBuilder.h"
#import "BaseViewController.h"

#pragma mark -
 
@class ShareActivityVC;

@interface ShareActivityVC : BaseViewController

@property (nonatomic, strong) NSString *eventCode;

@singleton( ShareActivityVC )

/**
 *  用ShareParamBuilder初始化
 */
- (void)shareWithWithParamBuilder:(ShareParamBuilder *)paramBuilder
                   shareViewTitle:(NSString *)title;
- (void)dismissSharePopup;

@end
