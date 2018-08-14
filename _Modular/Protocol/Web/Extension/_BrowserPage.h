#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol _BrowserPage <NSObject>

@property (nonatomic, readonly) UIView *view; // addSubView: 的时候使用
@property (nonatomic, readonly) UIView *webView; // UIWebView, WKWebView



@end
