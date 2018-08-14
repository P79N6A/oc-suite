//
//  ALSBrowserImpl.h
//  NewStructure
//
//  Created by 7 on 17/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "_BrowserProtocol.h"

#if __has_ALSWebViewController
@interface ALSBrowserImpl : ALSWebViewController <_BrowserProtocol>
#else
@interface ALSBrowserImpl : NSObject <_BrowserProtocol>
#endif

@end
