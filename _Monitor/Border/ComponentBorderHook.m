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

#import "ComponentBorderHook.h"
#import "ComponentBorderLayer.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSObject ( Border )

@def_notification( BORDER_SHOW )
@def_notification( BORDER_HIDE )

static void (*__layoutSubviews)( id, SEL ) = NULL;
static void (*__setNeedsLayout)( id, SEL ) = NULL;
static void (*__setNeedsDisplay)( id, SEL ) = NULL;

static BOOL __enabled = NO;

+ (void)borderEnable {
	__enabled = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSObject.BORDER_SHOW object:nil];
}

+ (void)borderDisable {
	__enabled = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSObject.BORDER_HIDE object:nil];
}

+ (void)borderHook {
	__layoutSubviews = [UIView replaceSelector:@selector(layoutSubviews) withSelector:@selector(__layoutSubviews)];
	__setNeedsLayout = [UIView replaceSelector:@selector(setNeedsLayout) withSelector:@selector(__setNeedsLayout)];
	__setNeedsDisplay = [UIView replaceSelector:@selector(setNeedsDisplay) withSelector:@selector(__setNeedsDisplay)];
}

- (void)__layoutSubviews {
	if ( [self isKindOfClass:[UIView class]] ) {
		for ( UIView * subview in [(UIView *)self subviews] ) {
			[self borderPresent:subview];
		}

//		[self borderPresent:(UIView *)self];
	}
	
	if ( __layoutSubviews ) {
		__layoutSubviews( self, _cmd );
	}
}

- (void)__setNeedsLayout {
	if ( [self isKindOfClass:[UIView class]] ) {
		for ( UIView * subview in [(UIView *)self subviews] ) {
			[self borderPresent:subview];
		}
		
//		[self borderPresent:(UIView *)self];
	}
	
	if ( __setNeedsLayout ) {
		__setNeedsLayout( self, _cmd );
	}
}

- (void)__setNeedsDisplay {
	if ( [self isKindOfClass:[UIView class]] ) {
		for ( UIView * subview in [(UIView *)self subviews] ) {
			[self borderPresent:subview];
		}

//		[self borderPresent:(UIView *)self];
	}
	
	if ( __setNeedsDisplay ) {
		__setNeedsDisplay( self, _cmd );
	}
}

- (void)borderPresent:(UIView *)container {
    TODO("暂时注释")
//	if ( nil == container.renderer )
//		return;
//	
//	ComponentBorderLayer * borderLayer = nil;
//	
//	for ( CALayer * sublayer in container.layer.sublayers ) {
//		if ( [sublayer isKindOfClass:[ComponentBorderLayer class]] ) {
//			borderLayer = (ComponentBorderLayer *)sublayer;
//			break;
//		}
//	}
//	
//	if ( nil == borderLayer ) {
//		borderLayer = [[ComponentBorderLayer alloc] init];
//		borderLayer.container = container;
//		
//		borderLayer.hidden = __enabled ? NO : YES;
//		borderLayer.frame = CGRectInset( CGRectMake( 0, 0, container.bounds.size.width, container.bounds.size.height ), 0.1f, 0.1f );
//		
//		borderLayer.masksToBounds = YES;
//	//	borderLayer.cornerRadius = container.layer.cornerRadius;
//		
//		[container.layer insertSublayer:borderLayer atIndex:0];
//	}
//	
//	SamuraiRenderObject * renderer = container.renderer;
//	
//	if ( renderer ) {
//		if ( DomNodeType_Document == renderer.dom.type ) {
//			borderLayer.borderColor = [HEX_RGBA(0x000000, 1.0f) CGColor];
//			borderLayer.borderWidth = 2.0f;
//		} else if ( DomNodeType_Element == renderer.dom.type ) {
//			borderLayer.borderColor = [HEX_RGBA(0xd22042, 1.0f) CGColor];
//			borderLayer.borderWidth = 2.0f;
//		} else if ( DomNodeType_Text == renderer.dom.type ) {
//			borderLayer.borderColor = [HEX_RGBA(0x666666, 1.0f) CGColor];
//			borderLayer.borderWidth = 2.0f;
//		} else {
//			borderLayer.borderColor = [HEX_RGBA(0xcccccc, 1.0f) CGColor];
//			borderLayer.borderWidth = 2.0f;
//		}
//		
//		if ( [renderer.childs count] ) {
//			borderLayer.backgroundColor = [[UIColor clearColor] CGColor];
//		} else {
//			borderLayer.backgroundColor = [HEX_RGBA(0x00bff3, 0.2f) CGColor];
//		}
//	} else {
//		borderLayer.backgroundColor = [[UIColor clearColor] CGColor];
//		borderLayer.borderColor = [HEX_RGBA(0xcccccc, 1.0f) CGColor];
//		borderLayer.borderWidth = 2.0f;
//	}
//	
//	[borderLayer setNeedsDisplay];
}

@end

