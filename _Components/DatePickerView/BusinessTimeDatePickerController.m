//
//  BusinessTimeDatePickerController.m
//  hairdresser
//
//  Created by fallen on 16/6/13.
//
//

#import "_building_precompile.h"
#import "BusinessTimeDatePickerController.h"

static const CGFloat buttonContentViewHeightConstant = 44.f;
static const CGFloat buttonWidthConstant = 64.f;
static const CGFloat datePickerContentViewHeightConstant = 216.f;
static const CGFloat datePickerContentViewInvisiableVerticalConstant = buttonContentViewHeightConstant + datePickerContentViewHeightConstant;
static const CGFloat datePickerContentViewVisiableVerticalConstant = 0;

@interface BusinessTimeDatePickerController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *selectButton;

//@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *topBarContentView;
@property (nonatomic, strong) UIView *datePickerContentView;

@property (nonatomic, strong) UIPickerView *datePicker;

@property (nonatomic, strong) UIMotionEffectGroup *motionEffectGroup;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIWindow *originalKeyWindow;

@end

@implementation BusinessTimeDatePickerController

#pragma mark - Initialize

- (void)initViews {
    // 背景图
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.backgroundView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancel)];
    [_backgroundView addGestureRecognizer:tapRecognizer];
    
    // 日期选择的父视图
    self.datePickerContentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.datePickerContentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.datePickerContentView];
    
    // 选择器视图
    self.datePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.datePicker.layer.cornerRadius = 4;
    self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    self.datePicker.backgroundColor = [UIColor clearColor];
    self.datePicker.delegate = self;
    self.datePicker.dataSource = self;
    [self.datePickerContentView addSubview:self.datePicker];
    
    // 选择器的初始状态
    [self.datePicker selectRow:self.startIndex inComponent:0 animated:NO];
    self.endIndex = self.endIndex == 0 ? 1 : self.endIndex;
    [self.datePicker selectRow:self.endIndex-1 inComponent:1 animated:NO];
    
    // 取消、选择按钮的父视图
    self.topBarContentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.topBarContentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topBarContentView];
    
    // 取消、选择按钮
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.selectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.topBarContentView addSubview:self.cancelButton];
    
    [self.selectButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.selectButton addTarget:self action:@selector(onSelect) forControlEvents:UIControlEventTouchUpInside];
    self.selectButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.selectButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.selectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.topBarContentView addSubview:self.selectButton];
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(is_method_implemented(self.delegate, datePickerController:didCancel:), @"datePickerController:didCancel: 未实现");
    NSAssert(is_method_implemented(self.delegate, datePickerController:didSelectAtFrom:to:), @"datePickerController:didSelectAtFrom:to: 未实现");
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.masksToBounds = YES;
    
    [self initViews];
    
    [self applyViewConstraints];
    
    [self addMotionEffects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applyViewConstraints {
    // 背景图
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.bottom.equalTo(self.view.mas_bottom);
        make.trailing.equalTo(self.view.mas_trailing);
        make.top.equalTo(self.view.mas_top);
    }];
    
    // 选择器父视图
    [self.datePickerContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_bottom).mas_offset(datePickerContentViewInvisiableVerticalConstant);
        make.height.mas_equalTo(datePickerContentViewHeightConstant);
    }];
    
    // 选择器视图
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.datePickerContentView.mas_leading);
        make.bottom.equalTo(self.datePickerContentView.mas_bottom);
        make.trailing.equalTo(self.datePickerContentView.mas_trailing);
        make.top.equalTo(self.datePickerContentView.mas_top);
    }];
    
    // 按钮父视图
    [self.topBarContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.mas_equalTo(buttonContentViewHeightConstant);
        make.bottom.equalTo(self.datePickerContentView.mas_top).mas_offset(-0.5f);
    }];
    
    // 两个按钮
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.topBarContentView.mas_leading);
        make.width.mas_equalTo(buttonWidthConstant);
        make.height.equalTo(self.topBarContentView.mas_height);
        make.centerY.equalTo(self.topBarContentView.mas_centerY);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.topBarContentView.mas_trailing);
        make.width.mas_equalTo(buttonWidthConstant);
        make.height.equalTo(self.topBarContentView.mas_height);
        make.centerY.equalTo(self.topBarContentView.mas_centerY);
    }];
}

- (void)updateInViewConstraints {
    // 选择器父视图
    [self.datePickerContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).mas_offset(datePickerContentViewVisiableVerticalConstant);
    }];
}

- (void)updateOutViewConstraints {
    // 选择器父视图
    [self.datePickerContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).mas_offset(datePickerContentViewInvisiableVerticalConstant);
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Private

- (void)addMotionEffects {
    [self.view addMotionEffect:self.motionEffectGroup];
}

- (void)removeMotionEffects {
    [self.view removeMotionEffect:self.motionEffectGroup];
}

#pragma mark - Action handler

- (void)onCancel {
    [self.delegate datePickerController:self didCancel:YES];
    
    [self dismiss];
}

- (void)onSelect {
    [self.delegate datePickerController:self didSelectAtFrom:self.startIndex to:self.endIndex];
    
    [self dismiss];
}

#pragma mark - Public 

- (void)show {
    // 窗口设置
    {
        self.originalKeyWindow = [UIApplication sharedApplication].keyWindow;
        [self.window makeKeyAndVisible];
        
        // If we start in landscape mode also update the windows frame to be accurate
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            self.window.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
        }
    }
    
    // UIViewController config
    {
        [self viewWillAppear:YES];
        
        self.window.rootViewController = self;
        
        [self viewDidAppear:YES];
    }
    
    // Animate
    {
        self.topBarContentView.alpha = 0;
        self.datePickerContentView.alpha = 0;
        
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.backgroundView.alpha = 1;
            self.topBarContentView.alpha = 1;
            self.datePickerContentView.alpha = 1;
            
            [self updateInViewConstraints];
            
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

- (void)dismiss {
    [self updateOutViewConstraints];
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.backgroundView.alpha = 0;
        self.topBarContentView.alpha = 0;
        self.datePickerContentView.alpha = 0;
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self viewWillDisappear:YES];
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        [self didMoveToParentViewController:nil];
        [self viewDidDisappear:YES];
        
        [self.window resignKeyWindow];
        [self.originalKeyWindow makeKeyAndVisible];
        self.window = nil;
    }];
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.dataSource count]-1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return screen_width/2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 210 / 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [self.dataSource safeStringAtIndex:row];
    } else if (component == 1) {
        return [self.dataSource safeStringAtIndex:row+1];
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // 第二个component 比 第一个component 偏差一个
    if (component == 0) { // 从 00:00 ～ 22:00
        self.startIndex = row;
        
        if (self.startIndex >= self.endIndex) {
            [self.datePicker selectRow:self.startIndex inComponent:1 animated:YES];
        }
    } else if (component == 1) { // 从 1:00 ～ 23:00
        self.endIndex = row+1;
        
        if (self.endIndex <= self.startIndex) {
            [self.datePicker selectRow:self.endIndex-1 inComponent:0 animated:YES];
        }
    }
}

#pragma mark - Property

- (UIWindow *)window {
    if (!_window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.windowLevel = UIWindowLevelAlert;
    }
    
    return _window;
}


@end
