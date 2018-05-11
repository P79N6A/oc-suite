//
//  3DTouchController.h
//  hairdresser
//
//  Created by fallen.ink on 7/14/16.
//
//

#import <Foundation/Foundation.h>
#import "_foundation.h"

#pragma mark -

#define UIApplicationShortcutItemMake( _type_, _title_, _subtitle_, _imagename_) [[UIApplicationShortcutItem alloc]initWithType:_type_ localizedTitle:_title_ localizedSubtitle:_subtitle_ icon:[UIApplicationShortcutIcon iconWithTemplateImageName:_imagename_] userInfo:nil];

#define UIApplicationShortcutItemEqual( _item_, _type_) [_item_.type isEqual:_type_]

#pragma mark -

@interface _DTouchController : NSObject

@singleton( _DTouchController )

#pragma mark - Home screen quick actions

/**
 *  create uiapplication shortcut items
 
 *  call when - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 *
 *  @param params @[@{...}]
 *      required @"type", @"title", @"imagename"
 *      optional @"subtitle"
 */
- (void)createUIApplicationShortcutItemsWithParams:(NSArray *)params;

/**
 *  There is 2 possibility:
    1. call when - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    here, if u enter app through 3dtouch, performActionForShortcutItemHandler will be call immidiately.
    2. call when - (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
    here, app recover from background, not launching moment, performActionForShortcutItemHandler will be call.
 *
 *  @param performActionForShortcutItemHandler ...
 */
- (void)setPerformActionForShortcutItemHandler:(StringBlock)performActionForShortcutItemHandler;

- (void)handleWhenApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 *  call when - (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
 */
- (void)handleWhenApplication:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler;

#pragma mark - Peek and pop



#pragma mark - Force properties

/**
 *  iOS9为我们提供了一个新的交互参数:力度。我们可以检测某一交互的力度值，来做相应的交互处理。例如，我们可以通过力度来控制快进的快慢，音量增加的快慢等。
 */


@end


/**
 *  Quick actions
 
    1. 静态方式
    
        a. 编辑 Info.plist
        b. 
            必填项（下面两个键值是必须设置的）：
 
            UIApplicationShortcutItemType 这个键值设置一个快捷通道类型的字符串
            UIApplicationShortcutItemTitle 这个键值设置标签的标题
 
            选填项（下面这些键值不是必须设置的）：
 
            UIApplicationShortcutItemSubtitle 设置标签的副标题
            UIApplicationShortcutItemIconType 设置标签Icon类型
            UIApplicationShortcutItemIconFile  设置标签的Icon文件
 
    2.
 */
