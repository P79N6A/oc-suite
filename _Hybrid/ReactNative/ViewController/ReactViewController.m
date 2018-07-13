//
//  ReactViewController.m
//  hairdresser
//
//  Created by fallen.ink on 7/21/16.
//
//

#import "ReactViewController.h"

#if __has_RCTRootView

@interface ReactViewController () <RCTEventHandler>

@property (nonatomic, strong) RCTRootView *rootView;

@end

@implementation ReactViewController

#pragma mark - Initialize

- (void)initViews {
    // Check params
    NSAssert(self.params, @"params shouldn't be nil, or U should use @router_push");
    NSAssert(self.params[@"url"], @"url of params shouldn't be nil");
    NSAssert(self.params[@"title"], @"title of params shouldn't be nil");
    NSAssert(self.params[@"param"], @"param of params shouldn't be nil");
    NSAssert(self.params[@"module"], @"name of js module");
    
    NSURL *url = self.params[@"url"];
    NSString *title = self.params[@"title"];
    NSDictionary *param = self.params[@"param"];
    NSString *moduleName = self.params[@"module"];
    
    // View controller title
    self.title = title;
    
    // Init react view
    self.rootView = [[RCTRootView alloc] initWithBundleURL:url
                                                        moduleName:moduleName
                                                 initialProperties:param
                                                     launchOptions:nil];
    //注意，这里是 @"EmbedRNMeituan"
    self.rootView.frame = CGRectZero;
    [self.view addSubview:self.rootView];
    
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.top.equalTo(self.view.mas_top);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

- (void)initEvent {
    [[RCTEventStation sharedInstance] addEventObserver:self];
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
    
    [self initEvent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)navigationBarHiddenWhenAppear {
    return NO;
}

#pragma mark - Update

- (void)update {
//    self.rootView.initialProperties
}

#pragma mark - RCTEventHandler

- (NSString *)moduleName {
    NSString *moduleName = self.params[@"module"];
    
    return moduleName;
}

- (void)eventHandler:(NSString *)name extraParams:(NSDictionary *)params {
    if (self.eventHandler) {
        self.eventHandler(name, params);
    }
}


@end

#endif
