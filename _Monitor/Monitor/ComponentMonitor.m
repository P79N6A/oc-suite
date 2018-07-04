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

#import "ComponentMonitor.h"
#import "ComponentMonitorStatusBar.h"

#import "ComponentMonitorCPUModel.h"
#import "ComponentMonitorMemoryModel.h"
#import "ComponentMonitorNetworkModel.h"
#import "ComponentMonitorFPSModel.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation ComponentMonitor {
	NSTimer *						_timer;
	ComponentMonitorCPUModel *		_model1;
	ComponentMonitorMemoryModel *		_model2;
	ComponentMonitorNetworkModel *	_model3;
	ComponentMonitorFPSModel *		_model4;
	ComponentMonitorStatusBar *		_bar;
}

- (void)install {
    [super install];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didApplicationLaunched)
												 name:UIApplicationDidFinishLaunchingNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(willApplicationTerminate)
												 name:UIApplicationWillTerminateNotification
											   object:nil];
	
	_model1 = [ComponentMonitorCPUModel sharedInstance];
	_model2 = [ComponentMonitorMemoryModel sharedInstance];
	_model3 = [ComponentMonitorNetworkModel sharedInstance];
	_model4 = [ComponentMonitorFPSModel sharedInstance];

	_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f / 10.0f
											  target:self
											selector:@selector(didTimeout)
											userInfo:nil
											 repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)uninstall {
    [super uninstall];
    
	_bar = nil;
	_model1 = nil;
	_model2 = nil;
	_model3 = nil;
	_model4 = nil;

	[_timer invalidate];
	_timer = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)powerOn {
    [super powerOn];
}

- (void)powerOff {
    [super powerOff];
}

#pragma mark -

- (void)whenDockerOpen {
    [_bar show];
}

- (void)whenDockerClose {
    [_bar hide];
}

#pragma mark -

- (void)didApplicationLaunched {
	_bar = [[ComponentMonitorStatusBar alloc] init];
}

- (void)willApplicationTerminate {
	_bar = nil;
}

- (void)didTimeout {
	[_model1 update];
	[_model2 update];
	[_model3 update];
	[_model4 update];

	[_bar update];
}

@end
