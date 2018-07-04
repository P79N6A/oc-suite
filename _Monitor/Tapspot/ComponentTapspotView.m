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

#import "ComponentTapspotView.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation ComponentTapspotView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if ( self ) {
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeCenter;
	}
	return self;
}

- (void)dealloc {
}

- (void)didAppearingAnimationStopped  {
	[self removeFromSuperview];
}

- (void)startAnimation {
	self.alpha = 1.0f;
	self.transform = CGAffineTransformMakeScale( 0.5f, 0.5f );
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.6f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(didAppearingAnimationStopped)];
	
	self.alpha = 0.0f;
	self.transform = CGAffineTransformIdentity;
	
	[UIView commitAnimations];
}

- (void)stopAnimation {
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	if ( context ) {
		CGContextSaveGState( context );
		
		CGContextSetFillColorWithColor( context, [[UIColor clearColor] CGColor] );
		CGContextFillRect( context, rect );
		
		CGRect bound;
		bound.origin = CGPointZero;
		bound.size = rect.size;
		
		CGContextAddEllipseInRect( context, bound );
		CGContextSetFillColorWithColor( context, [[UIColor lightGrayColor] CGColor] );
		CGContextFillPath( context );

		CGContextAddEllipseInRect( context, CGRectInset(bound, 5, 5) );
		CGContextSetFillColorWithColor( context, [[UIColor whiteColor] CGColor] );
		CGContextFillPath( context );

		CGContextRestoreGState( context );
	}
	
	[super drawRect:rect];
}

@end
