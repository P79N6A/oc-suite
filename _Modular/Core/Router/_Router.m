
#import "_Router.h"
//#import "UINavigationController+Extension.h"

@interface _Router ()

@end

@implementation _Router

@def_singleton( _Router )

#pragma mark - Initialize

- (instancetype)init {
    self = [super init];
    if (self) {
        route = [Routable sharedRouter];
    }
    return self;
}

#pragma mark - Interface

- (void)setNavigationController:(UINavigationController *)controller {
    [route setNavigationController:controller];
}

- (void)pop {
    [route pop];
}

- (void)popViewControllerFromRouterAnimated:(BOOL)animated {
    [route popViewControllerFromRouterAnimated:animated];
}

- (void)pop:(BOOL)animated {
    [route pop:animated];
}

- (void)map:(NSString *)format toCallback:(RouterOpenCallback)callback {
    [route map:format toCallback:callback];
}

- (void)map:(NSString *)format toCallback:(RouterOpenCallback)callback withOptions:(UPRouterOptions *)options {
    [route map:format toCallback:callback withOptions:options];
}

- (void)map:(NSString *)format toController:(Class)controllerClass {
    [route map:format toController:controllerClass];
}

- (void)map:(NSString *)format toController:(Class)controllerClass withOptions:(UPRouterOptions *)options {
    [route map:format toController:controllerClass withOptions:options];
}

///-------------------------------
/// @name Opening URLs
///-------------------------------

- (void)openExternal:(NSString *)url {
    [route openExternal:url];
}

- (void)open:(NSString *)url {
    [route open:url];
}

- (void)open:(NSString *)url animated:(BOOL)animated {
    [route open:url animated:animated];
}

- (void)open:(NSString *)url animated:(BOOL)animated extraParams:(NSDictionary *)extraParams {
    [route open:url animated:animated extraParams:extraParams];
}

- (NSDictionary*)paramsOfUrl:(NSString*)url {
    return [route paramsOfUrl:url];
}

@end
