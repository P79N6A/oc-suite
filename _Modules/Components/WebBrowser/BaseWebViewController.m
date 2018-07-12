
//#import "_building_precompile.h"
#import "Masonry.h"
#import "BaseWebViewController.h"
#import "BaseViewController+Private.h"
#import "WebViewProgress.h"
#import "WebViewProgressView.h"
#import "WebViewFailedView.h"
#import "UIWebView+JavaScript.h"
#import "NSURLRequest+Web.h"

@interface BaseWebViewController () <UIWebViewDelegate, WebViewFailedViewDelegate>

/** Web failed view start */
@property (nonatomic, strong) WebViewFailedView *webFailedView;

/** Web failed view end */

@property (nonatomic) NSHashTable *webDelegates;

@property (nonatomic) UIBarButtonItem       *closeButtonItem;

@property (nonatomic) WebViewProgress       *progressProxy;
@property (nonatomic) WebViewProgressView   *progressView;

/**
 *  array that hold snapshots
 */
@property (nonatomic) NSMutableArray    *snapShotsArray;

/**
 *  current snapshotview displaying on screen when start swiping
 */
@property (nonatomic) UIView    *currentSnapShotView;

/**
 *  previous view
 */
@property (nonatomic) UIView    *prevSnapShotView;

/**
 *  background alpha black view
 */
@property (nonatomic) UIView    *swipingBackgoundView;

/**
 *  left pan ges
 */
@property (nonatomic) UIPanGestureRecognizer *swipePanGesture;

/**
 *  if is swiping now
 */
@property (nonatomic) BOOL isSwipingBack;

@end

@implementation BaseWebViewController

#pragma mark - public funcs

- (void)reloadWebView {
    [self.webView reload];
}

#pragma mark - Initialize

- (instancetype)initWithUrl:(NSURL *)url {
    return [self initWithUrl:url param:nil];
}

- (instancetype)initWithUrl:(NSURL *)url param:(NSDictionary *)param {
    if (self = [super init]) {
        self.params = param;
        
        _useCache = NO;
        _webDelegates = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:10];
        _url = url;
        _progressViewColor = [UIColor redColor];
    }
    
    return self;
}

- (void)initDefault {
    {
        self.title = @"";
        
        if ([self.params hasKey:@"title"]) {
            self.title = self.params[@"title"];
        }
    }}

//- (void)initNavigationBar {
//    self.navigationItem.leftItemsSupplementBackButton = YES;
//
//    [self setNavLeftItemWithImage:[BaseViewController backButtonImageName] target:self action:@selector(onBack)];
//}

- (void)initProgressView {
    [self.webDelegates addObject:self.progressProxy];
    
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)uinitProgressView {
    [self.progressView removeFromSuperview];
}

- (void)initWebFailedView {
    [self.webDelegates addObject:self.webFailedView];
    
    [self.view addSubview:self.webFailedView];
    
    [self.webFailedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

- (void)initWebView {
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

- (void)uinitWebView {
    self.webView.delegate = nil;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDefault];
    
//    [self initNavigationBar];
    
    [self initProgressView];

    [self initWebView];
    
    [self initWebFailedView];
    
    [self requestWebView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self uinitProgressView];
    
    [self uinitWebView];
}

- (void)requestWebView {
    if (self.useCache) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:10.f];
        [self.webView loadRequest:request];
    } else {
        [[NSURLCache sharedURLCache] removeAllCachedResponses]; // 清除本地h5缓存和cookie
        
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                             timeoutInterval:10.f];
        [self.webView loadRequest:request];
    }
}

#pragma mark - Action handler

- (void)onBack {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onShare {
    
}

- (void)onSwipePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.webView];
    CGPoint location = [panGesture locationInView:self.webView];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (location.x <= 50 && translation.x > 0) {  //开始动画
            [self startPopSnapshotView];
        }
    } else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded) {
        [self endPopSnapShotView];
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self popSnapShotViewWithPanGestureDistance:translation.x];
    }
}

- (void)onClose {
    [self.navigationController popViewControllerAnimated:YES];
}

// WebViewFailedViewDelegate
- (void)onRefresh {
    [self requestWebView];
}

#pragma mark - StatusBar indicator

- (void)showLoadingIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)hideLoadingIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - logic of push and pop snap shot views

- (void)pushCurrentSnapshotViewWithRequest:(NSURLRequest *)request {
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    
    //如果url是很奇怪的就不push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return;
    }
    //如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    
    UIView* currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:
     @{
       @"request":request,
       @"snapShotView":currentSnapShotView
       }
     ];
}

- (void)startPopSnapshotView {
    if (self.isSwipingBack) {
        return;
    }
    
    if (!self.webView.canGoBack) {
        return;
    }
    
    self.isSwipingBack = YES;
    
    //create a center of scrren
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    
    //add shadows just like UINavigationController
    self.currentSnapShotView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapShotView.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapShotView.layer.shadowRadius = 5;
    self.currentSnapShotView.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.currentSnapShotView.center = center;
    
    self.prevSnapShotView = (UIView*)[[self.snapShotsArray lastObject] objectForKey:@"snapShotView"];
    center.x -= 60;
    
    self.prevSnapShotView.center = center;
    self.prevSnapShotView.alpha = 1;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.prevSnapShotView];
    [self.view addSubview:self.swipingBackgoundView];
    [self.view addSubview:self.currentSnapShotView];
}

- (void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance {
    if (!self.isSwipingBack) {
        return;
    }
    
    if (distance <= 0) {
        return;
    }
    
    CGPoint currentSnapshotViewCenter = CGPointMake(screen_width/2, screen_height/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint prevSnapshotViewCenter = CGPointMake(screen_width/2, screen_height/2);
    prevSnapshotViewCenter.x -= (screen_width - distance)*60/screen_width;
    
    self.currentSnapShotView.center = currentSnapshotViewCenter;
    self.prevSnapShotView.center = prevSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (screen_width - distance)/screen_width;
}

- (void)endPopSnapShotView {
    if (!self.isSwipingBack) {
        return;
    }
    
    //prevent the user touch for now
    self.view.userInteractionEnabled = NO;
    
    if (self.currentSnapShotView.center.x >= screen_width) {
        // pop success
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(screen_width*3/2, screen_height/2);
            self.prevSnapShotView.center = CGPointMake(screen_width/2, screen_height/2);
            self.swipingBackgoundView.alpha = 0;
            
        } completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            [self.webView goBack];
            [self.snapShotsArray removeLastObject];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    } else {
        //pop fail
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(screen_width/2, screen_height/2);
            self.prevSnapShotView.center = CGPointMake(screen_width/2-60, screen_height/2);
            self.prevSnapShotView.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }
}

#pragma mark - update nav items

- (void)updateNavigationItems {
    if (self.webView.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.navigationItem setLeftBarButtonItems:@[self.closeButtonItem] animated:NO];
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:nil];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    LOG(@"request url = %@", request.URL.path);
    
    /**
     *  这个方法比较重要, 它的返回值，基本是由webDelegates中提供；所有ret value进行或运算
     */
    
    BOOL ret =  YES;
    {
        // Dispatch WebViewDelegate to other proxy
        for (id delegate in self.webDelegates) {
            if (is_protocol_implemented(delegate, UIWebViewDelegate) && is_method_implemented(delegate, webView:shouldStartLoadWithRequest:navigationType:)) {
               ret |= [delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
            }
        }
    }
    
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeBackForward: {
            break;
        }
        case UIWebViewNavigationTypeReload: {
            break;
        }
        case UIWebViewNavigationTypeFormResubmitted: {
            break;
        }
        case UIWebViewNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        default: {
            break;
        }
    }
    
//    [self updateNavigationItems];
    
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    {
        // Dispatch WebViewDelegate to other proxy
        for (id delegate in self.webDelegates) {
            if (is_protocol_implemented(delegate, UIWebViewDelegate) && is_method_implemented(delegate, webViewDidStartLoad:)) {
                [delegate webViewDidStartLoad:webView];
            }
        }
    }
    
    [self showLoadingIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    {
        // Dispatch WebViewDelegate to other proxy
        for (id delegate in self.webDelegates) {
            if (is_protocol_implemented(delegate, UIWebViewDelegate) && is_method_implemented(delegate, webViewDidFinishLoad:)) {
                [delegate webViewDidFinishLoad:webView];
            }
        }
    }
    
    [self hideLoadingIndicator];
    
//    [self updateNavigationItems];
    
    if (!is_string_present(self.title)) {// 如果用户未设置标题，则看webview的标题
        NSString *theTitle = [self.webView getTitle];
        
        if (theTitle.length > 10) {
            theTitle = [[theTitle substringToIndex:9] stringByAppendingString:@"…"];
        }
        self.title = theTitle;
        
        if (!is_string_present(self.title)) { // 如果webview标题为空，则获取应用名
            self.title = app_display_name;
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    {
        // Dispatch WebViewDelegate to other proxy
        for (id delegate in self.webDelegates) {
            if (is_protocol_implemented(delegate, UIWebViewDelegate) && is_method_implemented(delegate, webView:didFailLoadWithError:)) {
                [delegate webView:webView didFailLoadWithError:error];
            }
        }
    }
    
    [self hideLoadingIndicator];
}

#pragma mark - NJProgress delegate

- (void)webViewProgress:(WebViewProgress *)webViewProgress updateProgress:(float)progress {
    [self.progressView setProgress:progress animated:YES];
}

#pragma mark - setters and getters

- (void)setProgressViewColor:(UIColor *)progressViewColor {
    _progressViewColor = progressViewColor;
    self.progressView.progressColor = progressViewColor;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = (id)self;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = [UIColor whiteColor];
        [_webView addGestureRecognizer:self.swipePanGesture];
    }
    return _webView;
}

- (UIBarButtonItem *)closeButtonItem {
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
    }
    return _closeButtonItem;
}

- (UIView *)swipingBackgoundView {
    if (!_swipingBackgoundView) {
        _swipingBackgoundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _swipingBackgoundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _swipingBackgoundView;
}

- (NSMutableArray*)snapShotsArray {
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}

- (BOOL)isSwipingBack {
    if (!_isSwipingBack) {
        _isSwipingBack = NO;
    }
    return _isSwipingBack;
}

- (UIPanGestureRecognizer*)swipePanGesture {
    if (!_swipePanGesture) {
        _swipePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipePanGesture:)];
    }
    return _swipePanGesture;
}

- (WebViewProgress *)progressProxy {
    if (!_progressProxy) {
        _progressProxy = [[WebViewProgress alloc] init];
        _progressProxy.progressDelegate = (id)self;
    }
    return _progressProxy;
}

- (WebViewProgressView *)progressView {
    if (!_progressView) {
        CGFloat progressBarHeight = 3.0f;
        CGRect barFrame = CGRectMake(0, navigation_bar_height, screen_width, progressBarHeight);
        
        _progressView = [[WebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.progressColor = self.progressViewColor;
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _progressView;
}

- (WebViewFailedView *)webFailedView {
    if (!_webFailedView) {
        _webFailedView = [WebViewFailedView new];
        _webFailedView.delegate = self;
    }
    
    return _webFailedView;
}

@end

#pragma mark - BaseViewController, WebView

@implementation BaseViewController ( WebView )

- (void)pushHtml:(NSURL *)url {
    [self pushHtml:url extraParams:nil];
}

- (void)pushHtml:(NSURL *)url extraParams:(NSDictionary *)params {
    BaseWebViewController *viewController = [[BaseWebViewController alloc] initWithUrl:url param:params];
    [self pushVC:viewController];
}

@end
