//
//  SNShareLink.m
//  component
//
//  Created by fallen.ink on 5/26/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "SNShareLink.h"

@implementation SNShareLink

@def_singleton( SNShareLink )

- (void)configure {
    LOG(@"微信 key = %@", self.config.appId);
}

- (BOOL)share:(ShareParamBuilder *)paramBuilder onViewController:(UIViewController *)viewController {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = paramBuilder.url;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                    message:@"复制链接成功"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
    return YES;
}

- (void)parse:(NSURL *)url application:(UIApplication *)application {
    
}

@end
