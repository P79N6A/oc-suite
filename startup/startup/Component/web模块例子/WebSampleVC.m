//
//  WebSampleVC.m
//  startup
//
//  Created by 7 on 25/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#define PERF_TIMER_IMPL_CODE {\
@private \
volatile long double factor_; \
volatile UInt64 started_; \
volatile UInt64 capture_; \
} \
- (void)start { \
    started_ = mach_absolute_time(); \
    capture_ = 0ULL; \
} \
- (void)capture { \
    UInt64 capture = mach_absolute_time(); \
    if (started_) { \
        capture_ = capture; \
    } \
} \
- (UInt32)msElapsed { \
    if (!started_ || !capture_) { \
        return 0LL; \
    } \
    return (UInt32)roundl((long double)(capture_ - started_) * factor_ / 1000000.0L); \
} \
- (NSString *)stringWithElapsedTime { \
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init]; \
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; \
    NSString * msElapsedString = [formatter stringFromNumber:[NSNumber numberWithLong:[self msElapsed]]]; \
    return [NSString stringWithFormat:@"[%@ ms]", msElapsedString]; \
}

// 格式 0xff3737
#define JHUDRGBHexAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define JHUDRGBA(r,g,b,a)     [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]


// 再来个webView的自适应高度：
/**
 
 CGRect frame = webView.frame;
 CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
 frame.size = fittingSize;
 webView.frame = frame;  
 
 */

//#import <hybrid_web/hybrid_web.h>
#import <mach/mach.h>
#import <mach/mach_time.h>

#import "WebSampleVC.h"
#import "_greats.h"
#import "_building.h"
#import "_web_service.h"

@interface WebSampleVC () <_WebPageDelegate, _WebPageJavaScript, UIWebViewDelegate>

@property (nonatomic, strong) _WebPage *webView;


///////////////////////////////////////////////////////

@property (nonatomic) _WebHUD *hudView;
@property (nonatomic, strong) UIWebView *webView_;

@end

@implementation WebSampleVC PERF_TIMER_IMPL_CODE

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        // Precalculate the absolute time to nanosecond conversion factor as it
        // only needs to be done once.
        mach_timebase_info_data_t info;
        mach_timebase_info(&info);
        factor_ = ((long double)info.numer) / ((long double)info.denom);
    }
    
    self.title = @"WebPage例子";
    
    // 清理网页缓存
    
    [service_web clearCache]; // 只能清理wk
    
    // 加载网页
#if 0
    
    [self loadWebViewByURL];
    
#elif 0
    
    [self loadWebViewByContentFile];
    
#else
    
    [self loadByContentFileAndUIWebView];
    
#endif
    
    if (self.webView) {
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(self.view);
        }];
    } else if (self.webView_) {
        [self.webView_ mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(self.view);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)loadByContentFileAndUIWebView {
    _webView_ = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView_.delegate = self;
    [self.view addSubview:_webView_];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"html"];
    NSString *htmlString = [[NSString alloc] initWithContentsOfFile:htmlPath encoding:kCFStringEncodingUTF8 error:nil];
    
    [_webView_ loadHTMLString:htmlString baseURL:nil];
    
    // 开始加载的时候 量身高
    _webView_.frame = CGRectMake(0, 0, screen_width, 1);
    
    CGFloat height = [[_webView_ stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    CGRect frame = CGRectMake(0, 0, screen_width, height);
    
    INFO(@"web view frame when start = %@", NSStringFromCGRect(frame));
    
    _webView_.hidden = YES;
    
    self.hudView = [[_WebHUD alloc] initWithFrame:self.view.bounds];
    self.hudView.messageLabel.text = @"Hello ,this is a circleJoin animation";
    self.hudView.indicatorForegroundColor = JHUDRGBA(60, 139, 246, .5);
    self.hudView.indicatorBackGroundColor = JHUDRGBA(185, 186, 200, 0.3);
    [self.hudView showAtView:self.view hudType:_WebHUDLoadingTypeCircleJoin];
}

- (void)loadWebViewByURL {
#define ADDRESS @"https://xe.easylinking.net:443/elinkWaiter/consultation/consultationAppIndex.do?userId=131812"
    
    NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:ADDRESS]];
    _webView = [[_WebPage alloc] initWithFrame:self.view.bounds JSPerformer:self];
    _webView.script = self;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    [_webView loadRequest:req];
}

- (void)loadWebViewByContentFile {
    _webView = [[_WebPage alloc] initWithFrame:self.view.bounds JSPerformer:self];
    _webView.script = self;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"html"];
    NSString *htmlString = [[NSString alloc] initWithContentsOfFile:htmlPath encoding:kCFStringEncodingUTF8 error:nil];
    
    [_webView loadHTMLString:htmlString baseURL:nil];
    
    // 开始加载的时候 量身高
    _webView.frame = CGRectMake(0, 0, screen_width, 1);
    [_webView excuteJavaScript:@"document.body.offsetHeight" completionHandler:^(id  _Nonnull params, NSError * _Nonnull error) {
        NSNumber *height = (NSNumber *)params;
        CGRect frame = CGRectMake(0, 0, screen_width, height.floatValue);

        INFO(@"web view frame when start = %@", NSStringFromCGRect(frame));
    }];
    
}

#pragma mark -

- (NSArray <NSString *>*)webViewRegisterObjCMethodNameForJavaScriptInteraction {
    return @[@"getConsultationInfo"];
}

- (BOOL)webView:(_WebPage *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(_WebPageNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(_WebPage *)webView {
    NSLog(@"开始加载");
    
    [self start];
}

- (void)webViewDidFinishLoad:(_WebPage *)webView {
    if ([webView isKindOfClass:_WebPage.class]) {
        [self capture];
        
        NSLog(@"加载成功, 加载时间：%@", [self stringWithElapsedTime]);
        
        // 结束加载的时候 量身高
        _webView.frame = CGRectMake(0, 0, screen_width, 1); // 很重要！！！
        [_webView excuteJavaScript:@"document.body.offsetHeight" completionHandler:^(id  _Nonnull params, NSError * _Nonnull error) {
            NSNumber *height = (NSNumber *)params;
            CGRect frame = CGRectMake(0, 0, screen_width, height.floatValue);
            
            INFO(@"web view frame when finish = %@", NSStringFromCGRect(frame));
        }];
        
        
        {
            /**
             *  用户ID通过注入JS代码完成
             */
            NSString *jsGetCurrentUserId = [NSString stringWithFormat:@"getCurrentUserId('%@')", @"131812"];
            [self.webView excuteJavaScript:jsGetCurrentUserId completionHandler:^(id  _Nonnull params, NSError * _Nonnull error) {
                if (error) {
                    NSLog(@"注入JS方法getCurrentUserId出错：%@",[error localizedDescription]);
                }else{
                    NSLog(@"注入JS方法getCurrentUserId成功");
                }
            }];
            
        }
        
        {
            ////告诉服务端是否使用最新的WebView
            NSString * shouldUseLatestWebView = [NSString stringWithFormat:@"shouldUseLatestWebView('%@')", @"1"];;
            
            [self.webView excuteJavaScript:shouldUseLatestWebView completionHandler:^(id  _Nonnull params, NSError * _Nonnull error) {
                if (error) {
                    NSLog(@"注入JS方法shouldUseLatestWebView出错：%@",[error localizedDescription]);
                }else{
                    NSLog(@"注入JS方法shouldUseLatestWebView成功");
                }
            }];
        }
    }
    
    else {
        
        [self.hudView hide];
        self.hudView = nil;
        
        self.webView_.hidden = NO;
        
        // 结束加载的时候 量身高
        self.webView_.frame = CGRectMake(0, 0, screen_width, 1);
        
        CGFloat height = [[self.webView_ stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
        CGRect frame = CGRectMake(0, 0, screen_width, height);
        
        INFO(@"web view frame when finish = %@", NSStringFromCGRect(frame));
    }
    
}

- (void)webView:(_WebPage *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"加载失败:%@",error);
}

- (void)getConsultationInfo:(NSDictionary *)param {
    NSLog(@"JS传来参数:%@",param[@"id"]);
    
    NSURL * url = [NSURL URLWithString: [NSString stringWithFormat:@"https://xe.easylinking.net:10004/elinkWaiter/consultation/getConsultationInfo.do?consultationId=%@&userId=131812",param[@"id"]]];
    NSURLRequest * req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
}

@end
