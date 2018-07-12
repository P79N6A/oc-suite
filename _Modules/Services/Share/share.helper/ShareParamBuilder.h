//
//  ShareParamBuilder.h
//  component
//
//  Created by fallen.ink on 12/21/15.
//  Copyright © 2015 OpenTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#pragma mark -

#define kShareTitle          @"TitleString"         //分享链接,邮件Title
#define kShareDetail         @"DetailString"        //分享链接的description
#define kShareUrl            @"ShareUrl"            //分享链接的URL
#define kShareImage          @"ShareImage"          //分享链接的image
#define kShareMessageText    @"ShareMessageText"    //分享的内容。微博，qq，短信，邮件需要填写的内容
#define kObjectID            @"ObjectID"            //微博分享使用唯一标识

#pragma mark -

@interface ShareParamBuilder : NSObject

@property (nonatomic, assign) int32_t type;

/**
 *  渠道名
 */
@property (nonatomic, strong) NSString * channelId;

/**
 *  以下为分享的外部模块所需参数
 */

@property (nonatomic, copy) NSString *title;                // 标题
@property (nonatomic, copy) NSString *detail;               // 摘要
@property (nonatomic, copy) NSString *url;                  // URL
@property (nonatomic, strong) UIImage *image;               // 图片
@property (nonatomic, copy) NSString *objectId;             // 微博 required

/**
 *  适配老方案的wrapper参数的方法
 */
@property (nonatomic, strong, readonly) NSString *smsBody; // for older using
@property (nonatomic, strong, readonly) NSString *emailBody; // same as upstairs

@end
