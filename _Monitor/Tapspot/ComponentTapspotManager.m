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

#import "ComponentTapspotManager.h"
#import "ComponentTapspotView.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation ComponentTapspotManager

@def_singleton( ComponentTapspotManager )

- (void)handleUIEvent:(UIEvent *)event
{
	UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
	
	if ( keyWindow )
	{
		if ( UIEventTypeTouches == event.type )
		{
			NSSet * allTouches = [event allTouches];
			
			for ( UITouch * touch in allTouches )
			{
				if ( nil == touch.view || touch.view.window != keyWindow )
					continue;

				if ( UITouchPhaseBegan == touch.phase )
				{
//                    INFO( @"View '%@ %p', touch began", [[touch.view class] description], touch.view );

//					if ( NO == [touch.view isKindOfClass:[UIScrollView class]] )
//					{
//						BOOL		clicked = NO;
//						UIView *	clickedView = nil;
//						
//						for ( UIView * view = touch.view; nil != view; view = view.superview )
//						{
//							if ( view.gestureRecognizers && view.gestureRecognizers.count )
//							{
//								for ( UIGestureRecognizer * gesture in view.gestureRecognizers )
//								{
//									if ( [gesture isKindOfClass:[UITapGestureRecognizer class]] )
//									{
//										clicked = YES;
//										clickedView = view;
//										break;
//									}
//								}
//							}
//							
//							if ( [view isKindOfClass:[UIControl class]] )
//							{
//								clicked = YES;
//								clickedView = view;
//								break;
//							}
//							
//							if ( [view.renderer isClickable] )
//							{
//								clicked = YES;
//								clickedView = view;
//								break;
//							}
//						}
//
//						if ( clicked )
//						{
//							[clickedView.layer removeAnimationForKey:@"scale"];
//							
//							CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//							animation.fromValue = [NSNumber numberWithFloat:1.0f];
//							animation.toValue = [NSNumber numberWithFloat:0.9f];
//							animation.duration = 0.15f;
//							animation.repeatCount = 1;
//							animation.autoreverses = YES;
//							
//							[clickedView.layer addAnimation:animation forKey:@"scale"];
//						}
//					}
				}
				else if ( UITouchPhaseMoved == touch.phase )
				{
//                    INFO( @"View '%@ %p', touch moved", [[touch.view class] description], touch.view );
				}
				else if ( UITouchPhaseEnded == touch.phase )
				{
//                    INFO( @"View '%@ %p', touch ended", [[touch.view class] description], touch.view );

//					[touch.view.layer removeAnimationForKey:@"alpha"];
//					
//					CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//					animation.fromValue = [NSNumber numberWithFloat:1.0f];
//					animation.toValue = [NSNumber numberWithFloat:0.25f];
//					animation.duration = 0.2f;
//					animation.repeatCount = 1;
//					animation.autoreverses = YES;
//					
//					[touch.view.layer addAnimation:animation forKey:@"alpha"];

					ComponentTapspotView * spotView = [[ComponentTapspotView alloc] init];
					spotView.frame = CGRectMake( 0, 0, 50.0f, 50.0f );
					spotView.center = [touch locationInView:keyWindow];
					[keyWindow addSubview:spotView];
					[keyWindow bringSubviewToFront:spotView];
					[spotView startAnimation];
				}
				else if ( UITouchPhaseCancelled == touch.phase )
				{
				}
			}
		}
	}
}

@end
