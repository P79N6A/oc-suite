//
//  MonitorConfig.h
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Defines

typedef enum : NSUInteger {
    _ViewController,
    _Block,
    _TargetAction,
} MonitorHandlerType;

@interface MonitorHandler : NSObject

@property (nonatomic, assign, readonly) MonitorHandlerType type;

@property (nonatomic, readonly) NSString *vclass;

@property (nonatomic, readonly) Block command;

@property (nonatomic, readonly) id target;
@property (nonatomic, readonly) SEL action;

+ (instancetype)vclass:(NSString *)vclass; // _ViewController
+ (instancetype)command:(Block)command; // _Block
+ (instancetype)target:(id)target action:(SEL)action;

@end

@interface UIViewController (MonitorHandler)

- (void)run:(MonitorHandler *)handler;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interfaces

@interface MonitorConfig : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

@property (nonatomic, readonly) NSArray<NSString *> *sectionTitles;

@property (nonatomic, readonly) NSArray<NSString *> *featureTitles;
@property (nonatomic, readonly) NSArray<MonitorHandler *> *featureViewControllers;

@property (nonatomic, readonly) NSArray<NSString *> *customTitles;
@property (nonatomic, readonly) NSArray<MonitorHandler *> *customViewControllers;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Instance Methods

- (void)set:(NSArray<NSString *> *)titles viewControllers:(NSArray<MonitorHandler *> *)classnames;

@end
