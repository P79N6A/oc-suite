//
//  ALSBrowserPageImpl.h
//  wesg
//
//  Created by 7 on 18/12/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "ALSportsPrecompile.h"
#import "ALSBrowserPage.h"

#if __has_AEHybridEngine
@interface ALSBrowserPageImpl : AEWebViewContainer <ALSBrowserPage>
#else
@interface ALSBrowserPageImpl : UIView <ALSBrowserPage>
#endif

@end
