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

#import "ComponentGridsWindow.h"

#pragma mark -

@implementation ComponentGridsWindow

@def_singleton( ComponentGridsWindow )

- (id)init {
	self = [super initWithFrame:[UIScreen mainScreen].bounds];
	if ( self ) {
		self.hidden = YES;
		self.backgroundColor = [UIColor clearColor];
		self.windowLevel = UIWindowLevelStatusBar + 2.0f;
		self.userInteractionEnabled = NO;
		self.rootViewController = [[UIViewController alloc] init];
	}
	return self;
}

- (void)dealloc {
    
}

#pragma mark -

- (void)show {
	self.hidden = NO;
}

- (void)hide {
	self.hidden = YES;
}

#pragma mark -

- (void)drawRect:(CGRect)rect {
	CGFloat a = 30.0f;
	CGFloat i = 5.0f;
//	CGFloat n = [UIScreen mainScreen].bounds.size.width / (a + i);

	CGContextRef context = UIGraphicsGetCurrentContext();
	if ( context ) {
		CGContextSaveGState( context );

		CGContextSetFillColorWithColor( context, [[UIColor clearColor] CGColor] );
		CGContextFillRect( context, rect );

		CGFloat x = 0;
		
		while ( x < [UIScreen mainScreen].bounds.size.width ) {
			x += i;
			
			CGRect column;
			column.origin.x = x;
			column.origin.y = 0.0f;
			column.size.width = a;
			column.size.height = [UIScreen mainScreen].bounds.size.height;

			CGContextSetFillColorWithColor( context, [HEX_RGBA( 0xc3ebfa, 0.4f ) CGColor] );
			CGContextFillRect( context, column );

			CGContextSetStrokeColorWithColor( context, [HEX_RGBA( 0x0097ff, 0.8f ) CGColor] );
			CGContextStrokeRect( context, column );

			x += a;
		}

		CGContextRestoreGState( context );
	}
	
	[super drawRect:rect];
}

@end
