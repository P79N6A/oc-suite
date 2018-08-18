//
//  ALSPayWebViewController.h
//  Pay-inner
//
//  Created by  杨子民 on 2018/4/26.
//  Copyright © 2018年 yangzm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALSFumentProtocol.h"

@interface ALSPayWebViewController : UIViewController
{
    
}

@property(nonatomic,weak) ALSFuCompleteCallBack callback;
@property(nonatomic,copy) NSURLRequest* payRequest;
/**
 重定向
 */
@property (nonatomic, copy) NSString *redirectUrl;

/**
 退出时会用到
 */
@property (nonatomic, copy) NSString *quitUrl;
@end
