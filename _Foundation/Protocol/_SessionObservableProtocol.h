
#import <Foundation/Foundation.h>

@protocol _SessionObservableProtocol <NSObject>

- (void)onLogin:(id)data;

- (void)onLogout;
    
@end
