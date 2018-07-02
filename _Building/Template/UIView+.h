//
//  UIView+.h
//  XFAnimations
//
//  Created by fallen.ink on 11/24/15.
//  Copyright © 2015 fallen.ink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ConstraintsControl)

/**
 *  Make constraints by code! Masonry is suggest.
 
 *  Call it at subViews created.
 */
- (void)applyConstraints;

@end

@interface UIView (Template)

+ (NSString *)identifier;
+ (UINib *)nib;

@end

@interface UIView (Nib)

- (instancetype) _initWithNib;

+ (instancetype) _loadViewWithNibNamed:(NSString *)name;

#pragma mark - 备用

+ (UINib *)loadNib;
+ (UINib *)loadNibNamed:(NSString*)nibName;
+ (UINib *)loadNibNamed:(NSString*)nibName bundle:(NSBundle *)bundle;

+ (instancetype)loadInstanceFromNib;
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName;
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName owner:(id)owner;
+ (instancetype)jk_loadInstanceFromNibWithName:(NSString *)nibName owner:(id)owner bundle:(NSBundle *)bundle;

@end

#pragma mark - 

/**
 *  @knowledge 
 
 *  参考:http://blog.csdn.net/kaitiren/article/details/50491583, 猿题库 iOS 客户端架构设计
 *
 *  数据层：Model/Entity
 *  数据访问＋业务逻辑＋业务流程：Dao＋logic＋flow（service层，可以省略，直接接入到ViewModel）
 *  控制器：ViewController（它其实只是个View的容器，不做业务逻辑，简单的做视图逻辑
 *  视图模型：ViewModel（这个可以按View来）
 *  视图：View
 
 *  优点
 *  层次清晰，职责明确：和界面有关的逻辑完全划到 ViewModel 和 View 一遍，其中 ViewModel 负责界面相关逻辑，View 负责绘制；Data Controller 负责页面相关的数据逻辑，而 Model 还是负责纯粹的数据层逻辑。 ViewController 仅仅只是充当简单的胶水作用。
 *  耦合度低，测试性高：除开 ViewController 外，各个部件可以说是完全解耦合的，各个部分也是可以完全独立测试的。同一个功能，可以分别由不同的开发人员分别进行开发界面和逻辑，只需要确立好接口即可。
 *  复用性高：解耦合带来的额外好处就是复用性高，例如同一个View，只需要多一个工厂方法生成 ViewModel，就可以直接复用。数据逻辑代码不放在 ViewController 层也可以更方便的复用。
 *  学习成本低: 本质上来说，这个架构属于对 MVC 的优化，主要在于解决 Massive View Controller 问题，把原本属于 View Controller 的职责根据界面和逻辑部分相应的拆到 ViewModel 和 DataController 当中，所以是一个非常易于理解的架构设计，即使是新手也可以很快上手。
 *  开发成本低: 完全不需要引入任何第三方库就可以进行开发，也避免了因为 MVVM 维护成本高的问题。
 *  实施性高，重构成本低：可以在 MVC 架构上逐步重构的架构，不需要整体重写，是一种和 MVC 兼容的设计。
 
 *  缺点
 *  当页面的交互逻辑非常多时，需要频繁的在 DC-VC-VM 里来回传递信息，造成了大量胶水代码。
 *  由于在传统的 MVVM 中 VM 原本是一体的，一些复杂的交互本来可以在 VM 中直接完成测试，如今却需要同时使用 DC 和 VM 并附上一些胶水代码才能进行测试。
 *  没有了 Binding，代码写起来会更费劲一点（仁者见仁，智者见智）。
 *
 */

@interface UIView ( Bind )

- (void)bindWithViewModel:(id)viewModel;

@end
