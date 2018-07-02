//
//  SGGuideDispatcher.h
//  SGUserGuide
//
//  Created by soulghost on 5/7/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGGuideNode.h"
#import "SGGuideMaskView.h"

extern NSString * const SGGuideTrigNotification;

/**
 *  单个页面，多个引导的时候，使用该类别，Usage：
 
 *  1. 向引导分发器，设置多个节点
 *      SGGuideDispatcher *dp = [SGGuideDispatcher sharedDispatcher];
 *      [dp reset];
 *      dp.nodes = @[
 *      [SGGuideNode nodeWithController:[FirstViewController class] permitViewPath:@"addBtn" message:@"Please Click The Add Button And Choose Yes From the Alert." reverse:NO],
 *      [SGGuideNode nodeWithController:[FirstViewController class] permitViewPath:@"wrap.innerView" message:@"Please Click the Info Button" reverse:NO],
 *      [SGGuideNode nodeWithController:[SecondViewController class] permitViewPath:@"tabBarController.tabBar" message:@"Please Change To Third Page" reverse:NO],
 *      [SGGuideNode endNodeWithController:[ThirdViewController class]]
 *      ];
 
 *  2. 收到用户点击之后，分发下一个提示：
 *      SGGuideDispatcher *dp = [SGGuideDispatcher sharedDispatcher];
 *      [dp next];
 */
@interface SGGuideDispatcher : NSObject

@property (nonatomic, strong) NSArray<SGGuideNode *> *nodes;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, strong) UIColor *holeColor;
@property (nonatomic, weak) UIViewController *currentViewController;

+ (instancetype)sharedDispatcher;
- (void)next;
- (void)reset;

@end
