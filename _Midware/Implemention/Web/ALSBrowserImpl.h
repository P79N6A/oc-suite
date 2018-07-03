//
//  ALSBrowserImpl.h
//  NewStructure
//
//  Created by 7 on 17/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "ALSportsPrecompile.h"
#import "ALSBrowserProtocol.h"

#if __has_ALSWebViewController
@interface ALSBrowserImpl : ALSWebViewController <ALSBrowserProtocol>
#else
@interface ALSBrowserImpl : NSObject <ALSBrowserProtocol>
#endif

@end
