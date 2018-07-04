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

#import "ComponentGestureViewSwipe.h"
#import "ComponentGesture.h"

// ----------------------------------
// Source code
// ----------------------------------

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#pragma mark -

@implementation ComponentGestureViewSwipe
{
	BOOL						_animating;
	UISwipeGestureRecognizer *	_gesture;
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

- (void)setGesture:(UIGestureRecognizer *)gesture
{
	_gesture = (UISwipeGestureRecognizer *)gesture;
	
	_circle.image = [[ComponentGesture instance].bundle imageForResource:@"gesture-circle.png"];

	if ( UISwipeGestureRecognizerDirectionLeft & _gesture.direction )
	{
		_finger.image = [[ComponentGesture instance].bundle imageForResource:@"gesture-swipe-left.png"];
	}
	else if ( UISwipeGestureRecognizerDirectionRight & _gesture.direction )
	{
		_finger.image = [[ComponentGesture instance].bundle imageForResource:@"gesture-swipe-right.png"];
	}
	else if ( UISwipeGestureRecognizerDirectionUp & _gesture.direction )
	{
		_finger.image = [[ComponentGesture instance].bundle imageForResource:@"gesture-swipe-up.png"];
	}
	else if ( UISwipeGestureRecognizerDirectionDown & _gesture.direction )
	{
		_finger.image = [[ComponentGesture instance].bundle imageForResource:@"gesture-swipe-down.png"];
	}
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

- (void)startAnimation
{
	[self performSelector:@selector(startAnimationStep1) withObject:nil afterDelay:0.6f];
}

- (void)startAnimationStep1
{
	if ( NO == _animating )
	{
		_finger.transform = CGAffineTransformIdentity;
		_finger.alpha = 0.0f;

		_circle.transform = CGAffineTransformIdentity;
		_circle.alpha = 0.0f;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(startAnimationStep2)];

		_finger.alpha = 1.0f;
		_circle.alpha = 1.0f;

		[UIView commitAnimations];

		_animating = YES;
	}
}

- (void)startAnimationStep2
{
	CGAffineTransform transform;
 
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(startAnimationStep3)];
	
	if ( UISwipeGestureRecognizerDirectionLeft & _gesture.direction )
	{
		transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate( transform, -(self.frame.size.width / 2.0f - 7.0f), 0.0f );
		_finger.transform = transform;

		transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate( transform, -(self.frame.size.width / 2.0f - 7.0f), 0.0f );
		_circle.transform = transform;
	}
	else if ( UISwipeGestureRecognizerDirectionRight & _gesture.direction )
	{
		transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate( transform, (self.frame.size.width / 2.0f - 7.0f), 0.0f );
		_finger.transform = transform;
		
		transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate( transform, (self.frame.size.width / 2.0f - 7.0f), 0.0f );
		_circle.transform = transform;
	}
	else if ( UISwipeGestureRecognizerDirectionUp & _gesture.direction )
	{
		transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate( transform, 0.0f, -(self.frame.size.height / 2.0f - 7.0f) );
		_finger.transform = transform;
		
		transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate( transform, 0.0f, -(self.frame.size.height / 2.0f - 7.0f) );
		_circle.transform = transform;
	}
	else if ( UISwipeGestureRecognizerDirectionDown & _gesture.direction )
	{
		transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate( transform, 0.0f, (self.frame.size.height / 2.0f - 7.0f) );
		_finger.transform = transform;
		
		transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate( transform, 0.0f, (self.frame.size.height / 2.0f - 7.0f) );
		_circle.transform = transform;
	}
	
	_circle.alpha = 0.6f;
	
	[UIView commitAnimations];
}

- (void)startAnimationStep3
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(startAnimationStep4)];
	
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
