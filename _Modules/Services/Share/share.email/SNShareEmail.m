//
//  SNShareEmail.m
//  component
//
//  Created by fallen.ink on 5/26/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "SNShareEmail.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SNShareEmail () <MFMailComposeViewControllerDelegate>

@end
@implementation SNShareEmail

@def_singleton( SNShareEmail )

- (BOOL)supported {
    return [MFMailComposeViewController canSendMail] && self.config.supported;
}

- (void)configure {
    
}

- (BOOL)share:(ShareParamBuilder *)paramBuilder onViewController:(UIViewController *)viewController {
    if ([[SNShareService sharedInstance].email supported]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:paramBuilder.title];
        
        NSString *contentString = paramBuilder.emailBody;
        [picker setMessageBody:contentString isHTML:NO];

        [viewController presentViewController:picker animated:YES completion:^{
            viewController.view.alpha = 0;
        }];
    } else {
        NSString *recipients = @"mailto:first@example.com&subject=my email!";
        NSString *body = @"&body=email body!";
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }
    
    return YES;
}

- (void)parse:(NSURL *)url application:(UIApplication *)application {
    
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        switch (result) {
            case MFMailComposeResultSent: {
                LOG(@"邮件传送成功");
            }
                break;
            case MFMailComposeResultFailed: {
                LOG(@"邮件分享：邮件传送失败");
            }
                break;
            case MFMailComposeResultCancelled: {
                LOG(@"邮件分享：邮件被用户取消传送");
            }
                break;
            case MFMailComposeResultSaved: {
                LOG(@"邮件分享：邮件被保存");
            }
                break;
            default:
                break;
        }
    }];
}

@end
