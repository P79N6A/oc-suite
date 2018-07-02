
#import "_Foundation.h"
#import "Masonry.h"
#import "UIView+Extension.h"
#import "BaseViewController.h"
#import "BaseViewController+Private.h"
#import "UIViewController+Extension.h"

// ----------------------------------
// class implementation
// ----------------------------------

#pragma mark - External

static NSString *backButtonImageName = @"buckbutton";

#pragma mark - BaseViewController


@interface BaseViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, copy) UIColor *originNavBarColor;
@property (nonatomic, copy) UIColor *originNavTitleColor;

@property (nonatomic, assign) BOOL hasPreferNavBarColor;
@property (nonatomic, assign) BOOL hasPreferNavTitleColor;

@property (nonatomic, assign) BOOL alreadyInitialized;

@end

@implementation BaseViewController

@def_prop_class( UIColor *, preferredNavigationBarColor, setPreferredNavigationBarColor )
@def_prop_class( UIStatusBarStyle, userPreferredStatusBarStyle, setUserPreferredStatusBarStyle )
@def_prop_class( UIColor *, preferredViewBackgroundColor, setPreferredViewBackgroundColor )

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        [self initDefault];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initDefault];
    }
    
    return self;
}

- (NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    return _dataArr;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initDefault];
    }
    
    return self;
}

- (void)initDefault {
    if (self.alreadyInitialized) {
        return;
    }
    self.hideKeyboardWhenEndEditing = YES;
    
    [self hookSelector:@selector(viewDidLoad) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
//        UIViewController *viewController = aspectInfo.instance;
    } error:nil];
    self.alreadyInitialized = YES;
}

- (void)uinitDefault {
    [self unobserveAllNotifications];
    
    LOG(@"%@ quit", NSStringFromClass(self.class));
}

#pragma mark - Play with view model: overrided if needed

- (instancetype)initWithViewModel:(id)viewModel {
    if (self = [super init]) {
        [self initDefault];
    }
    
    return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![self isNavigationRootController]) {
        [self setNavLeftItemWithImage:backButtonImageName target:self action:@selector(onBack)];
    }

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if ([self navigationBarLeftButtonHiddenWhenAppear]) {
        [self clearNavLeftItem];
    }
    
    self.view.backgroundColor = self.class.preferredViewBackgroundColor;
    
#if 0 // 切换tab的时候动画
    [self injectSwipeToTabGesture];
#endif
    
    [self aspect_doLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    SEL selector = @selector(navigationBarHiddenWhenAppear);
    BOOL overrided = [self.class instanceMethodForSelector:selector] != [BaseViewController.class instanceMethodForSelector:selector];
    if (![self isMemberOfClass:[BaseViewController class]]
        && overrided) {
        [self.navigationController setNavigationBarHidden:[self navigationBarHiddenWhenAppear] animated:animated];
    }
    
    UIColor *preferNavBarColor = [self preferNavBarBackgroundColor];
    if (preferNavBarColor) {
        self.hasPreferNavBarColor = YES;
        self.originNavBarColor = self.navBarColor;
        self.navBarColor = preferNavBarColor;
    }
    
    UIColor *preferNavBarNormalTitleColor = [self preferNavBarNormalTitleColor];
    if (preferNavBarNormalTitleColor) {
        self.hasPreferNavTitleColor = YES;
        self.originNavTitleColor = self.navTitleColor;
        self.navTitleColor = preferNavBarNormalTitleColor;
        self.navLeftItemNormalTitleColor = preferNavBarNormalTitleColor;
        self.navRightItemNormalTitleColor = preferNavBarNormalTitleColor;
    }
    
    UIColor *preferNavItemHighlightedTitleColor = [self preferNavBarHighlightedTitleColor];
    if (preferNavItemHighlightedTitleColor) {
        self.navItemHighlightedTitleColor = preferNavItemHighlightedTitleColor;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //解决手势返回失效的问题
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }else{
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self aspect_doAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (![self isMemberOfClass:[BaseViewController class]] &&
        is_method_overrided(self.class, BaseViewController.class, @selector(navigationBarHiddenWhenDisappear))) {
        [self.navigationController setNavigationBarHidden:[self navigationBarHiddenWhenDisappear] animated:animated];
    }
    
    if (self.hasPreferNavBarColor) {
        self.navBarColor = self.originNavBarColor;
    }
    
    if (self.hasPreferNavTitleColor) {
        self.navTitleColor = self.originNavTitleColor;
        self.navLeftItemNormalTitleColor = self.originNavBarColor;
        self.navRightItemNormalTitleColor = self.originNavBarColor;
    }
}

- (void)dealloc {
    [self uinitDefault];
    
    [self aspect_doDealloc];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    /**
     *  隐藏键盘
     */
    if (self.hideKeyboardWhenEndEditing) {
        [self.view endEditing:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bindViewModel:(id)vm {
    // do nothing
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Use aspect hook

- (void)aspect_doLoad {
    
}

- (void)aspect_doAppear {
    
}

- (void)aspect_doDealloc {
    
}

#pragma mark - Virtual methods

- (void)applyViewConstraints {
    // Do nothing...
}

- (void)updateVCviewsConstraints {
    
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

#pragma mark - NavigationBar style

- (BOOL)navigationBarHiddenWhenAppear {
    return NO;
}

- (BOOL)navigationBarHiddenWhenDisappear {
    return NO;
}

- (BOOL)navigationBarLeftButtonHiddenWhenAppear {
    return NO;
}

- (UIColor *)preferNavBarBackgroundColor {
    return [BaseViewController preferredNavigationBarColor];
}

- (UIColor *)preferNavBarNormalTitleColor {
    return nil;
}

- (UIColor *)preferNavBarHighlightedTitleColor {
    return nil;
}

#pragma mark - Status style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return BaseViewController.userPreferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    _statusBarHidden = statusBarHidden;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

#pragma mark - Utility

- (BOOL)isNavigationRootController {
    if (!self.navigationController ||
        !self.navigationController.viewControllers ||
        ![self.navigationController.viewControllers count]) {
        return YES;
    }
    
    return [self.navigationController.viewControllers.firstObject isEqual:self];
}

- (BOOL)isVisibleEx {
    return (self.isViewLoaded && self.view.window);
}

- (BOOL)isPresent {
    return ![self isPush];
}

- (BOOL)isPush {
    if (self.navigationController) { // 首先要有Navigation，如果自己定义独占，一定要记得重写这里
        NSArray *viewcontrollers = self.navigationController.viewControllers;
        if (viewcontrollers.count > 1) {
            if ([viewcontrollers objectAtIndex:viewcontrollers.count-1] == self) {
                return YES;
            }
        }
    }
    
    return NO;
}

//显示系统自带的菊花
- (void)showLoadingIndicator{
    [self.loadingIndicator bringToFront];
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
}

- (void)hideLoadingIndicator{
    [self.loadingIndicator stopAnimating];
    self.loadingIndicator.hidden = YES;
}


#pragma mark - DataBinder

- (void)bindViewModel {
    LOG(@"Warning: 该方法应该被覆盖！");
}

#pragma mark - Getter

- (UIActivityIndicatorView*)loadingIndicator {
    if (_loadingIndicator == nil) {
        _loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.view addSubview:_loadingIndicator];
        [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
    }
    return _loadingIndicator;
}

#pragma mark - tabbed switch

- (void)injectSwipeToTabGesture {
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedRightButton:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    [self.view addGestureRecognizer:swipeLeft];
    
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLeftButton:)];
    
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.view addGestureRecognizer:swipeRight];
}

- (void)tappedRightButton:(id)sender {
    NSUInteger selectedIndex = [self.tabBarController selectedIndex];
    NSArray *aryViewController = self.tabBarController.viewControllers;
    
    if (selectedIndex < aryViewController.count - 1) {
        UIView *fromView = [self.tabBarController.selectedViewController view];
        UIView *toView = [[self.tabBarController.viewControllers objectAtIndex:selectedIndex + 1] view];
        
        [UIView transitionFromView:fromView toView:toView duration:0.5f options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            
            if (finished) {
                [self.tabBarController setSelectedIndex:selectedIndex + 1];
            }
        }];
    }
}

- (void)tappedLeftButton:(id)sender {
    NSUInteger selectedIndex = [self.tabBarController selectedIndex];
    
    if (selectedIndex > 0) {
        UIView *fromView = [self.tabBarController.selectedViewController view];
        UIView *toView = [[self.tabBarController.viewControllers objectAtIndex:selectedIndex - 1] view];
        
        [UIView transitionFromView:fromView toView:toView duration:0.5f options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            
            if (finished) {
                [self.tabBarController setSelectedIndex:selectedIndex - 1];
            }
        }];
    }
}

@end

#pragma mark - Config

@implementation BaseViewController ( Config )

+ (void)setBackButtonImageName:(NSString *)imageName {
    backButtonImageName = imageName;
}

+ (NSString *)backButtonImageName {
    return backButtonImageName;
}

@end

#pragma mark - Navigation control

@implementation BaseViewController ( NavigationControl )

- (void)pushVC:(UIViewController *)vc animate:(BOOL)animate {
    [self.navigationController pushViewController:vc animated:animate];
}

- (void)pushVC:(UIViewController *)vc {
    [self pushVC:vc animate:YES];
}

- (void)popVCAnimate:(BOOL)animate {
    [self.navigationController popViewControllerAnimated:animate];
}

- (void)popVC {
    [self popVCAnimate:YES];
}

- (void)popToVC:(UIViewController *)vc animate:(BOOL)animate {
    [self.navigationController popToViewController:vc animated:animate];
}

- (void)popToVC:(UIViewController *)vc {
    [self popToVC:vc animate:YES];
}

- (void)popToRootAnimate:(BOOL)animate {
    [self.navigationController popToRootViewControllerAnimated:animate];
}

- (void)popToRoot {
    [self popToRootAnimate:YES];
}

- (void)presentVC:(UIViewController *)vc {
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
