
#import "UI3DTouchController.h"

@interface _DTouchController ()

@property (nonatomic, strong) StringBlock performActionForShortcutItemHandler;

- (void)addShortcurItems:(NSArray *)shortcutItems;

@end

@implementation _DTouchController

@def_singleton( _DTouchController )

- (void)addShortcurItems:(NSArray *)shortcutItems {
    if (system_version_greater_than_or_equal_to(@"9.0")) {
        [[UIApplication sharedApplication] setShortcutItems:shortcutItems];
    } else {
        LOG(@"你的手机暂不支持3D Touch!");
    }
}

#pragma mark - Public

- (void)createUIApplicationShortcutItemsWithParams:(NSArray *)params {
    if (system_version_greater_than_or_equal_to(@"9.0")) {
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary *param in params) {
            UIApplicationShortcutItem *item = UIApplicationShortcutItemMake(param[@"type"], param[@"title"], param[@"subtitle"], param[@"imagename"]);
            
            [items addObject:item];
        }
        
        if (items.count) {
            [self addShortcurItems:items];
        }
    } else {
        LOG(@"你的手机暂不支持3D Touch!");
    }
}

- (void)setPerformActionForShortcutItemHandler:(StringBlock)performActionForShortcutItemHandler {
    _performActionForShortcutItemHandler = performActionForShortcutItemHandler;
}

- (void)handleWhenApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (system_version_greater_than_or_equal_to(@"9.0")) {
        UIApplicationShortcutItem *shortcutItem = [launchOptions valueForKey:UIApplicationLaunchOptionsShortcutItemKey];
        if (shortcutItem) {
            if (self.performActionForShortcutItemHandler) {
                self.performActionForShortcutItemHandler(shortcutItem.type);
            }
        }
    }
}

- (void)handleWhenApplication:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if (system_version_greater_than_or_equal_to(@"9.0")) {
        if (self.performActionForShortcutItemHandler) {
            self.performActionForShortcutItemHandler(shortcutItem.type);
        }
    }
}

@end
