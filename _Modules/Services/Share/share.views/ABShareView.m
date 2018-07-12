//
//  ABShareView.m
//  ABPicBrower
//
//  Created by 杜亚伟 on 2017/4/19.
//  Copyright © 2017年 杜亚伟. All rights reserved.
//

#import "ABShareView.h"
@interface ABShareView ()

@property(nonatomic,weak) UIView* backView;

@property(nonatomic,weak) UIView* shareView;

@end

@implementation ABShareView


-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self initBackgroundView];
        [self initSubviews];
    }
    return self;
}

-(void)initBackgroundView{
    //设置半透明的背景色
    UIView* backView=[[UIView alloc] initWithFrame:self.bounds];
    backView.backgroundColor=[UIColor blackColor];
    backView.alpha = 0.3;
    [self addSubview:backView];
    self.backView = backView;
}

-(void)initSubviews{
    
    NSArray<NSString*> *titleArray = @[@"微信",@"朋友圈"];
    NSArray<NSString*> *imageArray = @[@"share_weixin",@"share_friends"];
    
    NSInteger numberCount = titleArray.count;
    NSInteger lineCount;
    CGFloat cancleHeight;
    NSInteger betCount;
    CGFloat btnHeight;
    
    if ([UIScreen mainScreen].bounds.size.width<360) {
        cancleHeight = 40;
    }else{
        cancleHeight = 50;
    }
    
    if (numberCount % 4==0) {
        lineCount = numberCount/4;
    }else{
        lineCount = (numberCount/4)+1;
    }
    
    if (numberCount<=4) {
        betCount = numberCount-1;
    }else{
        betCount = 3;
    }
    
    CGFloat btnWH = ([UIScreen mainScreen].bounds.size.width-((betCount*20)+20))/(numberCount>4?4:numberCount);
    if (numberCount<3) {
        btnHeight = btnWH*0.6;
    }else{
        btnHeight = btnWH;
    }
    
    CGFloat boomBetween = ([UIScreen mainScreen].bounds.size.height==812)? 34:0;
    CGFloat btnBet = 20;
    CGFloat buttonTitleBet;
    CGFloat shareHeight = btnHeight*lineCount+(lineCount-1)*20+cancleHeight+5+10+20+boomBetween;
    
    UIView* shareView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, shareHeight)];
    shareView.backgroundColor = [UIColor whiteColor];
    [self addSubview:shareView];
    self.shareView = shareView;
    
    //初始化分享子控件
    
    for (int i = 0; i < numberCount; i++) {
        CGFloat Y;
        CGFloat X;
        if (numberCount>4) {
            Y = i / 4;
            X = i % 4;
        }else{
            Y = 0;
            X = i;
        }
        
        UIButton* button = [[UIButton alloc] init];
        button.frame = CGRectMake(10+(btnBet+btnWH)*X, 20+(20+btnWH)*Y, btnWH, btnHeight);
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        if ([UIScreen mainScreen].bounds.size.width==320) {
            button.titleLabel.font = [UIFont systemFontOfSize:11];
            buttonTitleBet = 20;
        }else{
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            buttonTitleBet = 30;
        }
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addTarget: self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:button];
        
        ///计算button中心点imageview最大x的差
        CGFloat b1 = button.bounds.size.width/2.0-(button.imageView.frame.origin.x+button.imageView.bounds.size.width);
        ///button的label中心点减去上面的差值就是label的到button中心点的偏移量
        CGFloat b2 = button.titleLabel.bounds.size.width/2.0 -b1;
        ///计算imageview到button中心点的偏移量
        CGFloat b3 = button.bounds.size.width/2.0 - (button.imageView.frame.origin.x+button.imageView.bounds.size.width/2.0);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, b3, buttonTitleBet, -b3);
        button.titleEdgeInsets = UIEdgeInsetsMake(25, -b2-30, -25, b2-30);
    }
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, shareView.bounds.size.height-cancleHeight-1-boomBetween, shareView.bounds.size.width, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    lineView.alpha = 0.5;
    [shareView addSubview:lineView];
    
    UIButton* cancleShare = [[UIButton alloc] initWithFrame:CGRectMake(0, shareView.bounds.size.height-cancleHeight-boomBetween, shareView.bounds.size.width, cancleHeight)];
    cancleShare.backgroundColor = [UIColor whiteColor];
    [cancleShare setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancleShare setTitle:@"取消" forState:UIControlStateNormal];
    [cancleShare addTarget: self action:@selector(cancleShareClick:) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:cancleShare];


    [UIView animateWithDuration:0.25 animations:^{
        shareView.frame = CGRectMake(0, self.bounds.size.height-shareHeight, self.bounds.size.width, shareHeight);
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    UIView* touchView = touch.view;
    //点击背景view时移除分享界面
    if (touchView == self.backView) {
        [self disappearAnimation];
    }
}

-(void)buttonClick:(UIButton*)button{
    NSString *title = [button currentTitle];
    !self.clickBlock ?  :self.clickBlock(title);
    [self disappearAnimation];
}

-(void)cancleShareClick:(UIButton*)button{
    [self disappearAnimation];
}

-(void)disappearAnimation{
    [UIView animateWithDuration:0.25 animations:^{
        self.shareView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 250);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
