#import "_building_precompile.h"
#import "PhotosReaderController.h"
#import "PYPhotoView.h"
#import "PYPhoto.h"
#import "PYPhotoCell.h"
#import "PYConst.h"
#import "UIImageView+WebCache.h"

@interface PhotosReaderController ()<UICollectionViewDelegateFlowLayout>

// 所有图片
@property (nonatomic, strong) NSArray *photoViews;

/** 分页计数器 */
@property (nonatomic, strong) UIPageControl *pageControl;

/** 分页计数（文本） */
@property (nonatomic, strong) UILabel *pageLabel;

/** 存储indexPaths的数组 */
@property (nonatomic, strong) NSMutableArray *indexPaths;

/** 是否正在拖拽 */
@property (nonatomic, assign) BOOL dragging;

@end

@implementation PhotosReaderController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册cell
    [self.collectionView registerClass:[PYPhotoCell class] forCellWithReuseIdentifier:[PYPhotoCell identifier]];
    
    // 支持分页
    self.collectionView.pagingEnabled = YES;
    self.collectionView.size = CGSizeMake(self.view.width, self.view.height);
    
    // 设置collectionView的width
    // 获取行间距
    CGFloat lineSpacing = ((UICollectionViewFlowLayout *)self.collectionViewLayout).minimumLineSpacing;
    self.collectionView.width += lineSpacing;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, lineSpacing);

    // 取消水平滚动条
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentOffset = CGPointMake(self.selectedIndex * self.collectionView.width, 0);
}

#pragma mark - Config

- (void)configWithImages:(NSArray<UIImage *> *)images selectedIndex:(NSUInteger)selectedIndex {
    NSMutableArray *photoViews = [NSMutableArray new];
    for(int i = 0; i < images.count; i++) {
        PYPhotoView *photoView = [PYPhotoView new];
        
        // 设置标记
        photoView.tag = i;
        photoView.photo = [PYPhoto new];
        
        // 设置图片
        photoView.image = images[i];
        
        [photoViews addObject:photoView];
    }
    
    self.photoViews = photoViews;
    
    PYPhotoView *photoView = [photoViews safeObjectAtIndex:selectedIndex];
    photoView.image = [images safeObjectAtIndex:selectedIndex];
    self.selectedPhotoView = photoView;
    
    self.images = [images mutableCopy];
}

- (void)configWithPhotos:(NSArray<PYPhoto *> *)photos selectedIndex:(NSUInteger)selectedIndex {
    self.photos = photos;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedPhotoView.isMovie ? 1 : self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 创建cell
    PYPhotoCell *cell = [PYPhotoCell cellWithCollectionView:collectionView indexPath:indexPath];

    // 设置数据
    cell.photo = [PYPhoto new];
    
    self.selectedPhotoView.windowView = cell.photoView;

    // 返回cell
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.dragging = YES;
}

// 监听scrollView的滚动事件， 判断当前页数
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x != self.selectedIndex * self.collectionView.width && IOS8 && !self.dragging) { // 修复在iOS8系统下，scrollView.contentOffset被系统又初始化的BUG
        scrollView.contentOffset = CGPointMake(self.selectedIndex * self.collectionView.width, 0);
    }

    // 发出通知
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[PYCollectionViewDidScrollNotification] = scrollView;
    [[NSNotificationCenter defaultCenter] postNotificationName:PYCollectionViewDidScrollNotification object:nil userInfo:userInfo];
    if (scrollView.contentOffset.x >= scrollView.contentSize.width || scrollView.contentOffset.x <= 0) return;
    
    // 计算页数
    NSInteger page = self.collectionView.contentOffset.x / self.collectionView.width + 0.5;
    self.pageControl.currentPage = page;
    
    self.selectedPhotoView = self.photoViews[page];
    
    // 判断即将显示哪一张
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForItem:page inSection:0];
    PYPhotoCell *currentCell = (PYPhotoCell *)[self.collectionView cellForItemAtIndexPath:currentIndexPath];
    self.selectedPhotoView.windowView = currentCell.photoView;
}

#pragma mark - UICollectionViewDelegateFlowLayout

// 设置每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemHeight = screen_height;
    self.collectionView.height = itemHeight;
    return CGSizeMake(collectionView.width - ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).minimumLineSpacing, itemHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

#pragma mark - Lazy load

- (NSUInteger)selectedIndex {
    return self.selectedPhotoView.tag;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        _pageControl = pageControl;
        _pageControl.width = self.view.width;
        _pageControl.y = self.view.height - 30;
        if (IOS8) { // 如果是iOS8,补上状态栏20的高度
            _pageControl.y += 20;
        }
    }
    _pageControl.hidden = self.pageType == PYPhotosViewPageTypeLabel || _pageControl.numberOfPages > 9 || _pageControl.numberOfPages < 2;
    self.pageLabel.text = [NSString stringWithFormat:@"%zd / %zd", _pageControl.currentPage + 1, _pageControl.numberOfPages];
    return _pageControl;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        UILabel *pageLabel = [[UILabel alloc] init];
        pageLabel.height = 44;
        pageLabel.width = self.view.width;
        pageLabel.y = self.view.height - 54;
        if (IOS8) { // 如果是iOS8,补上状态栏20的高度
            pageLabel.y += 20;
        }
        pageLabel.font = [UIFont boldSystemFontOfSize:16];
        pageLabel.textColor = [UIColor whiteColor];
        pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel = pageLabel;
    }
    // 判断是否显示_pageLabel
    // 取出指示类型
    _pageLabel.hidden = self.pageType == PYPhotosViewPageTypeControll && _pageControl.numberOfPages < 10;
    return _pageLabel;
}

- (NSMutableArray *)indexPaths {
    if (!_indexPaths) {
        _indexPaths = [NSMutableArray array];
    }
    return _indexPaths;
}

@end
