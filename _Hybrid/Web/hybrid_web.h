//
//  hybrid_web.h
//  hybrid-web
//
//  Created by 7 on 25/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for hybrid_web.
FOUNDATION_EXPORT double hybrid_webVersionNumber;

//! Project version string for hybrid_web.
FOUNDATION_EXPORT const unsigned char hybrid_webVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <hybrid_web/PublicHeader.h>

#import "_web_browser.h"
#import "_web_config.h"
#import "_web_page.h"

//self.hudView = [[JHUD alloc]initWithFrame:self.view.bounds];
//
//- (void)circleJoinAnimation {
//    self.hudView.messageLabel.text = @"Hello ,this is a circleJoin animation";
//    self.hudView.indicatorForegroundColor = JHUDRGBA(60, 139, 246, .5);
//    self.hudView.indicatorBackGroundColor = JHUDRGBA(185, 186, 200, 0.3);
//    [self.hudView showAtView:self.view hudType:JHUDLoadingTypeCircleJoin]; }
//- (void)gifAnimations {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"loadinggif3" ofType:@"gif"];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//
//    self.hudView.gifImageData = data;
//    self.hudView.indicatorViewSize = CGSizeMake(110, 110); // Maybe you can try to use (100,250);😂
//    self.hudView.messageLabel.text = @"Hello ,this is a gif animation";
//    [self.hudView showAtView:self.view hudType:JHUDLoadingTypeGifImage]; }
//- (void)failure {
//    self.hudView.indicatorViewSize = CGSizeMake(100, 100);
//    self.hudView.messageLabel.text = @"Can't get data, please make sure the interface is correct !";
//    [self.hudView.refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
//    self.hudView.customImage = [UIImage imageNamed:@"null"];
//
//    [self.hudView showAtView:self.view hudType:JHUDLoadingTypeFailure]; }
//- (void)viewWillLayoutSubviews { // 横竖屏适配的话，在此更新hudView的frame。
//    [super viewWillLayoutSubviews];
//    CGFloat padding = 0;
//    self.hudView.frame = CGRectMake(padding,padding,self.view.frame.size.width - padding*2,self.view.frame.size.height - padding*2); }
//
//- (void)hide { [self.hudView hide]; }

#import "_web_hud.h"
