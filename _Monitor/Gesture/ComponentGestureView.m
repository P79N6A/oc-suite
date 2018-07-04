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

#import "ComponentGestureView.h"
#import "ComponentGestureSetting.h"

// ----------------------------------
// Source code
// ----------------------------------

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#pragma mark -

@implementation ComponentGestureView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		self.userInteractionEnabled = NO;
		self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
		self.alpha = 0.85f;
		self.hidden = [[ComponentGestureSetting sharedInstance] isEnabled] ? NO : YES;
		self.layer.borderColor = [HEX_RGBA(0xeb212e, 0.6) CGColor];
		self.layer.borderWidth = 3.0f;

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didEnabled)
													 name:ComponentGestureSetting.Enabled
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didDisabled)
													 name:ComponentGestureSetting.Disabled
												   object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setGesture:(UIGestureRecognizer *)gesture
{	
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	self.layer.masksToBounds = YES;
	self.layer.cornerRadius = fminf( frame.size.width, frame.size.height ) / 2.0f;
}

- (void)startAnimation
{
}

- (void)stopAnimation
{
}

- (void)didEnabled
{
	self.hidden = NO;
}

- (void)didDisabled
{
	self.hidden = YES;
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
