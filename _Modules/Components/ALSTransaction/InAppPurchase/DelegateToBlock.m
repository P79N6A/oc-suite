//
//  DelegateToBlock.m
//
//  Created by cevanoff on 5/6/15.
//  Copyright (c) 2015 Casey E. All rights reserved.
//

#import "DelegateToBlock.h"
#include <objc/runtime.h>

@implementation DelegateToBlock

+(BOOL)makeTarget:(id)target respondToSelector:(SEL)selector withBlock:(id)targetThenParametersBlock {
	
	// no swizzling, so log an error and bail if the method is already implemented
	if ([target respondsToSelector:selector]) {
		NSLog(@"Error: DelegateToBlock was unable to replace [%@ %@] with a block because it is already implemented.", target, NSStringFromSelector(selector));
		return NO;
	}
	
	// add the method to the target and make the implementation execute the block
	IMP someImp = imp_implementationWithBlock(targetThenParametersBlock);
	class_addMethod([target class], selector, someImp, "v@:v*");

	return YES;
}

@end
