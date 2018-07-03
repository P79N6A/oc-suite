//
//  ShareViewController.h
//  KidsTC
//
//  Created by Altair on 11/20/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController

- (instancetype)initWithSuccess:(void (^)(void))successHandler
                        failure:(void (^)(NSError *error))failureHandler;

@end
