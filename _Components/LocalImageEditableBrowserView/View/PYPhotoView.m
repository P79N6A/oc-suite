#import "_building_precompile.h"
#import "PYPhotoView.h"
#import "PYPhoto.h"
#import "PYConst.h"
#import "PhotosReaderController.h"
#import "PYPhotoCell.h"

// cell的宽
#define PYPhotoCellW (_photoCell.width > 0 ? _photoCell.width : screen_width)
// cell的高
#define PYPhotoCellH (_photoCell.height > 0 ? _photoCell.height : screen_height)

// 旋转角为PI的整数倍
#define PYHorizontal (ABS(_rotation) < 0.01 || ABS(_rotation - M_PI) < 0.01 || ABS(_rotation - M_PI * 2) < 0.01)

// 旋转角为90°或者270°
#define PYVertical (ABS(_rotation - M_PI_2) < 0.01 || ABS(_rotation - M_PI_2 * 3) < 0.01)


@interface PYPhotoView () <UIGestureRecognizerDelegate>
/** 单击手势 */
@property (nonatomic, weak) UIGestureRecognizer *singleTap;

/** photoCell的单击手势 */
@property (nonatomic, weak) UIGestureRecognizer *photoCellSingleTap;

/** contentScrollView的模拟锚点 */
@property (nonatomic, assign) CGPoint scrollViewAnchorPoint;
/** PYPhotoCell的模拟锚点 */
@property (nonatomic, assign) CGPoint photoCellAnchorPoint;

/** 旋转的角度 */
@property (nonatomic, assign) CGFloat rotation;

/** 手势状态 */
@property (nonatomic, assign) UIGestureRecognizerState state;

@end

@implementation PYPhotoView

#pragma mark - Life cycle

- (instancetype)init {
    if (self = [super init]) {
        // 运行与用户交互
        self.userInteractionEnabled = YES;
        
        // 添加单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidClicked:)];
        [self addGestureRecognizer:singleTap];
        self.singleTap = singleTap;
        
        // 添加捏合、放大手势
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidPinch:)];
        [self addGestureRecognizer:pinch];

        // 监听通知
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(collectionViewDidScroll:) name:PYCollectionViewDidScrollNotification object:nil];
        
        // 设置原始锚点
        self.scrollViewAnchorPoint = self.layer.anchorPoint;
        
        // 默认放大倍数和旋转角度
        self.scale = 1.0;
        self.rotation = 0.0;


    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scale = 1.0;
    
    // 判断最终旋转角度如果为270、90
    if ((PYVertical && PYPhotoCellH > PYPhotoCellW) || (PYHorizontal && PYPhotoCellW > PYPhotoCellH) || !CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity)) return;
    
    // 第一次进来才需要
    CGFloat width = screen_width;
    CGFloat height = width * self.image.size.height / self.image.size.width;
    if (self.isBig || self.isPreview) { // 预览状态
        if (height > screen_height) { // 长图
            UIScrollView *contentScrollView = self.photoCell.contentScrollView;
            contentScrollView.scrollEnabled = YES;
            contentScrollView.contentSize = PYPhotoCellW > PYPhotoCellH ? CGSizeMake(height, width) : CGSizeMake(width, height);
            contentScrollView.size = CGSizeMake(PYPhotoCellW, PYPhotoCellH);
            contentScrollView.center = CGPointMake(PYPhotoCellW * 0.5, PYPhotoCellH * 0.5);
        } else {
            self.photoCell.contentScrollView.contentSize = self.size;
        }
    }
}


- (void)dealloc {
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)setscrollViewAnchorPoint:(CGPoint)scrollViewAnchorPoint {
    // 当锚点异常时不赋值
    if (scrollViewAnchorPoint.x < 0.01 || scrollViewAnchorPoint.y < 0.01) return;
    _scrollViewAnchorPoint = scrollViewAnchorPoint;
}

// 监听transform
- (void)setTransform:(CGAffineTransform)transform {
    [super setTransform:transform];
    
    // 如果手势没结束、没有放大、旋转手势，返回
    if (self.isRotationGesture) return;
    
    // 调整scrollView
    // 恢复photoView的x/y位置
    self.origin = CGPointZero;
    // 修改contentScrollView的属性
    UIScrollView *contentScrollView = self.photoCell.contentScrollView;
    contentScrollView.height = self.height < PYPhotoCellH ? self.height : PYPhotoCellH;
    contentScrollView.width = self.width < PYPhotoCellW ? self.width : PYPhotoCellW;
    contentScrollView.contentSize = self.size;
    // 根基模拟锚点调整偏移量
    CGFloat offsetX = contentScrollView.contentSize.width * self.scrollViewAnchorPoint.x - contentScrollView.width * self.photoCellAnchorPoint.x;
    CGFloat offsetY = contentScrollView.contentSize.height * self.scrollViewAnchorPoint.y - contentScrollView.height * self.photoCellAnchorPoint.y;
    
    if (ABS(offsetX) + contentScrollView.width > contentScrollView.contentSize.width) { // 偏移量超出范围
        offsetX = offsetX > 0 ? contentScrollView.contentSize.width - contentScrollView.width : contentScrollView.width - contentScrollView.contentSize.width;
    }
    if (ABS(offsetY) + contentScrollView.height > contentScrollView.contentSize.height) {  // 偏移量超出范围
        offsetY = offsetY > 0 ? contentScrollView.contentSize.height - contentScrollView.height :
        contentScrollView.height - contentScrollView.contentSize.height;
    }
    // 最后调整
    offsetX = offsetX < 0 ? 0 : offsetX;
    offsetY = offsetY < 0 ? 0 : offsetY;
    contentScrollView.contentOffset = CGPointMake(offsetX, offsetY);
    contentScrollView.center = CGPointMake(PYPhotoCellW * 0.5, PYPhotoCellH * 0.5);
}

- (void)setPhotoCell:(PYPhotoCell *)photoCell {
    _photoCell = photoCell;
    
    // photoCell添加单击手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidClicked:)];
    [photoCell addGestureRecognizer:singleTap];
    self.photoCellSingleTap = singleTap;
}

- (void)setImage:(UIImage *)image {
    if (!image) return;
    CGFloat height = PYPhotoCellW * image.size.height / image.size.width;
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    if (height > PYPhotoCellH) { // 长图
        if (self.isBig) { // 预览状态
            self.size = CGSizeMake(PYPhotoCellW, PYPhotoCellW * image.size.height / image.size.width);
        } else {
            self.size = CGSizeMake(PYPhotoCellW, PYPhotoCellH);
            // 显示最上面的
            UIGraphicsBeginImageContextWithOptions(self.size,YES, 0.0);
            // 绘图
            CGFloat width = self.width;
            CGFloat height = width * image.size.height / image.size.width;
            [image drawInRect:CGRectMake(0, 0, width, height)];
            // 保存图片
            image = UIGraphicsGetImageFromCurrentImageContext();
            // 关闭上下文
            UIGraphicsEndImageContext();
        }
    }
    [super setImage:image];

    CGFloat width = PYPhotoCellW;
    originalSize = self.image.size;
    if (PYPhotoCellW > PYPhotoCellH) { //  横屏
        if (originalSize.width > originalSize.height * 2) { // 原始图宽大于高的两倍
            width = PYPhotoCellW;
            height = width * originalSize.height / originalSize.width;
        } else {
            height = PYPhotoCellH;
            width = height * originalSize.width / originalSize.height;
        }
    }
    self.size = self.isBig ? CGSizeMake(width, height) : self.image.size;
    // 设置scrollView的大小
    self.photoCell.contentScrollView.height = self.height < PYPhotoCellH ? self.height : PYPhotoCellH;
    self.photoCell.contentScrollView.width = self.width < PYPhotoCellW ? self.width : PYPhotoCellW;
    self.photoCell.contentScrollView.center = CGPointMake(PYPhotoCellW * 0.5, PYPhotoCellH * 0.5);
    self.photoCell.contentScrollView.contentSize = self.size;
    
    // 刷新
    [self setNeedsLayout];
}

#pragma mark - Gesture handler

// 记录预览时的最原始大小（未伸缩\旋转）
static CGSize originalSize;

// 单击手势
- (void)imageDidClicked:(UITapGestureRecognizer *)sender {
    
    if ([self.delegate respondsToSelector:@selector(didSingleClick:)]) { // 自定义 自己管理点击事件
        [self.delegate didSingleClick:self];
        return;
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    { // 未发布
        if (self.isPreview) { // 正在预览
                NSNotification *notifaction = [[NSNotification alloc] initWithName:PYChangeNavgationBarStateNotification object:nil userInfo:userInfo];
                [center postNotification:notifaction];
        } else { // 将要预览
            // 进入预览界面
            userInfo[PYPreviewImagesDidChangedNotification] = self;
            NSNotification *notifaction = [[NSNotification alloc] initWithName:PYPreviewImagesDidChangedNotification object:nil userInfo:userInfo];
            [center postNotification:notifaction];
        }
    }
}

- (void)imageDidPinch:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.numberOfTouches < 2) { // 只有一只手指，取消手势
        [recognizer setCancelsTouchesInView:YES];
        [recognizer setValue:@(UIGestureRecognizerStateEnded) forKeyPath:@"state"];
        
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        // 获取锚点
        self.scrollViewAnchorPoint = [self setAnchorPointBaseOnGestureRecognizer:recognizer];
        // 当对图片放大到最大最次放大时，缩放因子就会变小
        CGFloat scaleFactor = 1.0;
        if (self.width > PYPhotoCellW * PYPreviewPhotoMaxScale && recognizer.scale > 1.0) {
            scaleFactor =  (1 + 0.01 * recognizer.scale) /  recognizer.scale;
        }
        // 记录手势
        self.state = recognizer.state;
        self.rotationGesture = NO;
        self.transform = CGAffineTransformScale(self.transform, recognizer.scale * scaleFactor, recognizer.scale * scaleFactor);
        // 复位
        recognizer.scale = 1;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded
        || recognizer.state == UIGestureRecognizerStateFailed
        || recognizer.state == UIGestureRecognizerStateCancelled) { // 手势结束\取消\失败
        // 判断是否缩小
        CGFloat scale = 1;
        if (PYHorizontal) { // 旋转角为PI的整数倍 并且竖屏
            if (self.width <= self.photo.verticalWidth) { // 缩小了(旋转0°、180°、360°)
                // 放大
                scale = self.photo.verticalWidth / self.width;
            } else if (self.width > self.photo.verticalWidth * PYPreviewPhotoMaxScale) { // 最大放大3倍
                scale = self.photo.verticalWidth * PYPreviewPhotoMaxScale / self.width;
            }
        } else if (PYVertical) { // 旋转角为90°或者270°
            if (originalSize.width > originalSize.height * 2) { // image高和屏幕高一样
                if (self.height < PYPhotoCellH) { // 比原来小了
                    scale = PYPhotoCellH / self.height;
                } else if (self.height > PYPhotoCellH * PYPreviewPhotoMaxScale) { // 超过了最大倍数
                    scale = PYPhotoCellH * PYPreviewPhotoMaxScale / self.height;
                }
            } else { // image宽和屏幕一样
                if (self.width < self.photo.verticalWidth) { // 比原来小了
                    scale = self.photo.verticalWidth / self.width;
                } else if (self.width > self.photo.verticalWidth * PYPreviewPhotoMaxScale) { // 超过了最大倍数
                    scale = self.photo.verticalWidth * PYPreviewPhotoMaxScale / self.width;
                }
            }
        }
        
        // 复位
        [UIView animateWithDuration:0.25  delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.transform = CGAffineTransformScale(self.transform, scale, scale);
        } completion:^(BOOL finished) {
            // 记录放大的倍数
            self.scale = self.width / self.photo.verticalWidth;
        }];
    }
}

#pragma mark - Notification handler

// 监听滚动，判断cell是否在屏幕上，初始化cell
- (void)collectionViewDidScroll:(NSNotification *)notification {
    // 取出参数
    NSDictionary *info = notification.userInfo;
    UIScrollView *scrollView = info[PYCollectionViewDidScrollNotification];
    
    if (!CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity) && ((self.photoCell.x >= scrollView.contentOffset.x + scrollView.width) || (CGRectGetMaxX(self.photoCell.frame) < scrollView.contentOffset.x)) && (self.width >= PYPhotoCellW || self.photoCell.contentScrollView.transform.a)) { //self.transform不为初始化状态并且不在屏幕上并且有缩放或者旋转，就要初始化
        self.rotation = 0.0;
        self.scale = 1.0;
        self.transform = CGAffineTransformIdentity;
        self.height = PYPhotoCellW * self.height / self.width;
        self.width = PYPhotoCellW;
        UIScrollView *contentScrollView = self.photoCell.contentScrollView;
        contentScrollView.contentSize = self.size;
        contentScrollView.size = self.size;
        contentScrollView.contentOffset = CGPointZero;
        contentScrollView.contentInset = UIEdgeInsetsZero;
        contentScrollView.x = 0;
        contentScrollView.y = (screen_height - contentScrollView.height) * 0.5;
        contentScrollView.transform = CGAffineTransformIdentity;
    }
}


/** 根据手势触摸点修改相应的锚点，就是沿着触摸点做相应的手势操作 */
- (CGPoint)setAnchorPointBaseOnGestureRecognizer:(UIGestureRecognizer *)gr {
    // 手势为空 直接返回
    if (!gr) return CGPointMake(0.5, 0.5);
    
    // 创建锚点
    CGPoint anchorPoint = CGPointZero; // scrollView的虚拟锚点
    CGPoint cellAnchorPoint = CGPointZero; // photoCell的虚拟锚点
    UIScrollView *scrollView = (UIScrollView *)[self superview];
    if ([gr isKindOfClass:[UIPinchGestureRecognizer class]]) { // 捏合手势
        if (gr.numberOfTouches == 2) {
            // 当触摸开始时，获取两个触摸点
            // 获取滚动视图上的触摸点
            CGPoint point1 = [gr locationOfTouch:0 inView:scrollView];
            CGPoint point2 = [gr locationOfTouch:1 inView:scrollView];
            anchorPoint.x = (point1.x + point2.x) / 2.0 / scrollView.contentSize.width;
            anchorPoint.y = (point1.y + point2.y) / 2.0 / scrollView.contentSize.height;
            // 获取cell上的触摸点
            CGPoint screenPoint1 = [gr locationOfTouch:0 inView:gr.view];
            CGPoint screenPoint2 = [gr locationOfTouch:1 inView:gr.view];
            cellAnchorPoint.x = (screenPoint1.x + screenPoint2.x) / 2.0 / gr.view.width;
            cellAnchorPoint.y = (screenPoint1.y + screenPoint2.y) / 2.0 / gr.view.height;
        }
    } else if ([gr isKindOfClass:[UITapGestureRecognizer class]]) { // 点击手势
        // 获取scrollView触摸点
        CGPoint scrollViewPoint = [gr locationOfTouch:0 inView:scrollView];
        anchorPoint.x = scrollViewPoint.x / scrollView.contentSize.width;
        anchorPoint.y = scrollViewPoint.y / scrollView.contentSize.height;
        // 获取cell上的触摸点
        CGPoint photoCellPoint = [gr locationOfTouch:0 inView:gr.view];
        cellAnchorPoint.x = photoCellPoint.x / gr.view.width;
        cellAnchorPoint.y = photoCellPoint.y / gr.view.height;
    }
    
    self.photoCellAnchorPoint = cellAnchorPoint;
    
    return anchorPoint;
}

@end
