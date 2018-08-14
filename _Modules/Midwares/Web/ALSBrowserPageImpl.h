//
//  ALSBrowserPageImpl.h
//  wesg
//
//  Created by 7 on 18/12/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "_BrowserPage.h"

#if __has_AEHybridEngine
@interface ALSBrowserPageImpl : AEWebViewContainer <_BrowserPage>
#else
@interface ALSBrowserPageImpl : UIView <_BrowserPage>
#endif

@end
