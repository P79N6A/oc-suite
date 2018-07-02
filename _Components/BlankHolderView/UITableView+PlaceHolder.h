//
//  UITableView+PlaceHolder.h
//  student
//
//  Created by fallen.ink on 08/10/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (PlaceHolder)

@property (nonatomic, assign) BOOL firstReload;
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic,   copy) void(^reloadBlock)(void);

@end
