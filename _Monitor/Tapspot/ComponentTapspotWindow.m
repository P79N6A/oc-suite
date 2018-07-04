//
//     ____              _____    _____    _____
//    / ___\   /\ /\     \_   \   \_  _\  /\  __\
//    \ \     / / \ \     / /\/    / /    \ \  _\_
//  /\_\ \    \ \_/ /  /\/ /_     / /      \ \____\
//  \____/     \___/   \____/    /__|       \/____/
//
//	Copyright BinaryArtists development team and other contributors
//
//	https://github.com/BinaryArtists/suite.great
//
//	Free to use, prefer to discuss!
//
//  Welcome!
//

#import "ComponentTapspotWindow.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation ComponentTapspotWindow

- (id)init {
	CGRect screenBound = [UIScreen mainScreen].bounds;
	
	self = [super initWithFrame:screenBound];
	if ( self ) {
		self.backgroundColor = [UIColor blackColor];
		self.windowLevel = UIWindowLevelStatusBar + 1.0f;
		self.rootViewController = [[UIViewController alloc] init];
	}
	return self;
}

- (void)dealloc {
}

#pragma mark -

- (void)show {
	self.hidden = NO;
	self.alpha = 0.0f;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	self.alpha = 1.0f;
	self.hidden = NO;
	
	[UIView commitAnimations];
}

#pragma mark -

- (void)hide {
	[UIView beginAnimations:@"showStep2" context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(didHidden)];
	
	self.alpha = 0.0f;
	
	[UIView commitAnimations];
}

- (void)didHidden {
	self.alpha = 0.0f;
	self.hidden = YES;
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -
