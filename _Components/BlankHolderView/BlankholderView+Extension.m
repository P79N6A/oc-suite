#import "_building_precompile.h"
#import "BlankholderView+Extension.h"

const static char *blankholderDataSourceKey = "blankholderDataSourceKey";
const static char *blankholderViewKey = "blankholderViewKey";
const static char *userInfoKey = "userInfoKey";
const static char *blankholderViewBounceKey = "blankholderViewBounceKey";

#pragma mark -

@interface UITableView (Blankholder)

- (void)swizzled;

@end

@interface UICollectionView (Blankholder)

- (void)swizzled;

@end


#pragma mark -

@interface UIView ()

@property (nonatomic, strong) UIView *blankholderView;

@property (nonatomic, assign) BOOL blankholderViewBounce;

@end

@implementation UIView (Blankholder)

// 浮层
- (void)setBlankholderView:(UIView *)blankholderView {
    [self retainAssociatedObject:blankholderView forKey:blankholderViewKey];
}

- (UIView *)blankholderView {
    return [self getAssociatedObjectForKey:blankholderViewKey];
}

// 传递用户信息
- (void)setUserInfo:(NSDictionary *)userInfo {
    [self retainAssociatedObject:userInfo forKey:userInfoKey];
}

- (NSDictionary *)userInfo {
    return [self getAssociatedObjectForKey:userInfoKey];
}

// 存储table原本的bounce
- (void)setBlankholderViewBounce:(BOOL)blankholderViewBounce {
    [self retainAssociatedObject:@(blankholderViewBounce) forKey:blankholderViewBounceKey];
}

- (BOOL)blankholderViewBounce {
    return [[self getAssociatedObjectForKey:blankholderViewBounceKey] boolValue];
}

// 代理
- (void)setBlankholderDataSource:(id<UIBlankholderViewDataSource>)blankholderDataSource {
    if ([self isKindOfClass:[UITableView class]]) {
        
        [(UITableView *)self swizzled];
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        
        [(UICollectionView*)self swizzled];
    } else {
        exceptioning(@"未实现");
    }
    
    [self assignAssociatedObject:blankholderDataSource forKey:blankholderDataSourceKey];
}

- (id<UIBlankholderViewDataSource>)blankholderDataSource {
    return [self getAssociatedObjectForKey:blankholderDataSourceKey];
}

- (void)reloadBlankholderView {
    if (!self.blankholderDataSource) {
        return;
    }
    
    if ([self itemCount] > 0) {
        if ([self isKindOfClass:[UIScrollView class]]) {
            if ([self hasAssociatedObjectForKey:blankholderViewBounceKey]) {
                [(UIScrollView *)self setBounces:self.blankholderViewBounce];
            }
        }
        
        [self.blankholderView removeFromSuperview];
        self.blankholderView = nil;
        
    } else {
        if (self.blankholderView) {
            [self.blankholderView removeFromSuperview];
            self.blankholderView = nil;
        }
        
        if ([self.blankholderDataSource conformsToProtocol:@protocol(UIBlankholderViewDataSource)]
            && [self.blankholderDataSource respondsToSelector:@selector(blankholderView:superView:)]) {
            
            BlankholderView *view = [[BlankholderView alloc] initWithFrame:self.bounds];
            
            self.blankholderView = [self.blankholderDataSource blankholderView:view superView:self];
            
            if ([self.blankholderDataSource respondsToSelector:@selector(blankholderViewShouldShow)]) {
                self.blankholderView.hidden = ![self.blankholderDataSource blankholderViewShouldShow];
            }
        } else {
            self.blankholderView = [[BlankholderView alloc] initWithFrame:self.bounds];
            
            // 默认会有一张 空页面图
        }
        
        if (self.blankholderView) {
            if (([self isKindOfClass:[UITableView class]]
                 || [self isKindOfClass:[UICollectionView class]])
                && self.subviews.count > 1) {
                
                //只有当bounces为yes的时候才存储，可以防止多次请求为空，将用NO将yes覆盖导致scrollView不能弹跳
                if ([(UIScrollView *)self bounces]) {
                    self.blankholderViewBounce = YES;
                }
                
                [(UIScrollView *)self setBounces:NO];
                
                [self insertSubview:self.blankholderView atIndex:1];
            } else {
                [self addSubview:self.blankholderView];
            }
            
            self.blankholderView.frame = self.blankholderView.superview.bounds;
            self.blankholderView.backgroundColor = self.blankholderView.superview.backgroundColor;
        }
    }
}

- (NSInteger)itemCount {
    NSInteger itemCount = 0;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *view = (UITableView *)self;
        
        if (view.dataSource) {
            if ([view.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
                NSInteger section = [view.dataSource numberOfSectionsInTableView:view];
                for (int i = 0; i < section; i++) {
                    itemCount += [view.dataSource tableView:view numberOfRowsInSection:i];
                }
            } else {
                itemCount = [view.dataSource tableView:view numberOfRowsInSection:0];
            }
        }
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *view = (UICollectionView *)self;
        if (view.dataSource) {
            if ([view.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
                
                NSInteger section = [view.dataSource numberOfSectionsInCollectionView:view];
                for (int i = 0; i < section; i++) {
                    itemCount += [view.dataSource collectionView:view numberOfItemsInSection:i];
                }
            } else {
                itemCount = [view.dataSource collectionView:view numberOfItemsInSection:0];
            }
        }
        
    }
    
    return itemCount;
}

@end

#pragma mark - 

@implementation UITableView (Blankholder)

- (void)swizzled {
    execute_once(^{
        SEL originalSelector = @selector(reloadData);
        SEL swizzledSelector = @selector(yf_reloadData);
        [self.class swizzleMethod:originalSelector withMethod:swizzledSelector error:nil];
    })
}

- (void)yf_reloadData {
    [self yf_reloadData];
    [self reloadBlankholderView];
}

@end


@implementation UICollectionView (Blankholder)

- (void)swizzled {
    execute_once(^{
        SEL originalSelector = @selector(reloadData);
        SEL swizzledSelector = @selector(yf_reloadData);
        [self.class swizzleMethod:originalSelector withMethod:swizzledSelector error:nil];
    })
}

- (void)yf_reloadData {
    [self yf_reloadData];
    [self reloadBlankholderView];
}

@end
