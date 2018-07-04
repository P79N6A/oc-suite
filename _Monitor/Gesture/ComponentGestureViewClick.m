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

#import "ComponentGestureViewClick.h"
#import "ComponentGesture.h"

// ----------------------------------
// Source code
// ----------------------------------

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#pragma mark -

@implementation ComponentGestureViewClick
{
	BOOL						_animating;
	UITapGestureRecognizer *	_gesture;
	UIImageView *				_circle;
	UIImageView *				_finger;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		self.layer.masksToBounds = NO;
		
		_circle = [[UIImageView alloc] init];
		_circle.backgroundColor = [UIColor clearColor];
		_circle.contentMode = UIViewContentModeScaleAspectFit;
		_circle.alpha = 0.0f;
		[self addSubview:_circle];

		_finger = [[UIImageView alloc] init];
		_finger.backgroundColor = [UIColor clearColor];
		_finger.contentMode = UIViewContentModeScaleAspectFit;
		_finger.alpha = 0.0f;
		[self addSubview:_finger];
	}
	return self;
}

- (void)dealloc
{
	[_finger removeFromSuperview];
	_finger = nil;

	[_circle removeFromSuperview];
	_circle = nil;
}

- (void)setFrame:(CGRect)newFrame
{
	[super setFrame:newFrame];
	
	CGRect circleFrame;
	circleFrame.origin = CGPointZero;
	circleFrame.size = newFrame.size;
	_circle.frame = circleFrame;
	
	CGRect fingerFrame;
	fingerFrame.origin = CGPointZero;
	fingerFrame.size = newFrame.size;
	_finger.frame = CGRectInset( fingerFrame, -20.0f, -20.0f );
}

- (void)setGesture:(UIGestureRecognizer *)gesture
{
	_gesture = (UITapGestureRecognizer *)gesture;

	_circle.image = [[ComponentGesture instance].bundle imageForResource:@"gesture-circle.png"];

	if ( _gesture && _gesture.numberOfTapsRequired <= 1 )
	{
		_finger.image = [[ComponentGesture instance].bundle imageForResource:@"gesture-single-click.png"];
	}
	else if ( _gesture && 2 == _gesture.numberOfTapsRequired )
	{
		_finger.image = [[ComponentGesture instance].bundle imageForResource:@"gesture-double-click.png"];
	}
	else
	{
		_finger.image = [[ComponentGesture instance].bundle imageForResource:@"gesture-single-click.png"];
	}
}

- (void)startAnimation
{
	[self performSelector:@selector(startAnimationStep1) withObject:nil afterDelay:0.6f];
}

- (void)startAnimationStep1
{
	if ( NO == _animating )
	{
		CGAffineTransform transform;
		transform = CGAffineTransformIdentity;
		_finger.transform = transform;
		_finger.alpha = 0.0f;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.2f];
		
		if ( _gesture && _gesture.numberOfTapsRequired )
		{
			[UIView setAnimationRepeatCount:_gesture.numberOfTapsRequired];
		}
		else
		{
			[UIView setAnimationRepeatCount:1];
		}
		
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(startAnimationStep2)];

		transform = CGAffineTransformIdentity;
		transform = CGAffineTransformScale( transform, 0.8f, 0.8f );
		_finger.transform = transform;
		_finger.alpha = 1.0f;

		[UIView commitAnimations];

		_animating = YES;
	}
}

- (void)startAnimationStep2
{
	CGAffineTransform transform;
 
	transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale( transform, 0.6f, 0.6f );
	_circle.transform = transform;
	_circle.alpha = 1.0f;

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(startAnimationStep3)];
	
	transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale( transform, 1.2f, 1.2f );
	_circle.transform = transform;
	_circle.alpha = 0.6f;
	
	[UIView commitAnimations];
}

- (void)startAnimationStep3
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(startAnimationStep4)];
	
	_finger.transform = CGAffineTransformIdentity;
	_finger.alpha = 0.0f;
	_circle.alpha = 0.0f;
	
	[UIView commitAnimations];
}

- (void)startAnimationStep4
{
	_animating = NO;
	
	[self startAnimation];
}

- (void)stopAnimation
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
