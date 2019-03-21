//
//  AppDelegate.h
//  startup
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import <UIKit/UIKit.h>

// 这里引用大部分头文件依赖，所以其他页面代码，可以依赖 ‘AppDelegate.h’

#import <_Foundation/_Foundation.h>
#import <_Building/_Building.h>
#import <_Tool/_NetworkLit.h>
#import <_Tool/_Cache.h>
#import <YYModel/YYModel.h>
#import <SDWebImage/SDWebImageManager.h>
#import "UIImageView+WebCache.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

