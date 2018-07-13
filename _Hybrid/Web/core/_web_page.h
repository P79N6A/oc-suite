#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// ----------------------------------
// Type Definition
// ----------------------------------

/**
 *  The type of action triggering a navigation.
 */
typedef NS_ENUM(NSInteger, _WebPageNavigationType) {
    /**
     *  A link with an href attribute was activated by the user.
     */
    _WebPageNavigationTypeLinkClicked,
    /**
     *  A form was submitted.
     */
    _WebPageNavigationTypeFormSubmitted,
    /**
     *  An item from the back-forward list was requested.
     */
    _WebPageNavigationTypeBackForward,
    /**
     *  The webpage was reloaded.
     */
    _WebPageNavigationTypeReload,
    /**
     *  A form was resubmitted (for example by going back, going forward, or reloading).
     */
    _WebPageNavigationTypeFormResubmitted,
    /**
     *  Navigation is taking place for some other reason.
     */
    _WebPageNavigationTypeOther
};

/**
 *  _WebDataDetectorTypes
 */
typedef NS_OPTIONS(NSUInteger, _WebPageDataDetectorTypes) {
    /**
     *  Disable detection.
     */
    _WebPageDataDetectorTypeNone                  = 0,
    /**
     *  Phone number detection.
     */
    _WebPageDataDetectorTypePhoneNumber           = 1 << 0,
    /**
     *  URL detection.
     */
    _WebPageDataDetectorTypeLink                  = 1 << 1,
    /**
     *  Street address detection.
     */
    _WebPageDataDetectorTypeAddress               = 1 << 2,
    /**
     *  Event detection.
     */
    _WebPageDataDetectorTypeCalendarEvent         = 1 << 3,
    /**
     *  Shipment tracking number detection.
     */
    _WebPageDataDetectorTypeTrackingNumber        = 1 << 4,
    /**
     *  Flight number detection.
     */
    _WebPageDataDetectorTypeFlightNumber          = 1 << 5,
    /**
     *  Information users may want to look up.
     */
    _WebPageDataDetectorTypeLookupSuggestion      = 1 << 6,
    /**
     *  Enable all types, including types that may be added later.
     */
    _WebPageDataDetectorTypeAll = NSUIntegerMax
};

// ----------------------------------
// Pre Declaration
// ----------------------------------

@protocol _WebPageDelegate, _WebPageJavaScript;

// ----------------------------------
// MARK: - _WebPage
// ----------------------------------

NS_CLASS_AVAILABLE(10_10, 7_0)
@interface _WebPage : UIView

/**
 *  The web view's user interface delegate
 */
@property (nonatomic, weak) id<_WebPageDelegate> delegate;

/**
 *  The web view's javascript interactive delegate.
 */
@property (nonatomic, weak) id<_WebPageJavaScript> script;
//**

- (instancetype)new __IOS_PROHIBITED;
- (instancetype)init __IOS_PROHIBITED;

/**
 *  Specifies the constructor
 *
 *  @param performer Used for function pointers to callback
 */
- (instancetype)initWithFrame:(CGRect)frame JSPerformer:(nonnull id)performer;

/**
 *  Navigates to a requested URL.
 *
 *  @param request request The request specifying the URL to which to navigate.
 */
- (void)loadRequest:(NSURLRequest *)request;

/**
 *  Sets the webpage contents and base URL.
 *
 *  @param string   The string to use as the contents of the webpage.
 *  @param baseURL  A URL that is used to resolve relative URLs within the document.
 */
- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;

/**
 *  The page URLRequest.
 */
@property (nullable, nonatomic, readonly, strong) NSURLRequest *request;

/**
 *  The page title.
 */
@property (nullable, nonatomic, readonly, copy) NSString * title;

/**
 *  Customize the alert box title
 */
@property (nullable, nonatomic, copy) NSString * pageAlertTitle;
//当拦截到JS中的alter方法，自定义弹出框的标题

/**
 *  Customize the confirm box title
 */
@property (nullable, nonatomic, copy) NSString * pageConfirmTitle;
//当拦截到JS中的confirm方法，自定义弹出框的标题

/**
 *  An estimate of what fraction of the current navigation has been completed.
 *  This value ranges from 0.0 to 1.0 based on the total number of
 *  bytes expected to be received, including the main document and all of its
 *  potential subresources. After a navigation completes, the value remains at 1.0
 *  until a new navigation starts, at which point it is reset to 0.0.
 */
@property (nonatomic, readonly) double estimatedProgress NS_AVAILABLE_IOS(9_0); //9.0才支持获取进度,9.0之下版本可以根据回调模拟虚假进度

/**
 *  The scroll view associated with the web view.
 */
@property (nonatomic, readonly, strong) UIScrollView *scrollView;

/**
 *  An enum value indicating the type of data detection desired.
 *  The default value is WKDataDetectorTypeNone.
 
 ***********************************  SORRY  ***********************************
 
 *  Sorry, I try to solve WKWebView internal dataDetector problem,             *
 *  however, WKWebView only in iOS10 above support dataDetectorTypes.          *
 *  I try to find the implementation of dataDetectorTypes from Apple's         *
 *  open source code, but the new features of WKWebView IOS10 are not          *
 *  open source.                                                               *
 *  If you find a better way, please tell me, thank you for understanding.     *
 
 ***********************************  SORRY  ***********************************
 */
@property (nonatomic) _WebPageDataDetectorTypes dataDetectorTypes;

/**
 *  The server must intercept this method, or a non-crashing error will occur
 *
 *  @param javaScriptString  javaScript method
 *  @param completionHandler callback
 */
- (void)excuteJavaScript:(NSString *)javaScriptString completionHandler:(void(^)(id params, NSError * error))completionHandler;

@end

// ----------------------------------
// MARK: Navigation
// ----------------------------------
 
@interface _WebPage ( Navigation )
/**
 *  A Boolean value indicating whether there is a back item in
 *  the back-forward list that can be navigated to.
 */
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;

/**
 *  A Boolean value indicating whether there is a forward item in
 *  the back-forward list that can be navigated to.
 */
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;

/**
 *  A Boolean value indicating whether the view is currently
 *  loading content.
 */
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

/**
 *  Reloads the current page.
 */
- (void)reload;

/**
 *  Stops loading all resources on the current page.
 */
- (void)stopLoading;

/**
 *  Navigates to the back item in the back-forward list.
 */
- (void)goBack;

/**
 *  Navigates to the forward item in the back-forward list.
 */
- (void)goForward;

@end

// ----------------------------------
// MARK: - Protocol: _WebPageDelegate _WebPageJavaScript
// ----------------------------------

/********************************************************************************
 *  user interface protocol
 */
@protocol _WebPageDelegate <NSObject>
@optional

- (BOOL)webView:(_WebPage *)webPage shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(_WebPageNavigationType)navigationType;
- (void)webViewDidStartLoad:(_WebPage *)webPage;
- (void)webViewDidFinishLoad:(_WebPage *)webPage;
- (void)webView:(_WebPage *)webPage didFailLoadWithError:(NSError *)error;

@end

/********************************************************************************
 *  JavaScriptn interactive protocol
 */
@protocol _WebPageJavaScript <NSObject>
@optional

/**
 call objc method
 
     - (NSArray<NSString *>*)gswebViewRegisterObjCMethodNameForJavaScriptInteraction
     {
        return @[@"getCurrentUserId"];
     }
 
     - (void)getCurrentUserId:(NSString *)Id
     {
        NSLog(@"JS调用到OC%@",Id);
     }
 */
- (NSArray<NSString *>*)webViewRegisterObjCMethodNameForJavaScriptInteraction;

@end
 
NS_ASSUME_NONNULL_END
