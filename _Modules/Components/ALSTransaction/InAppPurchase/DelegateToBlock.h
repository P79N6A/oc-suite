//
//  DelegateToBlock.h
//
//  Created by cevanoff on 5/6/15.
//  Copyright (c) 2015 Casey E. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DelegateToBlock : NSObject

/**
 @brief Transform a delegate pattern into a block. When @c selector gets sent to @c target the block will be passed all of the input parameters and executed.
 @param selector The target's selector that is being replaced by @c targetThenParametersBlock.
 @param target The object (usually a delegate) that will receive the @c selector.
 @param targetThenParametersBlock The block to replace the selector with. The block must follow this format: ^void(id target, Type argument1, Type argument2, Type argument3)
 @warning If the provided @c target already responds to the selector this function will return early and the block will NOT be executed.
 @return Success bool
 
 @code
 // EXAMPLE CODE
 
 // replace delegate method SEL(alertView:didDismissWithButtonIndex:) with a block
 [DelegateToBlock makeTarget:self respondToSelector:@selector(alertView:didDismissWithButtonIndex:) withBlock:^void(id target, UIAlertView *alertView, NSInteger tappedIndex) {
     NSLog(@"tapped index: %ld", tappedIndex);
 }];
 
 // present the alert view with self as the delegate
 [[[UIAlertView alloc] initWithTitle:@"title" message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Proceed", nil] show];
 */
+(BOOL)makeTarget:(id)target respondToSelector:(SEL)selector withBlock:(id)targetThenParametersBlock;

@end
