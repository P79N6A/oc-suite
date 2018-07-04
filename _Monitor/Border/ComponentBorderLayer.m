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

#import "ComponentBorderLayer.h"
#import "ComponentBorderHook.h"
#import "ComponentBorder.h"

// ----------------------------------
// Source code
// ----------------------------------

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#pragma mark -

@implementation ComponentBorderLayer

@def_prop_unsafe( UIView *,	container )

- (id)init {
	self = [super init];
	if ( self ) {
		self.opaque = NO;
		self.opacity = 1.0f;
		
		self.needsDisplayOnBoundsChange = YES;
		self.allowsEdgeAntialiasing = YES;
		self.edgeAntialiasingMask = kCALayerLeftEdge|kCALayerRightEdge|kCALayerBottomEdge|kCALayerTopEdge;
		
		self.contentsGravity = @"center";
		self.contentsScale = [UIScreen mainScreen].scale;

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(show)
													 name:NSObject.BORDER_SHOW
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(hide)
													 name:NSObject.BORDER_HIDE
												   object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)show {
	self.hidden = NO;
	self.frame = CGRectInset( CGRectMake( 0, 0, self.container.bounds.size.width, self.container.bounds.size.height ), 0.1f, 0.1f );
	self.masksToBounds = YES;
}

- (void)hide {
	self.hidden = YES;
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
