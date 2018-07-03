//
//  ALSJavaScriptMessagePerformer.h
//  wesg
//
//  Created by 7 on 30/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSJavaScriptMessageHandler.h"

@protocol ALSJavaScriptMessagePerformer <NSObject>

/**
 *  @return YES: 继续传递; NO: 停止传递.
 */
- (BOOL)handleMessage:(id<ALSJavaScriptMessageHandler>)handler;

@end
