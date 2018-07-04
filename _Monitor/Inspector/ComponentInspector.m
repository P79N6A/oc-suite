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

#import "ComponentInspector.h"
#import "ComponentInspectorWindow.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation ComponentInspector
{
	ComponentInspectorWindow * _window;
}

- (BOOL)autoinstall {
    TODO("@王涛，这部分搞定后，可以改为自动安装")
    return NO;
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
}

- (void)uninstall {
    [super uninstall];
    
	_window = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)powerOn {
    [super powerOn];
}

- (void)powerOff {
    [super powerOff];
}

#pragma mark -

- (void)didApplicationLaunched
{
	if ( nil == _window )
	{
		_window = [[ComponentInspectorWindow alloc] init];
		_window.hidden = YES;
	}
}

- (void)willApplicationTerminate
{
	_window = nil;
}

#pragma mark -

- (void)whenDockerOpen {
	[_window show];
}

- (void)whenDockerClose {
	[_window hide];
}

@end
