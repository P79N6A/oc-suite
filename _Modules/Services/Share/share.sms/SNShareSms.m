//
//  SNShareSms.m
//  component
//
//  Created by fallen.ink on 5/26/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "_vendor_lumberjack.h"

#import "SNShareSms.h"
#import <MessageUI/MessageUI.h>

@interface SNShareSms () <MFMessageComposeViewControllerDelegate>

@end

@implementation SNShareSms

@def_singleton( SNShareSms )

- (void)configure {
    
}

- (BOOL)supported {
    return [MFMessageComposeViewController canSendText] && self.config.supported;
}

//参数phones：发短信的手机号码的数组，数组中是一个即单发,多个即群发。
- (BOOL)share:(ShareParamBuilder *)paramBuilder onViewController:(UIViewController *)viewController {
    if ([self supported]) {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        controller.navigationBar.tintColor = [UIColor redColor];
        controller.body = paramBuilder.smsBody;
        controller.messageComposeDelegate = self;
        [viewController presentViewController:controller animated:YES completion:^{
            viewController.view.alpha = 0;
        }];
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"该设备不支持短信功能"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    return YES;
}

- (void)parse:(NSURL *)url application:(UIApplication *)application {
    
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:^{
        switch (result) {
            case MessageComposeResultSent: {
                //信息传送成功
                NSLog(@"信息传送成功");
            }
                break;
            case MessageComposeResultFailed: {
                //信息传送失败
                DDLogError(@"短信分享：信息传送失败");
            }
                break;
            case MessageComposeResultCancelled: {
                //信息被用户取消传送
                DDLogError(@"短信分享：信息被用户取消传送");
            }
                break;
            default:
                break;
        }
    }];
}

@end
