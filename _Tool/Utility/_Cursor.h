#import <Foundation/Foundation.h>

@class _Cursor;

// ----------------------------------
// Usage
//
// [self.pageCursor reset];
// - (void)loadTopicListRequstWithCompletionBlock:(Block)completionHandler {
//    if (self.pageCursor.end) {
//        if (completionHandler) completionHandler();
//            
//            return;
//    }
//    
//    [self.pageCursor next];
//    
//    [self.accessor loadTopicList:nil :nil :@(self.pageCursor.start) :@(self.pageCursor.length) :@(1) success:^(id obj) {
//        
//        NSArray *array = [obj objectForKey:@"topicList"];
//        
//        [self.pageCursor evaluateEndWith:(int32_t)array.count];
// ----------------------------------
        
// ----------------------------------
// Category code
// ----------------------------------

@interface NSObject ( Cursor )

@property (nonatomic, readonly) _Cursor *pageCursor;
@property (nonatomic, readonly) _Cursor *tagCursor;

@end

// ----------------------------------
// Class code
// ----------------------------------

typedef enum CursorType {
    CursorType_Page = 10,
    CursorType_Tag  = 11,
} CursorType;

@interface _Cursor : NSObject

@property (nonatomic, assign) int32_t   start;  // 页开始
@property (nonatomic, assign) int32_t   length; // 每页长度， 默认：10
@property (nonatomic, assign) BOOL      end; // 是否到镜头了

@property (nonatomic, strong) NSString *tag;

- (instancetype)initWithType:(CursorType)type;

- (void)reset; // pageCursor, tagCursor

- (void)next; // pageCursor

- (void)evaluateEndWith:(int32_t)actualCount; // pageCursor: touch end, or , goto next page

@end
