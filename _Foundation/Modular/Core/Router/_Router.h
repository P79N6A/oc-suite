
#import "_Foundation.h"
#import "Routable.h"

#pragma mark -

@interface _Router : NSObject  {
    @public
    UPRouter *route;
}

/**
 *  当前没有模块跳转需求，所以用单例，统管页面跳转方式
 */
@singleton( _Router )

/**
 *  Add root navigation controller
 *
 *  @param controller navigation controller
 */
- (void)setNavigationController:(UINavigationController *)controller;

/**
 Pop to the last `UIViewController` mapped with the router; this will either dismiss the presented `UIViewController` (i.e. modal) or pop the top view controller in the navigationController. The transition is animated.
 */
- (void)pop;

/**
 Pop to the last `UIViewController` mapped with the router; this will either dismiss the presented `UIViewController` (i.e. modal) or pop the top view controller in the navigationController.
 @param animated Whether or not the transition is animated;
 */

- (void)popViewControllerFromRouterAnimated:(BOOL)animated;
/**
 Pop to the last `UIViewController` mapped with the router; this will either dismiss the presented `UIViewController` (i.e. modal) or pop the top view controller in the navigationController.
 @param animated Whether or not the transition is animated;
 @remarks not idiomatic objective-c naming
 */
- (void)pop:(BOOL)animated;

///-------------------------------
/// @name Mapping URLs
///-------------------------------

/**
 Map a URL format to an anonymous callback
 @param format A URL format (i.e. "users/:id" or "logout")
 @param callback The callback to run when the URL is triggered in `open:`
 */
- (void)map:(NSString *)format toCallback:(RouterOpenCallback)callback;
/**
 Map a URL format to an anonymous callback and `UPRouterOptions` options
 @param format A URL format (i.e. "users/:id" or "logout")
 @param callback The callback to run when the URL is triggered in `open:`
 @param options Configuration for the route
 */
- (void)map:(NSString *)format toCallback:(RouterOpenCallback)callback withOptions:(UPRouterOptions *)options;
/**
 Map a URL format to an anonymous callback and `UPRouterOptions` options
 @param format A URL format (i.e. "users/:id" or "logout")
 @param controllerClass The `UIViewController` `Class` which will be instanstiated when the URL is triggered in `open:`
 */
- (void)map:(NSString *)format toController:(Class)controllerClass;
/**
 Map a URL format to an anonymous callback and `UPRouterOptions` options
 @param format A URL format (i.e. "users/:id" or "logout")
 @param controllerClass The `UIViewController` `Class` which will be instanstiated when the URL is triggered in `open:`
 @param options Configuration for the route, such as modal settings
 */
- (void)map:(NSString *)format toController:(Class)controllerClass withOptions:(UPRouterOptions *)options;

///-------------------------------
/// @name Opening URLs
///-------------------------------

/**
 A convenience method for opening a URL using `UIApplication` `openURL:`.
 @param url The URL the OS will open (i.e. "http://google.com")
 */
- (void)openExternal:(NSString *)url;

/**
 Triggers the appropriate functionality for a mapped URL, such as an anonymous function or opening a `UIViewController`. `UIViewController` transitions will be animated;
 @param url The URL being opened (i.e. "users/16")
 @exception RouteNotFoundException Thrown if url does not have a valid mapping
 @exception NavigationControllerNotProvided Thrown if url opens a `UIViewController` and navigationController has not been assigned
 @exception RoutableInitializerNotFound Thrown if the mapped `UIViewController` instance does not implement -initWithRouterParams: or +allocWithRouterParams:
 */
- (void)open:(NSString *)url;

/**
 Triggers the appropriate functionality for a mapped URL, such as an anonymous function or opening a `UIViewController`
 @param url The URL being opened (i.e. "users/16")
 @param animated Whether or not `UIViewController` transitions are animated.
 @exception RouteNotFoundException Thrown if url does not have a valid mapping
 @exception NavigationControllerNotProvided Thrown if url opens a `UIViewController` and navigationController has not been assigned
 @exception RoutableInitializerNotFound Thrown if the mapped `UIViewController` instance does not implement -initWithRouterParams: or +allocWithRouterParams:
 */
- (void)open:(NSString *)url animated:(BOOL)animated;

/**
 Triggers the appropriate functionality for a mapped URL, such as an anonymous function or opening a `UIViewController`
 @param url The URL being opened (i.e. "users/16")
 @param animated Whether or not `UIViewController` transitions are animated.
 @param extraParams more paramters to pass in while opening a `UIViewController`; take priority over route-specific default parameters
 @exception RouteNotFoundException Thrown if url does not have a valid mapping
 @exception NavigationControllerNotProvided Thrown if url opens a `UIViewController` and navigationController has not been assigned
 @exception RoutableInitializerNotFound Thrown if the mapped `UIViewController` instance does not implement -initWithRouterParams: or +allocWithRouterParams:
 */
- (void)open:(NSString *)url animated:(BOOL)animated extraParams:(NSDictionary *)extraParams;

/**
 Get params of a given URL, simply return the params dictionary NOT using a block
 @param url The URL being detected (i.e. "users/16")
 */
- (NSDictionary*)paramsOfUrl:(NSString*)url;

@end
