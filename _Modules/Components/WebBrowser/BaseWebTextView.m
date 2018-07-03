//
//  BaseWebTextView.m
//  student
//
//  Created by fallen.ink on 11/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_building_precompile.h"
#import "BaseWebTextView.h"

@implementation BaseWebTextView

+ (instancetype)instanceWithHtmlString:(NSString *)htmlString {
    BaseWebTextView *textView = [[BaseWebTextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    textView.backgroundColor = [UIColor whiteColor];
    textView.returnKeyType = UIReturnKeyDone;
    textView.showsVerticalScrollIndicator = NO;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    textView.attributedText = attributedString;
    textView.textColor = [UIColor blackColor];
 
    
    
    return textView;
    
    
//    TODO("图片加载  TextView使用html.fromhtml加载html并显示图片")
    
    /** iOS
     
     iOS 的 UITextView 显示含有网络图片的 NSAttributedString 时，怎么样接管网络图片的下载过程？
     
     https://www.v2ex.com/t/149498
     
     
     parse html https://www.raywenderlich.com/14172/how-to-parse-html-on-ios
     
     */
    
    /** Android
     
     int index = str.indexOf("src=\"");
     
     //如果有图片
     if(index>-1){
     String regex="src=\"([^\"]*)\"";
     Pattern p=Pattern.compile(regex);
     Matcher m=p.matcher(str);
     if(m.find()){
     //正则匹配出图片
     System.out.println(m.group(1))
     img = m.group(1);
     }
     //异步吓着图片的方法，这里是先把文字显示出来，等后台下载好图片后，再次设置textview
     downloadImg();
     }
     Html.ImageGetter imageGetter = new ImageGetter() {
     Drawable drawable=null;
     @Override
     public Drawable getDrawable(String source) {
     //加载中提示图片
     drawable = getResources().getDrawable(R.drawable.pictures);
     try {
     drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());
     } catch (Exception e) {
     // TODO Auto-generated catch block
     e.printStackTrace();
     }
     return drawable;
     }
     };
     //s为html布局
     content.setText(Html.fromHtml(s,imageGetter,null));
     

     如果要异步加载图片，可以使用downloadImg();下载图片，下载完成，再次
     
     content.setText(Html.fromHtml(s,imageGetter,null));
     
     不过imageGetter 的图片需要换成你下载完成的图片。
     
     */
}

@end
