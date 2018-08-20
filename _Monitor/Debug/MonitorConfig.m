//
//  MonitorConfig.m
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "MonitorConfig.h"
#import "Monitor.h"

#pragma mark -

@interface MonitorHandler () {
    MonitorHandlerType _type;
    
    NSString *_vclass;
    
    Block _command;
    
    id _target;
    SEL _action;
}

@end

@implementation MonitorHandler

+ (instancetype)vclass:(NSString *)vclass {
    MonitorHandler *handler = [MonitorHandler new];
    
    handler->_type = _ViewController;
    handler->_vclass = vclass;
    
    return handler;
}

+ (instancetype)command:(Block)command {
    MonitorHandler *handler = [MonitorHandler new];
    
    handler->_type = _Block;
    handler->_command = command;
    
    return handler;
}

+ (instancetype)target:(id)target action:(SEL)action {
    MonitorHandler *handler = [MonitorHandler new];
    
    handler->_type = _TargetAction;
    handler->_target = target;
    handler->_action = action;
    
    return handler;
}

@end

@implementation UIViewController (MonitorHandler)

- (void)run:(MonitorHandler *)handler {
    if (handler.type == _ViewController) {
        NSString *classname = handler.vclass;
        
        if (classname) {
            Class class = NSClassFromString(classname);
            
            id viewController = [[class alloc] init];
            
            if ([viewController isKindOfClass:UIViewController.class]) {
                [[Monitor sharedInstance].navigation pushViewController:viewController animated:YES];
            }
        }
    } else if (handler.type == _Block) {
        if (handler && handler.command) {
            handler.command();
        }
    } else if (handler.type == _TargetAction) {
        if (handler && handler.target && [handler.target respondsToSelector:handler.action]) {
            [handler.target performSelector:handler.action];
        }
    }
}

@end

#pragma mark - 

@interface MonitorConfig () {
    NSMutableArray<NSString *> *_sectionTitles;
    
    NSMutableArray<NSString *> *_featureTitles;
    NSMutableArray<MonitorHandler *> *_featureViewControllers;
    
    NSMutableArray<NSString *> *_customTitles;
    NSMutableArray<MonitorHandler *> *_customViewControllers;
}

@end

@implementation MonitorConfig

- (instancetype)init {
    if (self = [super init]) {
        _sectionTitles = [NSMutableArray new];
        
        [_sectionTitles addObject:@"系统视图"];
        [_sectionTitles addObject:@"用户视图"];
        
        _featureTitles = [NSMutableArray new];
        _featureViewControllers = [NSMutableArray new];
        
        { // 监控器端的报告视图
            [_featureTitles addObject:@"离屏渲染报告"];
            [_featureViewControllers addObject:[MonitorHandler vclass:@"OffScreenReportView"]];
        }
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

- (void)set:(NSArray<NSString *> *)titles viewControllers:(NSArray<MonitorHandler *> *)classnames {
    _customTitles = [titles mutableCopy];
    _customViewControllers = [classnames mutableCopy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action handle

////////////////////////////////////////////////////////////////////////////////
#pragma mark - XXXDataSource / XXXDelegate methods


@end
