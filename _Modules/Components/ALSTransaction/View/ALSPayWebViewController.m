//
//  ALSPayWebViewController.m
//  Pay-inner
//
//  Created by  杨子民 on 2018/4/26.
//  Copyright © 2018年 yangzm. All rights reserved.
//

#import "ALSPayWebViewController.h"
#import "NetHelp.h"

#ifndef m404NotFoundHTMLPath
#define m404NotFoundHTMLPath [[NSBundle bundleForClass:NSClassFromString(@"PayViewController")] pathForResource:@"WebViewController.bundle/html.bundle/404" ofType:@"html"]
#endif
#ifndef mNetworkErrorHTMLPath
#define mNetworkErrorHTMLPath [[NSBundle bundleForClass:NSClassFromString(@"PayViewController")] pathForResource:@"WebViewController.bundle/html.bundle/neterror" ofType:@"html"]
#endif

@interface ALSPayWebViewController ()<UIWebViewDelegate>

@property(strong,nonatomic)UIWebView* webview;
@property(nonatomic,strong)UIButton *btn;
@property(nonatomic,assign)NSInteger flag;
@end

@implementation ALSPayWebViewController

-(void)doClick:(UIButton*)sender
{
    if (self.flag==0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        if ( _callback ){
            _callback( -2, @"用户返回支付", nil );
        }
    }
    self.flag=0;
}

- (void) dragMoving: (UIButton *) c withEvent:ev
{
    self.flag = 1;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
    NSLog(@"%f,,,%f",c.center.x,c.center.y);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    _webview.delegate = self;
    [self.view addSubview:_webview];
    [_webview loadRequest:_payRequest];
    /*
    self.btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.btn.frame = CGRectMake(5,  15, 80, 50);
    
    [self.btn setTitle:@"退出支付" forState:UIControlStateNormal];
    [self.btn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
    [self.btn addTarget:self action:@selector(doClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.btn];
    */
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"退出支付" style:UIBarButtonItemStyleBordered target:self action:@selector(doClick:)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    //show indicator while loading website
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //turn off indicator and display the name of the website in the navBar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
}

- (void)setPayRequest:(NSURLRequest *)payRequest
{
    _payRequest = payRequest;
    [_webview loadRequest:payRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)loadURL:(NSURL *)pageURL
{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pageURL];
        request.timeoutInterval = 30;
        [_webview loadRequest:request];
}

- (void)didFailLoadWithError:(NSError *)error
{
    if ( error.code == 101 )
        return;
    
    if (error.code == NSURLErrorCannotFindHost) {// 404
        [self loadURL:[NSURL fileURLWithPath:m404NotFoundHTMLPath]];
    } else {
        [self loadURL:[NSURL fileURLWithPath:mNetworkErrorHTMLPath]];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self didFailLoadWithError:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"--------------------------------- %@, path = %@", request.URL, request.URL.path);
    NSString *urlString = request.URL.absoluteString;
    
    if ( _redirectUrl.length == 0 ){
        NSString* str = [NSString stringWithFormat:@"/pay_order/%c%c%c%c%c%c_redirect", 97, 108, 105, 112, 97, 121 ];
         _redirectUrl = str;
    }
    
    if ( _quitUrl.length == 0  )
         _quitUrl = @"http://www.alisports.com/quit";
    
    if ([request.URL.absoluteString containsString:(NSString *)_redirectUrl]) {
        if ( _callback )
            _callback( 0, @"receive from web", nil );
        
        [self dismissViewControllerAnimated:YES completion:nil];
        return YES;
    } else if ([request.URL.absoluteString hasPrefix:(NSString *)_quitUrl]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }
    
    NSString* flag = [NetHelp GetFormatStr:@"" right:@"://"];
    if ( [urlString hasPrefix:flag ]  && ![urlString containsString:@"alisportstransactionkit"])
    {
        NSString* f2 = [NetHelp GetFormatStr:@"" right:@"s"];
        NSString *str = [urlString stringByReplacingOccurrencesOfString:f2 withString:@"alisportstransactionkit"];
        NSMutableURLRequest *mRequest = [request mutableCopy];
        [mRequest setURL:[NSURL URLWithString:str]];
        [self.webview loadRequest:mRequest];
        return NO;
    }
    
    return YES;
}

@end
