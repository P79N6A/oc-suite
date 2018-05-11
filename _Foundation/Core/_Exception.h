
#import <Foundation/Foundation.h>

// ----------------------------------
// MARK: Macro define
// ----------------------------------

#define ExceptionName @"open exception"

#define ExceptionReasonNotImplemented  @"interface not implemented"
#define ExceptionReasonFunctionWrong   @"function incrrect"

#define exceptioning( _reason_ ) exceptioning_1( @"default.exception", _reason_, nil)

#define exceptioning_1( _name_, _reason_, _userInfo_ ) [NSException raise:_name_ format:@"exception.reason(%@).userInfo(%@)", _reason_, _userInfo_];

// ----------------------------------
// MARK: Interface define
// ----------------------------------

@interface _Exception : NSObject

@end
