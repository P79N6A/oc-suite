#import "BlankholderView.h"

#pragma mark - Usage

/**
 *  第一步：
 *      #import "BlankholderView+Extension.h", 设置<UIBlankholderDataSource>
 
 *  第二步：
 *      self.tableView.emptyCoverSource = self;
 *      或
 *      self.collectionView.emptyCoverSource = self;
 
 *  第三步：
 *      实现emptyCoverViewFromInitializeEmptyCoverView：onView，该方法会自动生成一个emptyCoverView，自定义后return 即可。
 *
 *      #pragma mark UIScrollViewEmptyCoverSource
 *
 *      -(UIView *)emptyCoverViewFromInitializeEmptyCoverView:(EmptyCoverView *)emptyCoverView onView:(UIView *)view
 *      {
 *          //1. 不会有cover显示；
 *          return nil;
 
 *          //2. 显示自定义view；
 *          return [UIView new];
 
 *          //3. 显示默认EmptyCoverView，效果等同不实现emptyCoverViewFromInitializeEmptyCoverView：onView方法
 *          return emptyCoverView;
 
 *          //4. 自定义emptyCoverView；
 *          emptyCoverView.imageView.image = nil;
 *          emptyCoverView.titleLbl.text = @"Cover";
 
 *          //5. 可以通过给view.userinfo传值来判断是网络问题，还是无数据，还是其他，来修改coverview的显示
 *          if (view.userInfo) {
 *              emptyCoverView.actionBtn.hidden = YES;
 *          } else {
 *              emptyCoverView.actionBtn.hidden = NO;
 *          }
 *          return emptyCoverView;
 *      }
 *
 */

#pragma mark -

@protocol UIBlankholderViewDataSource;

@interface UIView (Blankholder)

/**
 *  代理，需要显示浮层就必须设置，交换reloadData方法在这里执行。
 */
@property(nonatomic, weak)id <UIBlankholderViewDataSource> blankholderDataSource;

/**
 *  可以在配置EmptyCoverView时获取，用来传递一些信息，比如提示信息，或者判断是空还是网络问题。默认为nil；
 */
@property(nonatomic, strong) NSDictionary *userInfo;

@end

@protocol UIBlankholderViewDataSource <NSObject>

/**
 *  UIBlankholderDataSource用于配置浮层view
 *
 *  @param view 初始化的emptyCoverView，直接return emptyCoverView同没有实现UIViewEmptyCoverSource同样效果。
 *  @param superView 当前super view
 *
 *  @return 返回一个view，可以是配置后的emptyCoverView的，也可以是自定义view，可以为nil；
 */
- (UIView *)blankholderView:(BlankholderView *)view superView:(UIView *)superView;

- (BOOL)blankholderViewShouldShow;

@end
