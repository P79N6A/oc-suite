//
//  _StatusBarController.m
//  _Building
//
//  Created by 7 on 2018/8/12.
//

#import "_Foundation.h"
#import "_StatusBarController.h"

@interface _StatusBarController ()

@singleton( _StatusBarController )

@property (atomic, assign) BOOL statusBarLocked;

@end

@implementation _StatusBarController

@def_singleton( _StatusBarController )

- (instancetype)init {
    if (self = [super init]) {
        self.statusBarLocked = NO;
    }
    
    return self;
}

+ (void)lockStatusBar {
    @synchronized(self.sharedInstance) {
        self.sharedInstance.statusBarLocked = YES;
    }
}

+ (void)unlockStatusBar {
    @synchronized(self.sharedInstance) {
        self.sharedInstance.statusBarLocked = NO;
    }
}

+ (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        if (!self.sharedInstance.statusBarLocked) {
            statusBar.backgroundColor = color;
        }
    }
}

@end
