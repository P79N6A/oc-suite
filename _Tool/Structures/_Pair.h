#import "_Precompile.h"
#import "_Singleton.h"
#import "_Instance.h"

// ----------------------------------
// MARK: Interface CFPair
// TODO: 应该支持任意类型的值、对象
// ----------------------------------

#define _PairMake( ... )        macro_concat( _PairMake_, macro_count(__VA_ARGS__) )( __VA_ARGS__ )

#define _PairMake_0( ... )
#define _PairMake_1( ... )
#define _PairMake_2(a, b)       _PairMake_3(a, b, nil)
#define _PairMake_3(a, b, c)    [[_PairManager sharedInstance] pairWith:a :b :c];

@interface _Pair : NSObject
@property (nonatomic, strong) id a;
@property (nonatomic, strong) id b;
@property (nonatomic, strong) id c;
@end

typedef _Pair *Pair;

// ----------------------------------
// MARK: Interface _PairManager
// ----------------------------------

@interface _PairManager : NSObject

@singleton( _PairManager )

// key value
// object_file_linenum : a/b/c
- (Pair)pairWith:(id)a :(id)b :(id)c;


@end
