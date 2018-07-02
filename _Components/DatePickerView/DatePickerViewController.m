//
//  QQDatePickerViewController.m
//  QQing
//
//  Created by 李杰 on 5/4/15.
//
//

#import "_building_precompile.h"
#import "_building_tools.h"
#import "DatePickerViewController.h"
#import "WindowRootViewController.h"

DatePickerViewController *g_popupDatePickerVC;

/**
 *  Category of NSDate, Rounding
 */

@interface NSDate (Rounding)

- (NSDate *)dateByRoundingToMiniutes:(NSInteger)minutes;

/**
 * ...
 * Sunday:1, Monday:2, Tuesday:3, Wednesday:4, Friday:5, Saturday:6
 */
+ (NSString *)weekdayCnTextForWeekDayComponent:(NSInteger)week;

@end

@implementation NSDate (Rounding)

- (NSDate *)dateByRoundingToMiniutes:(NSInteger)minutes {
    NSTimeInterval absoluteTime = floor([self timeIntervalSinceReferenceDate]);
    NSTimeInterval minuteInterval = minutes*60;
    
    NSTimeInterval remainder = (absoluteTime - (floor(absoluteTime/minuteInterval)*minuteInterval));
    if(remainder < 60) {
        return self;
    } else {
        NSTimeInterval remainingSeconds = minuteInterval - remainder;
        return [self dateByAddingTimeInterval:remainingSeconds];
    }
}

static NSArray *weekCnText;

+ (NSString *)weekdayCnTextForWeekDayComponent:(NSInteger)week {
    weekCnText = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    
    if (week < 1 || week > 7) return @"";
    
    return [weekCnText objectAtIndex:week - 1];
}

@end

#pragma mark - 

@interface CustomDatePickerView ()

@property (nonatomic, strong) NSDate* date;          // The date represented by the month picker. The day component is ignored in QQDatePickerTypeYearMonth, and set to 1 when read.

@property (nonatomic, assign)   DatePickerViewType datePickerType;

@property (nonatomic, strong, readonly) NSCalendar *calendar;  // The calendar currently being used
@property (nonatomic) BOOL enableColourRow;          // A Boolean value that determines whether the current month & year are coloured

@property (nonatomic) BOOL wrapMonths;               // A Boolean value that determines whether the month wraps
@property (nonatomic) BOOL wrapDays;                 // A Boolean value that determines whether the day wraps
@property (nonatomic, getter = enableColourRow, setter = setEnableColourRow:) BOOL enableColorRow; // en-US alias for `enableColourRow`

@property (nonatomic, strong) UIFont *font;          // Font to be used for all rows.  Default: System Bold, size 24
@property (nonatomic, strong) UIColor *fontColour;   // Colour to be used for all "non coloured" rows.  Default: Black
@property (nonatomic, strong, getter = fontColour, setter = setFontColour:) UIColor *fontColor;    // en-US alias for `fontColour`

@property (nonatomic) NSInteger yearComponent;
@property (nonatomic) NSInteger monthComponent;
@property (nonatomic) NSInteger dayComponent;

@property (nonatomic, strong) NSArray* monthStrings;

@property (nonatomic, strong, readonly) NSDateFormatter* yearFormatter;
@property (nonatomic, strong, readonly) NSDateFormatter* monthFormatter;
@property (nonatomic, strong, readonly) NSDateFormatter* dayFormatter;

@end

#pragma mark -

#define RM_DATE_PICKER_HEIGHT_PORTRAIT 216
#define RM_DATE_PICKER_HEIGHT_LANDSCAPE 162

@interface DatePickerViewController ()

@property (nonatomic, assign)   DatePickerViewType datePickerType;

@property (nonatomic, strong)   UIWindow *window;
@property (nonatomic, strong)   UIWindow *originalKeyWindow;

@property (nonatomic, strong)   UIViewController *rootViewController;
@property (nonatomic, strong)   UIView *backgroundView;

@property (nonatomic, strong)   NSLayoutConstraint *pickerHeightConstraint;

@property (nonatomic, weak)     NSLayoutConstraint *xConstraint;
@property (nonatomic, weak)     NSLayoutConstraint *yConstraint;
@property (nonatomic, weak)     NSLayoutConstraint *widthConstraint;

@property (nonatomic, strong)   UIView *topBarContentView;
@property (nonatomic, strong)   UIView *datePickerContentView;

@property (nonatomic, strong)   CustomDatePickerView *datePicker;

@property (nonatomic, strong)   UIButton *cancelButton;
@property (nonatomic, strong)   UIButton *selectButton;

@property (nonatomic, strong)   UIMotionEffectGroup *motionEffectGroup;

@property (nonatomic, assign)   BOOL hasBeenDismissed;

@end

@implementation DatePickerViewController

#pragma mark - Life cycle

+ (id)datePickerControllerWithStartSelectDate:(NSDate *)startSelectDate {
    return [[DatePickerViewController alloc] initWithStartSelectDate:startSelectDate type:DatePickerViewTypeYearMonth];
}

+ (id)datePickerControllerWithStartSelectDate:(NSDate *)startSelectDate type:(DatePickerViewType)datePickerType {
    return [[DatePickerViewController alloc] initWithStartSelectDate:startSelectDate type:datePickerType];
}

- (id)initWithStartSelectDate:(NSDate *)startSelectDate type:(DatePickerViewType)datePickerType {
    if (self = [super init]) {
        self.datePickerType = datePickerType;
        [self initBottomViewWithStartSelectDate:startSelectDate];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.masksToBounds = YES;
    
    [self initSubviewsLayout];
    
    [self.view addSubview:self.topBarContentView];
    [self.view addSubview:self.datePickerContentView];
    
    [self initUIConstraint];
    
    [self initDatePickerParam];
    
    if (self.topBarBackgroundColor) {
        self.topBarContentView.backgroundColor = self.topBarBackgroundColor;
    }
    if (self.pickerBackgroundColor) {
        self.datePickerContentView.backgroundColor = self.pickerBackgroundColor;
    }
    
    [self addMotionEffects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Class

static NSString *_selectTitle = @"选择";
static NSString *_cancelTitle = @"取消";

+ (void)setTitleForSelectButton:(NSString *)title {
    _selectTitle = title;
}

+ (void)setTitleForCancelButton:(NSString *)title {
    _cancelTitle = title;
}

+ (NSString *)titleForSelectButton {
    return _selectTitle;
}

+ (NSString *)titleForCancelButton {
    return _cancelTitle;
}

static NSInteger _minimumYear = 0;
static NSInteger _maximumYear = NSIntegerMax;

+ (void)setMinimumYear:(NSInteger)minimumYear {
    _minimumYear = minimumYear;
}

+ (void)setMaximumYear:(NSInteger)maximumYear {
    _maximumYear = maximumYear;
}

#pragma mark - Public methods

- (void)show {
    self.rootViewController = self.window.rootViewController;
    
    {
        self.originalKeyWindow = [UIApplication sharedApplication].keyWindow;
        [self.window makeKeyAndVisible];
        
        // If we start in landscape mode also update the windows frame to be accurate
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            self.window.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
        }
    }
    
    {
        self.backgroundView.alpha = 0;
        [self.rootViewController.view addSubview:self.backgroundView];
        
        [self.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    }
    
    [self willMoveToParentViewController:self.rootViewController];
    [self viewWillAppear:YES];
    
    [self.rootViewController addChildViewController:self];
    [self.rootViewController.view addSubview:self.view];
    
    [self viewDidAppear:YES];
    [self didMoveToParentViewController:self.rootViewController];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            self.pickerHeightConstraint.constant = RM_DATE_PICKER_HEIGHT_LANDSCAPE;
        } else {
            self.pickerHeightConstraint.constant = RM_DATE_PICKER_HEIGHT_PORTRAIT;
        }
    }
    
    self.xConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    self.yConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    [self.rootViewController.view addConstraint:self.xConstraint];
    [self.rootViewController.view addConstraint:self.yConstraint];
    [self.rootViewController.view addConstraint:self.widthConstraint];
    
    [self.rootViewController.view setNeedsUpdateConstraints];
    [self.rootViewController.view layoutIfNeeded];
    
    [self.rootViewController.view removeConstraint:self.yConstraint];
    self.yConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.rootViewController.view addConstraint:self.yConstraint];
    
    [self.rootViewController.view setNeedsUpdateConstraints];
    
    {
        self.topBarContentView.alpha = 0;
        self.datePickerContentView.alpha = 0;
        
        //[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.8 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.backgroundView.alpha = 1;
            self.topBarContentView.alpha = 1;
            self.datePickerContentView.alpha = 1;
            
            [self.rootViewController.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            g_popupDatePickerVC = self;
        }];
    }
}

- (void)dismissWithAnimation:(BOOL)animated {
    if (animated) {
        [self.rootViewController.view removeConstraint:self.yConstraint];
        self.yConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.rootViewController.view addConstraint:self.yConstraint];
        
        [self.rootViewController.view setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.backgroundView.alpha = 0;
            self.topBarContentView.alpha = 0;
            self.datePickerContentView.alpha = 0;
            
            [self.rootViewController.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self willMoveToParentViewController:nil];
            [self viewWillDisappear:YES];
            
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            
            [self didMoveToParentViewController:nil];
            [self viewDidDisappear:YES];
            
            [self.backgroundView removeFromSuperview];
            [self.window resignKeyWindow];
            [self.originalKeyWindow makeKeyAndVisible];
            self.window = nil;
            g_popupDatePickerVC = nil;
            self.hasBeenDismissed = NO;
        }];
    } else {
        [self willMoveToParentViewController:nil];
        [self viewWillDisappear:YES];
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        [self didMoveToParentViewController:nil];
        [self viewDidDisappear:YES];
        
        [self.backgroundView removeFromSuperview];
        [self.window resignKeyWindow];
        [self.originalKeyWindow makeKeyAndVisible];
        self.window = nil;
        g_popupDatePickerVC = nil;
        self.hasBeenDismissed = NO;
    }
}

#pragma mark - Initialization

- (void)initBottomViewWithStartSelectDate:(NSDate *)startSelectDate {
    self.datePicker = [[CustomDatePickerView alloc] initWithDate:startSelectDate type:self.datePickerType];
    self.datePicker.tintColor = self.tintColor;
    self.datePicker.layer.cornerRadius = 4;
    self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self initDatePickerParam];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.selectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [self.cancelButton setTitle:[DatePickerViewController titleForCancelButton] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(didPressedOnCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.cancelButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.selectButton setTitle:[DatePickerViewController titleForSelectButton] forState:UIControlStateNormal];
    [self.selectButton addTarget:self action:@selector(didPressedOnDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    self.selectButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.selectButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    self.selectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)initSubviewsLayout {
    self.topBarContentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.datePickerContentView = [[UIView alloc] initWithFrame:CGRectZero];
    
    {
        [self.topBarContentView addSubview:self.cancelButton];
        [self.topBarContentView addSubview:self.selectButton];
        
        [self.datePickerContentView addSubview:self.datePicker];

        self.topBarContentView.backgroundColor = [UIColor whiteColor];
        self.datePickerContentView.backgroundColor = color_with_rgb(248, 248, 248);
    }
    
    self.datePickerContentView.clipsToBounds = YES;
    self.datePickerContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.topBarContentView.clipsToBounds = YES;
    self.topBarContentView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)initUIConstraint {
    UIView *topBarContentView = self.topBarContentView;
    UIView *datePickerContentView = self.datePickerContentView;
    UIButton *cancel = self.cancelButton;
    UIButton *select = self.selectButton;
    CustomDatePickerView *picker = self.datePicker;
    
    NSDictionary *bindingsDict = NSDictionaryOfVariableBindings(topBarContentView, datePickerContentView, cancel, select, picker);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[topBarContentView]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[datePickerContentView]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[topBarContentView(40)]-(0)-[datePickerContentView]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    self.pickerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.datePickerContentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:RM_DATE_PICKER_HEIGHT_PORTRAIT];
    [self.view addConstraint:self.pickerHeightConstraint];
    
    [self.topBarContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(15)-[cancel(46)]" options:0 metrics:nil views:bindingsDict]];
    [self.topBarContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[select(46)]-(15)-|" options:0 metrics:nil views:bindingsDict]];
    [self.topBarContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[cancel(30)]-(5)-|" options:0 metrics:nil views:bindingsDict]];
    [self.topBarContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[select(30)]-(5)-|" options:0 metrics:nil views:bindingsDict]];
    
    [self.datePickerContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[picker]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.datePickerContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[picker]-(0)-|" options:0 metrics:nil views:bindingsDict]];
}

- (void)initDatePickerParam {
    self.datePicker.minimumYear = _minimumYear;
    self.datePicker.maximumYear = _maximumYear;
}

#pragma mark - Action handle

- (IBAction)didPressedOnDoneButton:(id)sender {
    if(!self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;
        
        // Get date selected
        [self.delegate datePickerViewController:self didPickDate:self.datePicker.date];

        [self dismissWithAnimation:YES];
    }
}

- (IBAction)didPressedOnCancelButton:(id)sender {
    if(!self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;
        
        if ([self.delegate respondsToSelector:@selector(datePickerViewControllerDidCancel:)]) {
            [self.delegate datePickerViewControllerDidCancel:self];
        }
        
        [self dismissWithAnimation:YES];
    }
}

- (IBAction)didTappedOnBackgroundView:(UIGestureRecognizer *)sender {
    if(!self.backgroundTapsDisabled && !self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;
        
        if ([self.delegate respondsToSelector:@selector(datePickerViewControllerDidCancel:)]) {
            [self.delegate datePickerViewControllerDidCancel:self];
        }
        
        [self dismissWithAnimation:YES];
    }
}

#pragma mark - Properties

- (UIMotionEffectGroup *)motionEffectGroup {
    if(!_motionEffectGroup) {
        UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalMotionEffect.minimumRelativeValue = @(-10);
        verticalMotionEffect.maximumRelativeValue = @(10);
        
        UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-10);
        horizontalMotionEffect.maximumRelativeValue = @(10);
        
        _motionEffectGroup = [UIMotionEffectGroup new];
        _motionEffectGroup.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    }
    
    return _motionEffectGroup;
}

- (UIWindow *)window {
    if (!_window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.windowLevel = UIWindowLevelStatusBar;
        
        WindowRootViewController *rootViewController = [WindowRootViewController createRootViewControllerWithStatusBarStyle:[UIApplication sharedApplication].statusBarStyle];
        _window.rootViewController = rootViewController;
    }
    
    return _window;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTappedOnBackgroundView:)];
        [_backgroundView addGestureRecognizer:tapRecognizer];
    }
    
    return _backgroundView;
}

- (void)setTintColor:(UIColor *)newTintColor {
    if(_tintColor != newTintColor) {
        _tintColor = newTintColor;

        self.cancelButton.tintColor = newTintColor;
        self.selectButton.tintColor = newTintColor;
        
        self.datePicker.tintColor = newTintColor;
    }
}

- (void)setTopBarBackgroundColor:(UIColor *)newBackgroundColor {
    if(_topBarBackgroundColor != newBackgroundColor) {
        _topBarBackgroundColor = newBackgroundColor;
        
        if ([self isViewLoaded]) {
            self.topBarContentView.backgroundColor = newBackgroundColor;
        }
    }
}

- (void)setPickerBackgroundColor:(UIColor *)newBackgroundColor {
    if(_pickerBackgroundColor != newBackgroundColor) {
        _pickerBackgroundColor = newBackgroundColor;
        
        if([self isViewLoaded]) {
            self.datePickerContentView.backgroundColor = newBackgroundColor;
        }
    }
}

#pragma mark - Utility

- (void)addMotionEffects {
    [self.view addMotionEffect:self.motionEffectGroup];
}

- (void)removeMotionEffects {
    [self.view removeMotionEffect:self.motionEffectGroup];
}
        
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

#pragma mark ===================================================
#pragma mark >>>>>>>>>>>>>>>>>>>>>>内部类<<<<<<<<<<<<<<<<<<<<<<<<
#pragma mark ===================================================

@implementation CustomDatePickerView

static const NSInteger _monthRowMultiplier = 340;
static const NSInteger _dayRowMultiplier = 20;
static const NSInteger _defaultMinimumYear = 1;
static const NSInteger _defaultMaximumYear = 99999;
static const NSCalendarUnit _dateComponentFlags = NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitWeekday;

#pragma mark - Initialization

- (id)initWithDate:(NSDate *)date type:(DatePickerViewType)type {
    self = [self initWithDate:date calendar:[NSCalendar currentCalendar] type:type];
    return self;
}

- (id)initWithDate:(NSDate *)date calendar:(NSCalendar *)calendar type:(DatePickerViewType)type {
    if (self = [super init]) {
        _calendar = calendar;
        _datePickerType = type;
        
        [self prepare];
        [self setDate:date];
        
        self.showsSelectionIndicator = YES;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _datePickerType = DatePickerViewTypeYearMonth;
        _minimumYear = _defaultMinimumYear;
        _maximumYear = _defaultMaximumYear;
        
        [self prepare];
        if (!_calendar) {
            _calendar = [NSCalendar currentCalendar];
        }
        
        if (!_date) {
            [self setDate:[NSDate date]];
        }
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _datePickerType = DatePickerViewTypeYearMonth;
        _minimumYear = _defaultMinimumYear;
        _maximumYear = _defaultMaximumYear;
        
        [self prepare];
        if (!_calendar)
            _calendar = [NSCalendar currentCalendar];
        if (!_date)
            [self setDate:[NSDate date]];
    }
    
    return self;
}

#pragma mark - Private Methods

- (NSInteger)yearFromRow:(NSUInteger)row {
    NSInteger minYear = _defaultMinimumYear;
    
    if (self.minimumYear) {
        minYear = self.minimumYear;
    }
    
    return row + minYear;
}

- (NSUInteger)rowFromYear:(NSInteger)year {
    NSInteger minYear = _defaultMinimumYear;
    
    if (self.minimumYear) {
        minYear = self.minimumYear;
    }
    
    return year - minYear;
}

- (void)prepare {
    self.dataSource = self;
    self.delegate = self;
    
    self.enableColourRow = YES;
    self.wrapMonths = YES;
    self.wrapDays = YES;
    
    self.font = [UIFont boldSystemFontOfSize:22.0f];
    self.fontColor = [UIColor blackColor];
}

#pragma mark - Properties

- (id<UIPickerViewDelegate>)delegate {
    return self;
}

- (void)setDelegate:(id<UIPickerViewDelegate>)delegate {
    if ([delegate isEqual:self]) {
        [super setDelegate:delegate];
    }
}

- (id<UIPickerViewDataSource>)dataSource {
    return self;
}

- (void)setDataSource:(id<UIPickerViewDataSource>)dataSource {
    if ([dataSource isEqual:self]) {
        [super setDataSource:dataSource];
    }
}

- (NSInteger)yearComponent {
    return 0;
}

- (NSInteger)monthComponent {
    return 1;
}

- (NSInteger)dayComponent {
    return 2;
}

- (NSDateFormatter *)yearFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.calendar = self.calendar;
        formatter.dateFormat = @"y年";
    });
    return formatter;
}

- (NSDateFormatter *)monthFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.calendar = self.calendar;
        formatter.dateFormat = @"M月";
    });
    return formatter;
}

- (NSDateFormatter *)dayFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.calendar = self.calendar;
        formatter.dateFormat = @"d日";
    });
    return formatter;
}

- (NSArray *)monthStrings {
    if (!_monthStrings) {
        NSMutableArray *arrayToSet = [NSMutableArray array];
        for (int i = 1; i <= 12; i++) {
            [arrayToSet addObject:[NSString stringWithFormat:@"%zd月", i]];
        }
        
        _monthStrings = [arrayToSet copy];
    }
    
    return _monthStrings;
}

- (void)setMinimumYear:(NSInteger)minimumYear {
    NSDate* currentDate = self.date;
    NSDateComponents* components = [self.calendar components:_dateComponentFlags fromDate:currentDate];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    if (components.year < minimumYear) {
        components.year = minimumYear;
    }
    
    _minimumYear = minimumYear;
    [self reloadAllComponents];
    [self setDate:[self.calendar dateFromComponents:components]];
}

- (void)setMaximumYear:(NSInteger)maximumYear {
    NSDate* currentDate = self.date;
    NSDateComponents* components = [self.calendar components:_dateComponentFlags fromDate:currentDate];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    if (components.year > maximumYear) {
        components.year = maximumYear;
    }
    
    _maximumYear = maximumYear;
    [self reloadAllComponents];
    [self setDate:[self.calendar dateFromComponents:components]];
}

- (void)setWrapMonths:(BOOL)wrapMonths {
    _wrapMonths = wrapMonths;
    [self reloadAllComponents];
}

- (void)setWrapDays:(BOOL)wrapDays {
    _wrapDays = wrapDays;
    [self reloadAllComponents];
}

- (void)setDate:(NSDate *)date {
    NSDateComponents* components = [self.calendar components:_dateComponentFlags fromDate:date];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    if (self.minimumYear && components.year < self.minimumYear) {
        components.year = self.minimumYear;
    } else if (self.maximumYear && components.year > self.maximumYear) {
        components.year = self.maximumYear;
    }
    
    [self selectRow:[self rowFromYear:components.year] inComponent:self.yearComponent animated:NO];
    
    if (self.wrapMonths) {
        NSInteger monthMidpoint = self.monthStrings.count * (_monthRowMultiplier / 2);
        
        [self selectRow:(components.month - 1 + monthMidpoint) inComponent:self.monthComponent animated:NO];
    } else {
        [self selectRow:(components.month - 1) inComponent:self.monthComponent animated:NO];
    }
    
    if (self.datePickerType == DatePickerViewTypeYearMonthDay) {
        if (self.wrapDays) {
            NSInteger daysCount = [NSDate numberOfDaysInMonth:components.month year:components.year];
            NSInteger dayMidpoint = daysCount * (_dayRowMultiplier / 2);
            
            [self selectRow:(components.day - 1 + dayMidpoint) inComponent:self.dayComponent animated:NO];
        } else {
            [self selectRow:(components.day - 1) inComponent:self.dayComponent animated:NO];
        }
    } else {
        components.day = 1;
    }
    
    _date = [self.calendar dateFromComponents:components];
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.year = [self yearFromRow:[self selectedRowInComponent:self.yearComponent]];
    components.month = 1 + ([self selectedRowInComponent:self.monthComponent] % self.monthStrings.count);
    if (self.datePickerType == DatePickerViewTypeYearMonthDay) {
        NSDateComponents* oldComponents = [self.calendar components:_dateComponentFlags fromDate:self.date];
        NSInteger oldDaysCount = [NSDate numberOfDaysInMonth:oldComponents.month year:oldComponents.year];
        NSInteger oldSelectedDay = [self selectedRowInComponent:self.dayComponent] % oldDaysCount + 1;
        
        if ((component == self.yearComponent) || (component == self.monthComponent)) {
            NSInteger newDaysCount = [NSDate numberOfDaysInMonth:components.month year:components.year];
            
            if (oldSelectedDay <= newDaysCount) {
                components.day = oldSelectedDay;
            } else {
                components.day = newDaysCount;
            }
        } else {
            components.day = oldSelectedDay;
        }
    } else {
        components.day = 1;
    }
    
    [self reloadAllComponents];
    [self setDate:[self.calendar dateFromComponents:components]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return (self.datePickerType == DatePickerViewTypeYearMonth) ? 2 : 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == self.yearComponent) {
        NSInteger maxYear = _defaultMaximumYear;
        if (self.maximumYear) {
            maxYear = self.maximumYear;
        }
        
        return [self rowFromYear:maxYear] + 1;
    } else if (component == self.monthComponent) {
        if (self.wrapMonths) {
            return _monthRowMultiplier * self.monthStrings.count;
        } else {
            return self.monthStrings.count;
        }
    } else if (component == self.dayComponent) {
        NSDateComponents* components = [self.calendar components:_dateComponentFlags fromDate:self.date];
        NSInteger daysCount = [NSDate numberOfDaysInMonth:components.month year:components.year];
        
        if (self.wrapDays) {
            return _dayRowMultiplier * daysCount;
        } else {
            return daysCount;
        }
    } else {
        assert(false);
        return 0;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (self.datePickerType == DatePickerViewTypeYearMonth) {
        return self.width / 2;
    } else {
        if (component == self.yearComponent) {
            return self.width / 3;
        } else if (component == self.monthComponent) {
            return self.width / 6;
        } else {
            return self.width / 2;
        }
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    CGFloat width = [self pickerView:self widthForComponent:component];
    CGRect frame = CGRectMake(0.0f, 0.0f, width, 45.0f);
    
    UILabel* label = [[UILabel alloc] initWithFrame:frame];

    NSDateFormatter* formatter = nil;
    
    if (component == self.yearComponent) {
        formatter = self.yearFormatter;
        
        label.text = [NSString stringWithFormat:@"%zd年", [self yearFromRow:row]];
        label.textAlignment = NSTextAlignmentCenter;
    } else if (component == self.monthComponent) {
        formatter = self.monthFormatter;
        
        label.text = [self.monthStrings objectAtIndex:(row % self.monthStrings.count)];
        label.textAlignment = NSTextAlignmentCenter;
    } else {  //  self.dayComponent
        formatter = self.dayFormatter;
        
        NSDateComponents* components = [self.calendar components:_dateComponentFlags fromDate:self.date];
        NSInteger daysCount = [NSDate numberOfDaysInMonth:components.month year:components.year];
        NSInteger dayToUse = (row % daysCount) + 1;
        
        NSDateComponents* todayComponents = [self todayComponents];
        if ((todayComponents.year == components.year)
            && (todayComponents.month == components.month)
            && (todayComponents.day == dayToUse)) {
            label.text = [NSString stringWithFormat:@"%zd日 今天", dayToUse];
        } else {
            NSDateComponents* itemComponents = [[NSDateComponents alloc] init];
            itemComponents.year = components.year;
            itemComponents.month = components.month;
            itemComponents.day = dayToUse;
            NSDate *itemDate = [self.calendar dateFromComponents:itemComponents];
            NSString *weekStr = [NSDate weekdayCnTextForWeekDayComponent:[itemDate weekday]];
            label.text = [NSString stringWithFormat:@"%zd日 周%@", dayToUse, weekStr];
        }
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    label.font = self.font;
    label.backgroundColor = [UIColor clearColor];
    label.shadowOffset = CGSizeMake(0.0f, 0.1f);
    label.shadowColor = [UIColor whiteColor];
    label.textColor = self.fontColour;
    
    if (self.enableColourRow && [label.text hasPrefix:[formatter stringFromDate:[NSDate date]]]) {
        label.textColor = [self.tintColor copy];
    }
    
    return label;
}

#pragma mark - Private methods

- (NSDateComponents *)todayComponents {
    static NSDateComponents *todayComponents;
    
    if (!todayComponents) {
        todayComponents = [self.calendar components:_dateComponentFlags fromDate:[NSDate date]];
    }
    
    return todayComponents;
}

@end
