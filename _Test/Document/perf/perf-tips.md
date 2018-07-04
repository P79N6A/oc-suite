# iOS开发性能注意点

這篇文章翻譯自[Raywenderlich](http://www.raywenderlich.com/31166/25-ios-app-performance-tips-tricks#arc)，最近開始練習一些提昇效能的方法，這篇文章提供了很多不錯的觀念。

TODO：
1. 讲清楚其中的原理

## 入門最佳化
### 1.使用ARC管理記憶體
ARC是設計用來管理記憶體回收的機制，使用ARC讓我們可以不用再自己管理記憶體，避免了大多數memory leak的問題。

以下是原作者建議學習ARC的文件：
- [Apple’s official documentation](https://developer.apple.com/library/ios/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html)
- Matthijs Hollemans’s [Beginning ARC in iOS Tutorial](http://www.raywenderlich.com/5677/beginning-arc-in-ios-5-part-1)
- Tony Dahbura’s [How To Enable ARC in a Cocos2D 2.X Project](http://www.raywenderlich.com/?p=23854)
- If you still aren’t convinced of the benefits of ARC, check out this article on [eight myths about ARC](http://www.learn-cocos2d.com/2012/06/mythbusting-8-reasons-arc/) to really convince you why you should be using it!

在使用 blocks, retain cycles, poorly managed CoreFoundation objects (and C structures in general)一些特殊的狀況下，需要特別注意記憶體管理，可以參考 [blog post that details some of the issues that ARC can’t fix](http://conradstoll.com/blog/2013/1/19/blocks-operations-and-retain-cycles.html) 。

### 2.在適當時機使用reuseIdentifier
在使用UITableViewCells, UICollectionViewCells, UITableViewHeaderFooterViews這些元件時，可以設定reuseIdentifier大幅提昇效能。

為了提昇效能，這些table view的datasource應該要重複使用UITableViewCell物件。在table view 呼叫tableView:cellForRowAtIndexPath:時，table view應該要存下這些重覆利用的cell物件。並且重複使用。
如果不這麼做的話，每次都需要花系統資源重新建立該物件，特別在上下拖曳的時候會大幅拖慢執行速度。

在iOS6之後reuseIdentifier也支援header view/footer view。
以下是使用reuseIdentifier的範例：
```
static NSString *CellIdentifier = @"Cell";
UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

```

### 3. 盡可能把畫面設定成不透明
如果該畫面沒有使用到透明度，盡量都設定成不透明（opaque）
如此以來，系統可以使用最佳化過的方式去畫出該畫面

[Apple documentation](http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIView_Class/UIView/UIView.html)裡面提到

```
This property provides a hint to the drawing system as to how it should treat the view. If set to YES, the drawing system treats the view as fully opaque, which allows the drawing system to optimize some drawing operations and improve performance. If set to NO, the drawing system composites the view normally with other content. The default value of this property is YES.
```

一般狀況設定成不透明是很容易的，但如果是處理被內嵌在scroll view，或是有複雜動畫的狀況話可能會導致一些問題，要特別小心。

可以在模擬器使用Debug\Color Blended Layers option檢視有哪些畫面沒有被設定成不透明，盡可能的把畫面設定成不透明。

### 4.Avoid Fat XIBs
在iOS5裡推出的storyboard很快的取代XIBs。但是XIBs在很多狀況下仍然很管用，至少在你需要支援iOS5之前的裝置就需要(註：這不是廢話嗎...)，或是在需要一些客製化重複使用的畫面，他們仍然是很好用的。

如果你真的需要使用XIBs，確保他們盡可能的單純。可以的話盡量切割成多個畫面，再以階層式的view controller去控制。

當載入一份XIB到記憶體當中，會把裡面所有的物件都一併載入，包含圖片。可想而知這會是個非常重的負擔。所以在你不需要這些畫面的時候，盡可能的不要浪費記憶體去載入這些物件。特別注意在storyboard裡面沒有這個情形，storyboard只有在需要的時候才會載入該物件。

在OSX上不僅圖片，連聲音檔也會一併載入。在iOS則僅有圖片。

如果對storyboard有興趣，可以參考[Matthijs Hollemans’ Beginning Storyboards in iOS 5 Part 1](http://www.raywenderlich.com/?p=5138) and [Part 2](http://www.raywenderlich.com/?p=5191).

### 5.不要Block住Main Thread
不該在Main Thread上做任何複雜的運算，因為所有UIKit的任務（繪製畫面，處理使用者的動作）都是在Main Thread執行，如果Block住會嚴重影響使用者的體驗。

在執行一些I/O，如存取硬碟，甚至是網路的資料時，應該使用asynchronously的方式執行。在NSURLConnection裡面有實作相關的API，或是使用GCD/NSOperationQueues來處理這些運算。

### 6.Size Images to Image Views
如果有需要使用UIImageView來呈現app bundle裡面的圖片，確認兩張圖片的大小式相同的。執行scale的動作相當吃系統資源（特別在scorll view當中），要盡可能避免這樣的運算。

如果圖片是從遠端伺服器拿到的，而無法從遠端伺服器拿到想要的大小的話，可以在下載後先把圖片scale過一次cache起來，之後就不需要在重新計算。也記得，要在其他background thread執行這項複雜的運算。

### 7.選擇對的集合（collection）
官方提供三種集合供開發者使用，可以依據使用情境挑選適合的集合

- Arrays:有排序性的集合。使用index搜尋時很快，但如果以值做搜尋速度慢，加入/刪除元件慢。
- Dictionarys:key-value的集合，以key做搜尋的速度快。
- Sets:沒有排序性的集合，裡面的值皆唯一。以值搜尋快，加入/刪除快。

### 8.使用GZIP壓縮
在開發過程中我們經常會與遠端伺服器做溝通，下載XML/JSON/HTML或是其他文字格式的資料。因為網路頻寬限制，壓縮檔案的大小可以大幅提高執行速度。
壓縮檔案大小的其中一個選擇就是GZIP。尤其針對text型態的檔案做壓縮，可以顯著的提高壓縮率。目前iOS已經支援GZIP，官方提供的NSURLConnection或是著名的AFNetworking都有支援。很多伺服器端供應商，如google app engine也都有支援GZIP。

[這篇文章](http://betterexplained.com/articles/how-to-optimize-your-site-with-gzip-compression/)有提到怎麼去設定Apache或是IIS伺服器，支援GZIP壓縮。


## 中級最佳化

###9.重複使用畫面，搭配Lazy Load
更多的畫面表示需要更多的CPU跟記憶體，特別是內嵌在scroll view裡面的畫面。
要提昇UITableView/UICollectionView效能的小訣竅就是：別一開始就把所有子畫面建立好。取而代之的是當你需要這些畫面時，才去建立（Lazy Load)。當使用完這些畫面後，把這些畫面註冊到reuse queue等待下次重複使用，概念與前面提過的reuseIdenfier相同。如此一來，可以避免多次alloc物件的成本。

而什麼時候才是去建立這些畫面的好時機呢？你有兩個選擇
- 1.當主畫面被載入之後就建立這些畫面，並且隱藏起來，等到需要用的時候在顯示出來。
- 2.當你需要顯示這些畫面的時候，再去初始這些畫面出來。

這兩個作法個有好壞。第一個作法的好處是執行速度很快，當你需要顯示畫面時，你只需要改變畫面的狀態。但伴隨而來的缺點是佔用記憶體的時間較長。
第二個作法執行速度較慢，但操作記憶體的方式則比較有效率。總結兩個方式沒有一定的好壞，端看今天設計app時，對於該個畫面的要求，還有整體app所吃的資源，進行的運算做考量，選擇一個適合的方式。

###10.快取
快取一切不經常變更卻很頻繁被系統使用的資料。具體一點，來自伺服器端的回應。如圖片，計算結果等等。

可以透過一些參數設定NSURLConnection的快取行為，甚至可以建立一個NSURLRequest指定從快取裡面拿值。

以下是範例是一個NSURLRequest從快取當中拿取不會變更的圖片

```
+ (NSMutableURLRequest *)imageRequestWithURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad; // this will make sure the request always returns the cached image
    request.HTTPShouldHandleCookies = NO;
    request.HTTPShouldUsePipelining = YES;
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    return request;
}

```
對於HTTP caching, NSURLCache, NSURLConnection有興趣的話可以參考[the NSURLCache entry](http://nshipster.com/nsurlcache/)
                                                                             
如果想要快取住一些不是透過HTTP的資料，可以參考NSCache。NSCache與NSDictionary相似，以key-value的形式快取住資料，但這些資料可以在必要的時候被系統回收。[這篇文章]（http://nshipster.com/nscache/）有詳細的介紹。
                                                                           
###11.從繪圖著手 (註:這段我不是很明白，對於full sized/ resizable的定義不清楚)
有多個方式可以顯示出好看的按鈕樣式，可以透過一張full sized/resizable的圖片，甚至使用CALayer/CoreGraphics/OpenGL去繪製。
                 
這麼多種方式伴隨這不同優缺點，[這篇文章](http://robots.thoughtbot.com/post/36591648724/designing-for-ios-graphics-performance)中提供了很好的觀點。


###12.處理記憶體警告
當系統記憶體低於限度時，iOS會對於正在執行的程式發出記憶體警告。
UIKit會對於

- appDelegate(applicationDidReceiveMemoryWarning),
- UIViewController subclass(didReceiveMemoryWarning)
- 在NotificationCenter註冊 UIApplicationDidReceiveMemoryWarningNotification

發出警告。
                      
當收到警告時，建議刪除strong reference 的圖片，物件。！確保這些物件可以在稍後再被重新建立。如果不處理警告，會有app被系統強制關閉的風險。可以透過使用 iOS Simulator 裡面的 simulate memory warning做測試。


###13.重複使用大型物件
重複使用需要花很多時間建立的物件，如：NSDateFormatter and NSCalendar 。
當你需要爬JSON/XML時經常會需要這些工具。

為了能重複利用這些已被建立的物件，可以用property存這些物件，或是使用static變數儲存。
如果選擇static變數，則這段記憶體在app存活的時候將持續被使用

以下是範例程式，講解了如何使用lazy-load的方式初始化NSDateFormatter，並且使用property存下物件，供後續使用。

```
@property (nonatomic, strong) NSDateFormatter *formatter;

- (NSDateFormatter *)formatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy"; // twitter date format
    });
    return formatter;
}
                                                                                                                                                                                       
```
特別提醒，如果要重新設定NSDateFormatter的format，會耗費與初始化一個新的NSDateFormatter物件差不多的時間。如果有要使用到不同格式的NSDateFormatter，可以以多個property存不同格式的物件。

###14.使用Sprite Sheets
如果你是個遊戲開發者，那麼Sprite sheets絕對是你不容錯過的工具。Sprite sheets比起正規的畫法可以畫的更快，而且更省記憶體。

（後面文章著重在Cocos2D的介紹，就不贅述了）


###15.避免重複處理資料
很多app會使用遠端伺服器的資料。而這些資料通常都是以JSON/XML格式做傳遞。確保在請求與回應兩邊的資料格式相同是很重要的。
因為在轉換資料格式的過程中，很可能牽扯複雜且多餘的運算。
舉例來說，如果你需要在table view裡面顯示資料，那麼最好的方式是接受一個array格式的資料，避免無謂的轉換就可以直接被table view做使用。

相同的，如果你的程式在運行的時候需要以key-value格式做處理，那麼最好可以在接收遠端資料時拿到dictionary的格式。

確保以正確的資料結構做處理，可以避免掉轉換格式所帶來的成本。

###16.選擇正確的資料格式
如上面提過的，JSON/XML是溝通app與伺服器常見的方式。
JSON在爬資料時比較快速，而且通常大小比起XML小的多，這也表示需要傳輸的資料量更小。而且在iOS之後就內建了JSON的解析工具，更方便使用。

不過XML也有他的優勢，如果使用[SAX](http://en.wikipedia.org/wiki/Simple_API_for_XML) parsing，可以不需要等待整包資料下載完後才能開始做處理。這在處理很巨量的資料時會顯得更有效率。

###17.使用適當的背景
基本上有兩種方式可以設定背景圖片：
- 可以透過UIColor的colorWithPatternImage設定畫面的背景。
- 可以使用UIImageView來設定。

如果有需要用到一張full size的背景圖，那麼就需要UIImageView。因為UIColor的colorWithPatternImage是設計來顯示重複出現的小圖，而非大型的圖片，直接使用UIImageView可以省下很多記憶體。
```
// You could also achieve the same result in Interface Builder
UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
[self.view addSubview:backgroundView];
```
相反過來，如果是要顯示重複出現的小圖，則是：
```
self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
```

###18.減少使用與Web相關的設計
UIWebView是很好用的設計，可以很容易的為我們顯示網頁上的畫面。
但UIWebView執行的速度遠不及Apple官方的Safari，這是因為Webkit’s Nitro Engine的限制，詳細可參考[JIT compilation](http://en.wikipedia.org/wiki/Just-in-time_compilation)。

為了提昇效率，盡可能減少HTML/JS，特別是使用像是jQuery這樣大型的框架，有時候用原生的JS會來的比依賴這些框架更為快速。
也記得盡可能使用非同步的方式載入JS file，特別當他們在執行過程中不是有直接必要的（如分析使用行為）。

最後別忘記前面提過的，注意圖片的大小。也可以配合sprite sheets等方式盡可能的提高性能。

[WWDC 2012 session #601 – Optimizing Web Content in UIWebViews and Websites on iOS.](http://developer.apple.com/videos/wwdc/2012/)

###19.設定Shadow Path
如果你需要在view或是layer上面增加視覺陰影效果，直覺上會使用QuartzCore framework
```
#import <QuartzCore/QuartzCore.h>

// Somewhere later ...
UIView *view = [[UIView alloc] init];

// Setup the shadow ...
view.layer.shadowOffset = CGSizeMake(-1.0f, 1.0f);
view.layer.shadowRadius = 5.0f;
view.layer.shadowOpacity = 0.6;

```
雖然很簡潔，但有個嚴重的問題。Core Animation裡面使用的(offscreen pass)相當吃系統資源。
（offscreen pass是Core Animation instrument定義的運算，雖然是使用硬體執行，但會中斷原本硬體的運算，重新指向要計算的buffer，完成offscreen運算之後，再導回之前處理的buffer。似乎在on-screen/ off-screen之間的context switch會導致系統緩慢。[參考文章](https://forums.developer.apple.com/thread/12257)）

不過有個更好的選項：設定Shadow Path！

```
view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:view.bounds] CGPath];
```
透過設定Shadow Path，OS不需要一再重新計算如何畫出陰影。而是使用自己預先設定好的路徑。
但這取決於這個view的格式，自己計算path有時候可能更加困難。
另外一個問題是在每次view的frame改變時，都需要重新更新Shadow Path.

[這篇文章](http://markpospesel.wordpress.com/2012/04/03/on-the-importance-of-setting-shadowpath/)裡面有更多關於這個技術的討論。


###20.最佳化Table views
Table view需要支援很快速的scroll，如果沒有把效能挑整好，使用者很容易發現lag的情形。
所以在實現table view時要謹記
- 透過正確reuseIdentifier重複使用cell（前面有提過）
- 盡可能設定views不透明
- 避免漸層，放大/縮小圖片，還有在off-screen的設計。
- cache 寬高的資訊，如果他們都是一樣的話。
- 如果這些cell使來自於網路，確定是使用非同步方法來操作，並且記得cache這些網路回應。
- 使用shadow path，如果需要的話
- 減少subview使用的數量
- 在cellForRowAtIndexPath:盡可能做最少的運算，如果有需要的話在一開始運算完之後cache起來。
- 使用正確的資料結構。
- 直接設定rowHeight, sectionFooterHeight, sectionHeaderHeight。而不透過delegate

###21.使用正確的資料儲存方式
當需要讀寫大量資料的時候，可以使用多種方式：
- 存在NSUserDefaults
- 使用XML/JSON/Plist的檔案格式儲存
- 使用NSCoding
- 使用本機的SQL database
- 使用Core data

操作NSUserDefaults很簡單，很適合拿來儲存小量的資料，如使用者偏好的設定。
使用XML/JSON/Plist檔案，會帶來幾個問題。一般來說，需要把整個檔案都載入到記憶體之後再進行操作，這顯得很沒有效率。當然可以使用前面提過的SAX處理XML檔案，但這是個複雜的方法。
NSCoding也是需要操作檔案，與前面一個方式會遇到差不多的問題。
最適合的選項是SQLite或是Core Data。透過這兩者，可以使用最佳化過的query方式拿到想要的物件，而這兩個方式的效能很相近。
Core Data是官方推薦的資料庫，至於內容博大精深，這邊不做詳述。如果使用SQLite的話可以用[FMDB](https://github.com/ccgus/fmdb)避免掉底層的語法操作。

## 進階最佳化
###22.加速App launch時間
App launch時間很重要，這是給使用者帶來的第一印象。
要加速這個流程，盡可能使用非同步的方式進行任務，如網路傳輸，資料庫存取，或是爬一些資料等等。
避免使用過度複雜的XIBs，因為載入這些XIB都是在main thread執行。（但是storyboard沒有這個問題）

！watchdog在debug模式底下不會執行，測試時別忘記解開iphone/ipad與xcode的連結，才能真正知道launch時的速度。

###23.使用Autorelease Pool
NSAutoreleasePool可以用在block中釋放物件。而它也會自動被UIKit呼叫。但是在某些情境下，手動使用NSAutoreleasePool可以帶來一些好處。

如果在程式執行的某個時候，需要短暫建立大量的物件，如果這些大量資料在之後不需要使用到的話，其實是可以被提早釋放的。不需要等到UIKit進行回收時才開始回收這些記憶體。
```
NSArray *urls = <# An array of file URLs #>;
for (NSURL *url in urls) {
    @autoreleasepool {
        NSError *error;
        NSString *fileContents = [NSString stringWithContentsOfURL:url
        encoding:NSUTF8StringEncoding error:&error];
        /* Process the string, creating and autoreleasing more objects. */
    }
}
```

###24.Cache圖片，或不這麼做
有兩個方法可以載入bundle裡面的圖片，imageNamed跟比較不常見的imageWithContentsOfFile
imageNamed優點是會cache這張圖片，當使用這個函式，會先在cache裡面找符合這個名稱的圖片。如果沒有的話在從bundle裡面載入到cache，再回傳。
而imageWithContentsOfFile就不會進行cache。
那什麼時候該使用哪個函式呢？
如果今天是要載入一個很大的圖片，而之後就不會在重複使用的話，那就沒有cache的必要。imageWithContentsOfFile會是比較好的選擇。
imageNamed則可以用在會重複使用的圖片上，可以省下再次載入需要的時間。

###25.盡可能避免Date Formatters

如果有很多date格式需要使用NSDateFormatter，那得小心處理。如同前面提過的，盡量重複使用NSDateFormatter這個物件。
然而，如果想要更進一步加速的話，可以直接使用C取代NSDateFormatter。Sam Soffes寫了一篇[部落格](http://soff.es/how-to-drastically-improve-your-app-with-an-afternoon-and-instruments)，可以直接使用他提供的代碼來取代NSDateFormatter。

聽起來很棒，但還有更好的方式！
如果你可以控制時間的格式的話，選擇Unix timestamps。Unix timestamps使用整數來計算時間，可以被簡單的轉成NSDate
```
- (NSDate*)dateFromUnixTimestamp:(NSTimeInterval)timestamp {
    return [NSDate dateWithTimeIntervalSince1970:timestamp];
}
```
這甚至比前面提過的C function還快
特別注意web傳過來的timestamps是milliseconds，原生javascript很常這麼做。記得先除過１０００轉換成秒之後再進行運算。


