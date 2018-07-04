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

#import "ComponentGestureHook.h"
#import "ComponentGestureView.h"
#import "ComponentGesture.h"

#import "ComponentGestureViewClick.h"
#import "ComponentGestureViewSwipe.h"
#import "ComponentGestureViewPinch.h"

// ----------------------------------
// Source code
// ----------------------------------

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#pragma mark -

static void (* __setFrame)( id, SEL, CGRect ) = NULL;

#pragma mark -

@implementation NSObject(Wireframe)

+ (void)gestureHook
{
	__setFrame = [UIView replaceSelector:@selector(setFrame:) withSelector:@selector(__setFrame:)];
}

- (ComponentGestureView *)createGestureView:(Class)clazz forContainer:(UIView *)container
{
	UIView * gestureView = nil;
	
	for ( UIView * subview in container.subviews )
	{
		if ( [subview isKindOfClass:clazz] )
		{
			gestureView = subview;
			break;
		}
	}
	
	if ( nil == gestureView )
	{
		gestureView = [[clazz alloc] init];
		
		[container addSubview:gestureView];
		[container bringSubviewToFront:gestureView];
	}

	return (ComponentGestureView *)gestureView;
}

- (void)__setFrame:(CGRect)newFrame
{
	if ( __setFrame )
	{
		__setFrame( self, _cmd, newFrame );
	}
	
	if ( NO == [self isKindOfClass:[UIView class]] )
		return;
	
	if ( [self isKindOfClass:[ComponentGestureView class]] )
		return;

	UIView * container = (UIView *)self;
	
	if ( container.window != [UIApplication sharedApplication].keyWindow )
		return;

    TODO("暂时注释")
//	if ( nil == container.renderer )
//		return;
	
	if ( container.gestureRecognizers && container.gestureRecognizers.count )
	{
		for ( UIGestureRecognizer * gesture in container.gestureRecognizers )
		{
			ComponentGestureView * gestureView = nil;

			if ( [gesture isKindOfClass:[UITapGestureRecognizer class]] )
			{
				gestureView = [self createGestureView:[ComponentGestureViewClick class] forContainer:container];
			}
			else if ( [gesture isKindOfClass:[UISwipeGestureRecognizer class]] )
			{
				gestureView = [self createGestureView:[ComponentGestureViewSwipe class] forContainer:container];
			}
			else if ( [gesture isKindOfClass:[UIPinchGestureRecognizer class]] )
			{
				gestureView = [self createGestureView:[ComponentGestureViewPinch class] forContainer:container];
			}
			
			if ( gestureView )
			{
				CGRect gestureFrame;
				gestureFrame.size.width = fminf( fminf( container.frame.size.width, container.frame.size.height ), 60.0f );
				gestureFrame.size.height = gestureFrame.size.width;
				gestureFrame.origin.x = (newFrame.size.width - gestureFrame.size.width) / 2.0f;
				gestureFrame.origin.y = (newFrame.size.height - gestureFrame.size.height) / 2.0f;
				gestureView.frame = gestureFrame;
				
				[gestureView setGesture:gesture];
				[gestureView startAnimation];
			}
		}
	}
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
