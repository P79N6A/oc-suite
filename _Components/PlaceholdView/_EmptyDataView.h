//
//  KTCEmptyDataView.h
//  KidsTC
//
//  Created by Altair on 12/5/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class _EmptyDataView;

@protocol _EmptyDataViewDelegate <NSObject>

- (void)didClickedGoHomeButtonOnEmptyView:(_EmptyDataView *)emptyView;

@end

@interface _EmptyDataView : UIView

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, assign) id<_EmptyDataViewDelegate> delegate;

@property (nonatomic, copy) void(^GoHomeBlock)();

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)img description:(NSString *)des;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)img description:(NSString *)des needGoHome:(BOOL)bNeed;

@end
