//
//  QQBaseTitleDisplayVC.m
//  QQBaseTitleDisplayVC
//
//  Created by YuanBo on 2016/11/3.
//  Copyright © 2016年 YuanBo. All rights reserved.
//

#import "UITitleDisplayViewController.h"
#import "Masonry.h"
#import "NSString+Size.h"
#import "UIColor+Extension.h"

static CGFloat kTitleViewHeight = 50;

@interface QQBaseTitleDisplayVC () <UIScrollViewDelegate>


@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (strong, nonatomic) UIView *contentView;

@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) NSMutableArray *reddotArray;
@property (nonatomic, strong) NSMutableArray *tagNewArray;  //不能用new开头 调换了一下名字

@property (strong, nonatomic) UIView *indicatorView;
/** 上次选中的索引(或者控制器) */
@property (nonatomic, assign) NSInteger lastSelectedIndex;

@property (assign, nonatomic) BOOL viewHasShowed;

@property (assign, nonatomic) BOOL selectedTypeAnimate;
@property (assign, nonatomic) NSInteger selectedTabIndex;

@end

@implementation QQBaseTitleDisplayVC


#pragma mark - life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.viewHasShowed = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(_viewHasShowed){
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint offset = self.contentScrollView.contentOffset;
        offset.x = self->_selectedTabIndex * self.contentScrollView.frame.size.width;
        [self.contentScrollView setContentOffset:offset animated:self->_selectedTabIndex];
        
        CGFloat centerX = (self->_selectedTabIndex + 0.5 ) * (screen_width / self.btnArray.count);
        if(self->_selectedTypeAnimate){
            [UIView animateWithDuration:.3 animations:^{
                [self.indicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.titleView.mas_left).offset(centerX);
                }];
                [self.titleView layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self clickTitleBtn:[self.btnArray objectAtIndex:self->_selectedTabIndex]];
            }];
        } else {
            [self.indicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.titleView.mas_left).offset(centerX);
            }];
            CGPoint offset = self.contentScrollView.contentOffset;
            offset.x = self->_selectedTabIndex * self.contentScrollView.frame.size.width;
            [self.contentScrollView setContentOffset:offset animated:NO];
            [self clickTitleBtn:[self.btnArray objectAtIndex:self->_selectedTabIndex]];
            [self.titleView layoutIfNeeded];
        }
    });
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.viewHasShowed = YES;
}

- (void)commitChildVC{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSAssert(self.childViewControllers.count > 1, @"请添加至少一个childVC");
    
    [self setupBasic];
    [self setupTitleView];
    [self addMyChildView];
    [self indicatorView];
    
    UIScrollView *scrollV = [UIScrollView new];
    [scrollV setContentOffset:CGPointMake(0, 0)];
    [self updateScrollviewContent:scrollV];
}

#pragma mark - setup
- (void)setupBasic{
    self.automaticallyAdjustsScrollViewInsets = NO;

    UIView *titleView = [UIView new];
    titleView.backgroundColor = [UIColor whiteColor];
    self.titleView = titleView;
    self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self.view);
        make.height.mas_equalTo(kTitleViewHeight);
    }];
    
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = self.allowBounce;
    self.contentScrollView = scrollView;
    self.contentScrollView.delegate = self;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(titleView.mas_bottom).offset(self.topMargin);
    }];
    
    self.pageIndex = 0;
}


- (void)setupTitleView
{
    NSInteger count = self.childViewControllers.count;
    
    for (NSInteger i = 0; i < count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleView addSubview:btn];
        CGFloat height = kTitleViewHeight;
        CGFloat width = screen_width / count;
        CGFloat x = i * width;
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(width);
            make.left.mas_equalTo(x);
            make.height.mas_equalTo(height);
        }];
        
        [btn setTitle:[self.childViewControllers[i] title] forState:UIControlStateNormal];
        [btn setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
        btn.titleLabel.font = self.titleFont;
        btn.tag = i +1001;
        [self.btnArray addObject:btn];
        [btn addTarget:self action:@selector(clickTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        //添加红点
        UILabel *reddotV = [UILabel new];
        reddotV.textAlignment = NSTextAlignmentCenter;
        reddotV.font = [UIFont systemFontOfSize:9];
        reddotV.textColor = [UIColor whiteColor];
        reddotV.backgroundColor = color_red;
        reddotV.translatesAutoresizingMaskIntoConstraints = NO;
        reddotV.text = @" ";
        [btn addSubview:reddotV];
        [self.reddotArray addObject:reddotV];
        [reddotV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(btn.titleLabel.mas_top);
            make.left.equalTo(btn.titleLabel.mas_right).offset(-3);
            make.height.mas_equalTo(0);
            make.width.mas_equalTo(0);
        }];
        [self setBadgeNumber:0 ForIndex:i];
        
        //添加new标示
        UILabel *newTagV = [UILabel new];
        newTagV.hidden = YES;
        newTagV.textAlignment = NSTextAlignmentCenter;
        newTagV.font = [UIFont systemFontOfSize:9];
        newTagV.textColor = [UIColor whiteColor];
        newTagV.backgroundColor = color_red;
        newTagV.translatesAutoresizingMaskIntoConstraints = NO;
        newTagV.text = @"NEW";
        float newTagVHeight = newTagV.font.lineHeight + 2;
        float newTagVWidth = [newTagV.text sizeWithFont:newTagV.font constrainedToSize:CGSizeMake(MAXFLOAT, [newTagV.font lineHeight]) lineBreakMode:NSLineBreakByWordWrapping].width + 4;
        newTagV.layer.cornerRadius = newTagVHeight * 0.5;
        newTagV.layer.masksToBounds = YES;
        [btn addSubview:newTagV];
        [self.tagNewArray addObject:newTagV];
        [newTagV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(btn.titleLabel.mas_top).offset(3);
            make.left.equalTo(btn.titleLabel.mas_right);
            make.height.mas_equalTo(newTagVHeight);
            make.width.mas_equalTo(newTagVWidth);
        }];
        
        
        //添加分割线
        if (i == count - 1) return;
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = self.titleSplitColor;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleView addSubview:view];
        
        CGFloat viewH = 12;
        CGFloat viewW = 1;
        CGFloat viewX = (i + 1)* width;
        CGFloat viewY = (self.titleView.bounds.size.height - viewH) * .5;

        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(viewW);
            make.height.mas_equalTo(viewH);
            make.left.mas_equalTo(viewX);
            make.top.mas_equalTo(viewY);
        }];
    }
}


- (UIView *)indicatorView{
    if (_indicatorView == nil) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = self.lineColor;
        CGFloat viewH = 2;
        CGFloat viewW = (_indicatorWidth ? _indicatorWidth : (screen_width / self.childViewControllers.count) * .7);
        CGFloat viewY = (kTitleViewHeight - viewH);
        CGFloat viewCenterX = (screen_width / self.childViewControllers.count ) *.5;

        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleView addSubview:view];

        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(2);
            make.width.mas_equalTo(viewW);
            make.centerX.equalTo(self.titleView.mas_left).offset(viewCenterX);
            make.top.mas_equalTo(viewY);
        }];
        
        self.indicatorView = view;
        [self.titleView layoutIfNeeded];
    }
    return _indicatorView;
}


- (void)addMyChildView{
    
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    self.contentView = contentView;
    contentView.userInteractionEnabled = YES;
    
    [self.contentScrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentScrollView);
        make.width.mas_equalTo(screen_width * self.childViewControllers.count);
    }];
    
    // 一些临时变量
    CGFloat width = screen_width;
    
    for (NSInteger VCIndex = 0; VCIndex < self.childViewControllers.count; VCIndex++) {
        CGFloat offsetX = width * VCIndex;
        
        UIViewController *subVC = self.childViewControllers[VCIndex];
        subVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [contentView addSubview:subVC.view];
        [subVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
            make.left.mas_equalTo(offsetX);
            make.top.bottom.equalTo(self.contentView);
            make.height.equalTo(self.contentScrollView);
        }];
    }
}

- (CGFloat)getTotalHeightWithContentHeight:(CGFloat)contentHeight{
    return kTitleViewHeight + _topMargin + contentHeight;
}


#pragma mark - private func
//根据btn的tag来识别是第几页
- (void)clickTitleBtn:(UIButton *)sender {
    // 取出被点击label的索引
    NSInteger index = sender.tag - 1001;
    self.pageIndex = index;
    
    if(self.viewHasShowed){  // view已经显示好了才会需要通知代理
        if ([self.delegate respondsToSelector:@selector(didSrollToIndex:)]) {
            [self.delegate didSrollToIndex:index];
        }
        
        if ([self.delegate respondsToSelector:@selector(didSrollToVC:)]) {
            UIViewController *subVC = self.childViewControllers[index];
            [self.delegate didSrollToVC:subVC];
        }
    }
    
    for (UIButton *btn in self.btnArray) {
        btn.enabled = NO;
        btn.selected = NO;
    }
    
    if (self.animationType == QQTitleDisplayAnimationTypeDelayed) {
        CGFloat centerX = (index + 0.5 ) * (screen_width / self.btnArray.count);
    
        [UIView animateWithDuration:.3 animations:^{
    
            [self.indicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.titleView.mas_left).offset(centerX);
            }];
        
            [self.titleView layoutIfNeeded];
        }];
    }

    sender.selected = YES;
    for (UIButton *btn in self.btnArray) {
        if (btn.selected == NO) {
            btn.enabled = YES;
            [btn setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
            [btn setTitleColor:self.normalTitleColor forState:UIControlStateSelected];
        }else{
            [btn setTitleColor:self.selectTitleColor forState:UIControlStateNormal];
            [btn setTitleColor:self.selectTitleColor forState:UIControlStateSelected];
        }
    }
    
    // 让底部的内容scrollView滚动到对应位置
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = index * self.contentScrollView.frame.size.width;
    [self.contentScrollView setContentOffset:offset animated:YES];
}

- (void)updateScrollviewContent:(UIScrollView *)scrollView{
    // 一些临时变量
    CGFloat width = screen_width;
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 当前位置需要显示的控制器的索引
    NSInteger index = offsetX / width;
    
    //取到对应页数的btn, 然后设置选中状态
    UIButton *btn = self.btnArray[index];
    [self clickTitleBtn:btn];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self updateScrollviewContent:scrollView];
}

//手指松开scrollView后，scrollView停止减速完毕就会调用这个
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updateScrollviewContent:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.animationType == QQTitleDisplayAnimationTypeDefault) {
        CGFloat centerX = screen_width /(self.childViewControllers.count*2) + scrollView.contentOffset.x/self.childViewControllers.count;
        [self.indicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.titleView.mas_left).offset(centerX);
        }];
    }
}

#pragma mark  - public func
- (void)setBadgeNumber:(NSInteger)count ForIndex:(NSInteger)index{
        UILabel *reddotLabel = self.reddotArray[index];
    
        if (count == 0) {
            reddotLabel.hidden = YES;
        }else if(count < 0){
            reddotLabel.hidden = NO;
            reddotLabel.text = @"";
            [reddotLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(8);
                make.width.mas_equalTo(8);
            }];
            reddotLabel.layer.cornerRadius = 8 * 0.5;
            reddotLabel.layer.masksToBounds  = YES;
        }else{ /* >0 */
            reddotLabel.hidden = NO;
            reddotLabel.text = [NSString stringWithFormat:@"%ld",count];
            float lineWidth = [reddotLabel.text sizeWithFont:reddotLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, [reddotLabel.font lineHeight]) lineBreakMode:NSLineBreakByWordWrapping].width;
            
            CGSize redSize = CGSizeMake(lineWidth, [reddotLabel.font lineHeight]);
            [reddotLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                
                make.width.mas_equalTo(ceilf(MAX(redSize.width + 3, [reddotLabel.font lineHeight] + 3)) );
                make.height.mas_equalTo(ceilf(redSize.height + 3));
            }];
            [reddotLabel layoutIfNeeded];
            reddotLabel.layer.cornerRadius = ceilf(([reddotLabel.font lineHeight] + 3) * 0.5);
            reddotLabel.layer.masksToBounds  = YES;
        }
}

- (void)setBadgeNumber:(NSInteger)count ForVC:(__kindof UIViewController *)vc{
    NSInteger index = [self.childViewControllers indexOfObject:vc];
    [self setBadgeNumber:count ForIndex:index];
}

- (void)setNewTagShow:(BOOL)show ForIndex:(NSInteger)index{
    UILabel *NewTag = self.tagNewArray[index];
    NewTag.hidden = !show;
}

- (void)setNewTagShow:(BOOL)show ForVC:(__kindof UIViewController *)vc{
    NSInteger index = [self.childViewControllers indexOfObject:vc];
    [self setNewTagShow:show ForIndex:index];
}

- (void)setSelectIndex:(NSInteger)index withAnimation:(BOOL)animation{
    
    _selectedTabIndex = index;
    _selectedTypeAnimate = animation;
}

#pragma mark - property
- (NSMutableArray *)btnArray{
    if (_btnArray == nil) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

- (UIFont *)titleFont{
    if (_titleFont == nil) {
        _titleFont = [UIFont systemFontOfSize:15];
    }
    return _titleFont;
}

- (UIColor *)normalTitleColor{
    if (_normalTitleColor == nil) {
        _normalTitleColor = font_gray_4;
    }
    
    return _normalTitleColor;
}

- (UIColor *)selectTitleColor{
    if (_selectTitleColor == nil) {
        _selectTitleColor = color_green;
    }
    return _selectTitleColor;
}

- (UIColor *)lineColor{
    if (_lineColor == nil) {
        _lineColor = color_green;
    }
    
    return _lineColor;
}

- (UIColor *)titleSplitColor{
    if (_titleSplitColor == nil) {
        _titleSplitColor = font_gray_1;
    }
    return _titleSplitColor;
}

- (NSMutableArray *)reddotArray{
    if (_reddotArray ==nil) {
        _reddotArray = [NSMutableArray new];
    }
    return _reddotArray;
}

- (NSMutableArray *)tagNewArray{
    if (_tagNewArray ==nil) {
        _tagNewArray = [NSMutableArray new];
    }
    return _tagNewArray;
}

- (CGFloat)topMargin{
    if (_topMargin == 0 ) {
        _topMargin = 1;
    }
    
    return _topMargin;

}

- (void)setAllowBounce:(BOOL)allowBounce{
    _allowBounce = allowBounce;
    if (self.contentScrollView) {
        self.contentScrollView.bounces = allowBounce;
    }
}

@end
