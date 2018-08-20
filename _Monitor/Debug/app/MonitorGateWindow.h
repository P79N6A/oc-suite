//
//  MonitorGateWindow.h
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

typedef void(^ MonitorGateHandler)(void);

@interface MonitorGateWindow : UIWindow

@property (nonatomic, copy) MonitorGateHandler gateHandler;

- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor animationColor:animationColor;

- (void)show;
- (void)dissmiss;

@end
