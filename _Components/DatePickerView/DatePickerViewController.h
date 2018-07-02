//
//  DatePickerViewController.h
//  QQing
//
//  Created by 李杰 on 5/4/15.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class DatePickerViewController;

extern DatePickerViewController *g_popupDatePickerVC;

typedef NS_ENUM(NSInteger, DatePickerViewType) {
    DatePickerViewTypeYearMonth,
    DatePickerViewTypeYearMonthDay,
} ;

@protocol DatePickerViewControllerDelegate <NSObject>

/**
 *  This method is called when user picked a certain date.
 *  @param vc       The date picking view controller that just finished picking a date.
 *  @param aDate    The picked date.
 */
- (void)datePickerViewController:(DatePickerViewController *)vc didPickDate:(NSDate *)aDate;

@optional

/**
 * This method is called when the user clicked the cancel button or taps the blank background erea.
 * @param vc        The date picking view controller that just finished picking a date.
 */
- (void)datePickerViewControllerDidCancel:(DatePickerViewController *)vc;

@end

@interface DatePickerViewController : UIViewController

@property (nonatomic, weak)     id<DatePickerViewControllerDelegate> delegate;
@property (nonatomic, assign)   BOOL backgroundTapsDisabled;
@property (nonatomic, strong)   UIColor *tintColor;
@property (nonatomic, strong)   UIColor *topBarBackgroundColor;
@property (nonatomic, strong)   UIColor *pickerBackgroundColor;

+ (id)datePickerControllerWithStartSelectDate:(NSDate *)startSelectDate;
+ (id)datePickerControllerWithStartSelectDate:(NSDate *)startSelectDate type:(DatePickerViewType)datePickerType;
+ (void)setTitleForSelectButton:(NSString *)title;
+ (void)setTitleForCancelButton:(NSString *)title;

- (void)show;
- (void)dismissWithAnimation:(BOOL)animated;

/**
 *  Class method for Default setting, CustomDatePickerView
 */
+ (void)setMinimumYear:(NSInteger)minimumYear;
+ (void)setMaximumYear:(NSInteger)maximumYear;

@end


/**
 * 内部类
 */
@interface CustomDatePickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) NSInteger minimumYear;         // The minimum year that a month picker can show
@property (nonatomic) NSInteger maximumYear;         // The maximum year that a month picker can show

- (id)initWithDate:(NSDate *)date type:(DatePickerViewType)type;
- (id)initWithDate:(NSDate *)date calendar:(NSCalendar *)calendar type:(DatePickerViewType)type;

@end

