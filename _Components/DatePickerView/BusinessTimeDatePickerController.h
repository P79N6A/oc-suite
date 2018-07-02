//
//  BusinessTimeDatePickerController.h
//  hairdresser
//
//  Created by fallen on 16/6/13.
//
//  fallenink: 这个可以作为window实现弹出框的模板。

#import "BaseViewController.h"

#pragma mark -

@protocol BusinessTimeDatePickerControllerDelegate;

/**
 *  1. 不支持点击背景消失
 */
@interface BusinessTimeDatePickerController : BaseViewController

/**
 *  代理
 */
@property (nonatomic, weak) id<BusinessTimeDatePickerControllerDelegate> delegate;

/**
 *  设置初始开始索引
 */
@property (nonatomic, assign) NSUInteger startIndex;
/**
 *  设置初始结束索引
 */
@property (nonatomic, assign) NSUInteger endIndex;

@property (nonatomic, strong) NSArray<NSString *> *dataSource;

- (void)show;
- (void)dismiss;

@end

#pragma mark -

@protocol BusinessTimeDatePickerControllerDelegate <NSObject>

- (void)datePickerController:(BusinessTimeDatePickerController *)controller
                   didCancel:(BOOL)bCancel;

- (void)datePickerController:(BusinessTimeDatePickerController *)controller
             didSelectAtFrom:(NSUInteger)startIndex
                          to:(NSUInteger)endIndex;

@end