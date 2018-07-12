//
//  ABShareView.h
//  ABPicBrower
//
//  Created by 杜亚伟 on 2017/4/19.
//  Copyright © 2017年 杜亚伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABShareView : UIView

@property (nonatomic,copy) void(^clickBlock)(NSString*);


@end
