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

#import "ComponentMonitorFPSModel.h"

#pragma mark -

#undef	MAX_HISTORY
#define MAX_HISTORY	(128)

#pragma mark -

@implementation ComponentMonitorFPSModel {
	CADisplayLink *		_displayLink;
	CFTimeInterval		_timestamp;
	NSUInteger			_frameCount;
}

@def_prop_assign( NSUInteger,		fps );
@def_prop_strong( NSMutableArray *,	history );

@def_singleton( ComponentMonitorFPSModel )

- (id)init {
	self = [super init];
	if ( self ) {
		self.fps = 0;
		self.history = [[NSMutableArray alloc] init];
		
		for ( NSUInteger i = 0; i < MAX_HISTORY; ++i ) {
			[self.history addObject:@(0)];
		}

		_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFrameCount)];
		[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	}
	return self;
}

- (void)dealloc {
	if ( _displayLink ) {
		[_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		_displayLink = nil;
	}
	
	[self.history removeAllObjects];
	self.history = nil;
}

- (void)update {
	[self.history removeObjectAtIndex:0];
	[self.history removeLastObject];

	[self.history addObject:[NSNumber numberWithFloat:self.fps]];
	
	if ( [self.history count] > MAX_HISTORY ) {
		[self.history removeObjectsInRange:NSMakeRange(0, [self.history count] - MAX_HISTORY)];
	}
	
	[self.history insertObject:[NSNumber numberWithFloat:0.0f] atIndex:0];
	[self.history addObject:[NSNumber numberWithFloat:self.maxFPS]];
}

- (void)updateFrameCount {
	_frameCount += 1;

	CFTimeInterval now = CACurrentMediaTime();
	CFTimeInterval diff = now - _timestamp;

	if ( diff >= 1.0f ) {
		self.fps = _frameCount;
		
		if ( self.fps > self.maxFPS ) {
			self.maxFPS = self.fps;
		}
		
		_timestamp = now;
		_frameCount = 0;
	}
}

@end
