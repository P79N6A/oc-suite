//
//  _net_download_operation.h
//  consumer
//
//  Created by fallen.ink on 9/23/16.
//
//

#import <Foundation/Foundation.h>

@interface _NetDownloadOperation : NSOperation

@property(nonatomic, readonly) _NetCacheRequest *cacheableItem;
@property (nonatomic, readonly) BOOL isExecuting;
@property (nonatomic, readonly) BOOL isFinished;

- (instancetype)initWithCacheableItem:(_NetCacheRequest *)cacheableItem;

@end
