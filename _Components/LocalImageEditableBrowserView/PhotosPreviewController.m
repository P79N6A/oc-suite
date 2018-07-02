
#import "_building_precompile.h"
#import "_building_application.h"
#import "BaseNavigationController.h"
#import "PhotosPreviewController.h"
#import "PYPhotoCell.h"

@interface PhotosPreviewController ()<UIActionSheetDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) BOOL isFirst;

/** 记录statusBar是否隐藏 */
@property (nonatomic, assign, getter=isStatusBarHidden) BOOL statusBarHidden;

/** 是否正在执行动画 */
@property (nonatomic, assign, getter=isNavBarAnimating) BOOL navBarAnimating;

/** 删除一张图片 */
- (void)deleteImage;

/** 关闭控制器 */
- (void)close;

@end

@implementation PhotosPreviewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithCollectionViewLayout:layout]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

+ (instancetype)previewController {
    // 创建流水布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 设置间距
    layout.minimumLineSpacing = PYPreviewPhotoSpacing;
    layout.minimumInteritemSpacing = 0;
    // 设置滚动方向
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 创建预览控制器
    PhotosPreviewController *readerVc = [[PhotosPreviewController alloc] initWithCollectionViewLayout:layout];
    readerVc.pageType = PYPhotosViewPageTypeLabel;
    
    readerVc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:readerVc action:@selector(backAction)];
    readerVc.navigationController.navigationBar.backIndicatorImage = nil;
    readerVc.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    readerVc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:readerVc action:@selector(trashDidClicked)];
    
    return readerVc;
}

- (BaseNavigationController *)withNavigationController {
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:self];
    [nav configNavigationBar:^(UINavigationBar *bar) {
        // 设置背景颜色
        bar.barTintColor = color_with_rgb(15, 16, 19);
        // 设置主题颜色
        bar.tintColor = [UIColor whiteColor];
        // 设置字体颜色
        NSDictionary *attr = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                NSFontAttributeName : [UIFont boldSystemFontOfSize:20]
                                };
        [bar setTitleTextAttributes:attr];
    }];

    return nav;
}

- (void)showInViewController:(UIViewController *)viewController {
    if (viewController) {
        [viewController presentViewController:[self withNavigationController] animated:YES completion:nil];
    } else {
        UIViewController *presentFromVc = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
        if (!presentFromVc) { // 如果为空，就使用根控制器
            presentFromVc = [UIApplication sharedApplication].keyWindow.rootViewController;
        }
        [presentFromVc presentViewController:[self withNavigationController] animated:YES completion:nil];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.isFirst) {
        self.collectionView.contentOffset = CGPointMake(self.selectedIndex * self.collectionView.width, 0);
        self.isFirst = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *title = [NSString stringWithFormat:@"%zd/%zd", self.selectedIndex + 1, self.images.count];
    self.title = title;
    // 用来判断是否偏移
    self.isFirst = YES;
    
    // 监听通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(changeNavBarState) name:PYChangeNavgationBarStateNotification object:nil];
}

// 状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// 状态栏隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

// 状态栏是否隐藏
- (BOOL)prefersStatusBarHidden {
    return self.isStatusBarHidden;
}

// 改变状态栏状态
- (void)changeNavBarState {
    // 如果正在执行动画，直接返回
    if (self.isNavBarAnimating) return;
    CGFloat duration = 0.5;
    [UIView animateWithDuration:duration animations:^{
        self.navBarAnimating = YES;
        self.statusBarHidden = self.navigationController.navigationBar.y > 0;
        [self setNeedsStatusBarAppearanceUpdate];
        self.navigationController.navigationBar.y = self.statusBarHidden ? -self.navigationController.navigationBar.height : [UIApplication sharedApplication].statusBarFrame.size.height;
    } completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navBarAnimating = NO;
    });
}

- (void)close {
    [self backAction];
}

- (void)backAction {
    // 调用代理实现
    if ([self.delegate respondsToSelector:@selector(photosPreviewController:didImagesChanged:)]) {
        [self.delegate photosPreviewController:self didImagesChanged:self.images];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)trashDidClicked {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"要删除这张照片么" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
}

// 删除图片
- (void)deleteImage {
    NSInteger page = self.collectionView.contentOffset.x / self.collectionView.width + 0.5;
    // 取出可见cell
    // 判断即将显示哪一张
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForItem:page inSection:0];
    PYPhotoCell *currentCell = (PYPhotoCell *)[self.collectionView cellForItemAtIndexPath:currentIndexPath];
    
    // 移除数组中的某个元素
    [self.images removeObjectAtIndex:page];
    
    // 移除cell
    [currentCell removeFromSuperview];
    // 刷新cell
    [self.collectionView reloadData];
    
    NSUInteger currentPage = self.selectedIndex;
    currentPage = self.selectedIndex <= 1 ? 1 : self.selectedIndex;
    // 往前移一张
    self.collectionView.contentOffset = CGPointMake((currentPage - 1) * self.collectionView.width, 0);
    // 刷新标题
    self.title = [NSString stringWithFormat:@"%zd/%zd", currentPage, self.images.count];
    
    if (self.images.count == 0) {
        // 来到这里，证明
        [self backAction];
    };
}

#pragma mark - <UIActionSheetDelegate>
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // 删除
        [self showSuccess:@"已删除"];// 计算页数
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 删除图片
            [self deleteImage];
        });
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PYPhotoCell *cell  = [PYPhotoCell cellWithCollectionView:collectionView indexPath:indexPath];
    cell.image = self.images[indexPath.item];
    cell.photoView.isPreview = YES;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    // 设置contentScrollView
    UIScrollView *contentScrollView = self.selectedPhotoView.windowView.photoCell.contentScrollView;
    contentScrollView.height = contentScrollView.height > screen_height ? screen_height : contentScrollView.height;
    contentScrollView.contentOffset = CGPointZero;
    contentScrollView.scrollEnabled = YES;
    contentScrollView.center = CGPointMake(screen_width * 0.5, screen_height * 0.5);
    // 隐藏状态栏
    if (!self.isStatusBarHidden) [self changeNavBarState];
    // 设置标题
    self.title = [NSString stringWithFormat:@"%zd/%zd", self.selectedIndex + 1,self.images.count];
}

#pragma mark <UICollectionViewDelegateFlowLayout>
// 设置每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return screen_size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

@end
