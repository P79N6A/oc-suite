//
//  WKWapperView
//
//
//  Created by yangzm 
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "TransactionWebView.h"
#import <Foundation/Foundation.h>
#ifndef k404NotFoundHTMLPath
#define k404NotFoundHTMLPath [[NSBundle bundleForClass:NSClassFromString(@"WKWapperView")] pathForResource:@"WKWebViewController.bundle/html.bundle/404" ofType:@"html"]
#endif
#ifndef kNetworkErrorHTMLPath
#define kNetworkErrorHTMLPath [[NSBundle bundleForClass:NSClassFromString(@"WKWapperView")] pathForResource:@"WKWebViewController.bundle/html.bundle/neterror" ofType:@"html"]
#endif

#define STRINGIFY(A)  #A
static const char *html_file = STRINGIFY(
                                         <html>
                                         <head>
                                         <script>
                                         //调用格式： post('URL', {"key": "value"});
                                         function post(path, params) {
                                             var method = "post";
                                             var form = document.createElement("form");
                                             form.setAttribute("method", method);
                                             form.setAttribute("action", path);
                                             
                                             for(var key in params) {
                                                 if(params.hasOwnProperty(key)) {
                                                     var hiddenField = document.createElement("input");
                                                     hiddenField.setAttribute("type", "hidden");
                                                     hiddenField.setAttribute("name", key);
                                                     hiddenField.setAttribute("value", params[key]);
                                                     
                                                     form.appendChild(hiddenField);
                                                 }
                                             }
                                             document.body.appendChild(form);
                                             form.submit();
                                         }
                                         </script>
                                         </head>
                                         <body>
                                         </body>
                                         </html>
);

@interface WKWapperView () {
    BOOL _displayHTML;  //  显示页面元素
    BOOL _displayCookies;// 显示页面Cookies
    BOOL _displayURL;// 显示即将调转的URL
}

//  交互对象，使用它给页面注入JS代码，给页面图片添加点击事件
@property (nonatomic, strong) WKUserScript *userScript;

@end


@implementation WKWapperView {
    NSString *_imgSrc;//  预览图片的URL路径
}

//  MARK: - init
- (instancetype)initWithURLString:(NSString *)urlString {
    self = [super init];
    self.URLString = urlString;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setDefaultValue];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    WKWebViewConfiguration *configer = [[WKWebViewConfiguration alloc] init];
    configer.userContentController = [[WKUserContentController alloc] init];
    configer.preferences = [[WKPreferences alloc] init];
    configer.preferences.javaScriptEnabled = YES;
    configer.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    configer.allowsInlineMediaPlayback = YES;
    [configer.userContentController addUserScript:self.userScript];
    self = [super initWithFrame:frame configuration:configer];
    return self;
}

- (void)setURLString:(NSString *)URLString {
    _URLString = URLString;
    [self setDefaultValue];
}

- (void)setDefaultValue {
    _displayHTML = YES;
    _displayCookies = NO;
    _displayURL = YES;
    self.UIDelegate = self;
    self.navigationDelegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    // 默认是不加入加载html的
    _needLoadJSPOST = NO;
}

//  MARK: - 加载本地URL
- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:htmlName
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    
    [self loadHTMLString:htmlCont baseURL:baseURL];
}

- (void)setJsHandlers:(NSArray<NSString *> *)jsHandlers {
    _jsHandlers = jsHandlers;
    [jsHandlers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         [self.configuration.userContentController addScriptMessageHandler:self name:obj];
    }];
}

//  MARK: - js调用原生方法 可在此方法中获得传递回来的参数
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if(self.webDelegate !=nil && [self.webDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]){
        [self.webDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

//  MARK: - 检查cookie及页面HTML元素
//页面加载完成后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    if (self.needLoadJSPOST) {
        NSString *jscript = [NSString stringWithFormat:@"post('%@', %@);", self.loadJSPostURL, self.loadJSPostJSONString];
        NSLog(@"Javascript: %@", jscript);
        
        [webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
        }];
        
        self.needLoadJSPOST = NO;
    }
    
    [webView evaluateJavaScript:@"registerImageClickAction();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {}];
    
    if (_displayCookies) {
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [cookieJar cookies]) {
            NSLog(@"%@", cookie);
        }
    }
    if (_displayHTML) {
        NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
        [webView evaluateJavaScript:jsToGetHTMLSource completionHandler:^(id _Nullable HTMLsource, NSError * _Nullable error) {
            NSLog(@"%@",HTMLsource);
        }];
    }
    if (![self.webDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        return;
    }
    if([self.webDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]){
        [self.webDelegate webView:webView didFinishNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:@"bob"
                                                               password:@"pass"
                                                            persistence:NSURLCredentialPersistenceNone];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

//  MARK: - 页面开始加载就调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (self.webDelegate != nil && [self.webDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [self.webDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

- (void)loadURL:(NSURL *)pageURL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pageURL];
    request.timeoutInterval = 30;
    request.cachePolicy = NSURLRequestReloadRevalidatingCacheData;

    [self loadRequest:request];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        // [webView reloadFromOrigin];
        return;
    }
    [self didFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        // [webView reloadFromOrigin];
        return;
    }

    [self didFailLoadWithError:error];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        [webView reload]; return;
    }
    [self didFailLoadWithError:error];
}

- (void)didFailLoadWithError:(NSError *)error
{
    if (error.code == NSURLErrorCannotFindHost) {// 404
        [self loadURL:[NSURL fileURLWithPath:k404NotFoundHTMLPath]];
    } else {
        [self loadURL:[NSURL fileURLWithPath:kNetworkErrorHTMLPath]];
    }
}

//  MARK: - 导航每次跳转调用跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (_displayURL) {
        NSLog(@"-----------%@",navigationAction.request.URL.absoluteString);
        if (self.webDelegate != nil && [self.webDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
            [self.webDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        }
    }
    
    // yangzm
    const NSString *redirect_url = _redirectUrl;//@"http://www.alisports.com/redirect";
    const NSString *quit_url = _quitUrl; //@"http://www.alisports.com/quit";
    
    NSLog(@"navigate url = %@, path = %@", navigationAction.request.URL, navigationAction.request.URL.path);
    // 导航动作，关注：navigationAction
    // 1. 退出逻辑
    // 1.1 下载支付宝
    // 1.2 取消支付
    // 1.3
    
    // 2. 跳支付宝app **************************************
    // 2.1 倒数5秒
    
    // 3. 已完成支付
    // 注意：hasPrefix 是 iOS 11的api！！！
    if ([navigationAction.request.URL.absoluteString hasPrefix:(NSString *)redirect_url])
    {
        if ( _delegate )
            [_delegate OnquitUrl:navigationAction];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
        [self removeFromSuperview];
        return;
        
    } else if ([navigationAction.request.URL.absoluteString hasPrefix:(NSString *)quit_url]) {
        if ( _delegate )
            [_delegate OnRedirectUrl:navigationAction];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
        [self removeFromSuperview];
        return;
    }
    
    // 4. 支付宝登录 **************************************
    // 4.1
    
    // 5. 忘记密码
    // 5.1 打开支付宝
    // 5.2 下载支付宝
    
    // 6. 支付登录页面的，返回操作
    
    // 7. app交互操作～～
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:navigationAction.request.URL.absoluteString];
    // For appstore and system defines. This action will jump to AppStore app or the system apps.
    if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/' OR SELF BEGINSWITH[cd] 'mailto:' OR SELF BEGINSWITH[cd] 'tel:' OR SELF BEGINSWITH[cd] 'telprompt:'"] evaluateWithObject:components.URL.absoluteString]) {
        if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
            if (@available(iOS 10.0, *)) {
                [UIApplication.sharedApplication openURL:components.URL options:@{} completionHandler:NULL];
            } else {
                [[UIApplication sharedApplication] openURL:components.URL];
            }
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES[cd] 'https' OR SELF MATCHES[cd] 'http' OR SELF MATCHES[cd] 'file' OR SELF MATCHES[cd] 'about'"] evaluateWithObject:components.scheme]) {// For any other schema but not `https`、`http` and `file`.
        if (@available(iOS 8.0, *)) { // openURL if ios version is low then 8 , app will crash
            if ( [[UIApplication sharedApplication] canOpenURL:components.URL]) {
                if (@available(iOS 10.0, *)) {
                    [UIApplication.sharedApplication openURL:components.URL options:@{} completionHandler:NULL];
                } else {
                    [[UIApplication sharedApplication] openURL:components.URL];
                }
            }
        }else{
            if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
                [[UIApplication sharedApplication] openURL:components.URL];
            }
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - 移除jsHandler
- (void)removejsHandlers {
    NSAssert(_jsHandlers, @"未找到jsHandler!无需移除");
    if (_jsHandlers) {
        for (NSString *handlerName in _jsHandlers) {
            [self.configuration.userContentController removeScriptMessageHandlerForName:handlerName];
        }
    }
}

//  MARK: - 进度条
- (UIProgressView *)progressView {
    if(!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
        _progressView.tintColor = [UIColor redColor];
        _progressView.trackTintColor = [UIColor whiteColor];
        [self addSubview:_progressView];
    }
    return _progressView;
}
//  MARK: - 清除cookie
- (void)removeCookies {
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                         for (WKWebsiteDataRecord *record  in records) {
                             [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                       forDataRecords:@[record]
                                                                    completionHandler:^{
                                                                        NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                    }];
                         }
                     }];
}

- (void)removeCookieWithHostName:(NSString *)hostName {
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                         for (WKWebsiteDataRecord *record  in records) {
                             if ( [record.displayName containsString:hostName]) {
                                 [[WKWebsiteDataStore defaultDataStore]removeDataOfTypes:record.dataTypes
                                                                          forDataRecords:@[record]
                                                                       completionHandler:^{
                                                                            NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                          }];
                             }
                         }
                     }];
}

//  MARK: - 调用js方法
- (void)callJavaScript:(NSString *)jsMethodName {
    [self callJavaScript:jsMethodName handler:nil];
}

- (void)callJavaScript:(NSString *)jsMethodName handler:(void (^)(id _Nullable))handler {
    
    NSLog(@"call js:%@",jsMethodName);
    [self evaluateJavaScript:jsMethodName completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (handler) {
            handler(response);
        }
    }];
}

- (void)dealloc {
    //  这里清除或者不清除cookies 按照业务要求
//    [self removeCookies];
}

- (WKUserScript *)userScript {
    if (!_userScript) {
        static  NSString * const jsGetImages =
        @"function getImages(){\
        var objs = document.getElementsByTagName(\"img\");\
        var imgScr = '';\
        for(var i=0;i<objs.length;i++){\
        imgScr = imgScr + objs[i].src + '+';\
        };\
        return imgScr;\
        };function registerImageClickAction(){\
        var imgs=document.getElementsByTagName('img');\
        var length=imgs.length;\
        for(var i=0;i<length;i++){\
        img=imgs[i];\
        img.onclick=function(){\
        window.location.href='image-preview:'+this.src}\
        }\
        }";
        _userScript = [[WKUserScript alloc] initWithSource:jsGetImages injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    }
    return _userScript;
}
@end
