//
//  AttributeLabelSampleVCLite.m
//  startup
//
//  Created by 7 on 25/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "AttributeLabelSampleVCLite.h"
#import "TYAttributedLabel.h"
//#import "_greats.h"
//#import "_building.h"

#define RGB(r,g,b,a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kExamTextFieldWidth 80
#define kExamTextFieldHeight 20
#define kAttrLabelWidth (CGRectGetWidth(self.view.frame)-20)
#define kTextFieldTag 1000

@interface AttributeLabelSampleVCLite () <TYAttributedLabelDelegate>

@end

@implementation AttributeLabelSampleVCLite

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __unused NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"html"];
    __unused NSString *htmlString = [[NSString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.attributedText = [self attributeStringFromHtml:htmlString withWidth:[UIScreen mainScreen].bounds.size.width];
    
    //
    TYAttributedLabel *label = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(10, 0, kAttrLabelWidth, 0)];
    [self.view addSubview:label];

    label.delegate = self;
    
//    label.textContainer = textContainer;
    
    label.attributedText = [self attributeStringFromHtml:htmlString withWidth:[UIScreen mainScreen].bounds.size.width];
    
    // 或者设置 attString
    //label.attributedText = _attString;
    
    [label sizeToFit];
    
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view);
//        make.centerY.equalTo(self.view);
//        make.width.equalTo(self.view);
//        make.height.equalTo(self.view);
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (NSAttributedString *)attributeStringFromHtml:(NSString *)html withWidth:(float)width {
    NSString *newString = [html stringByReplacingOccurrencesOfString:@"<img" withString:[NSString stringWithFormat:@"<img width=\"%f\"",width]];
    
    NSAttributedString *attributeString =
    [[NSAttributedString alloc]
     initWithData:
     [newString dataUsingEncoding:NSUnicodeStringEncoding]
     options:@{
               NSDocumentTypeDocumentAttribute
               :
               NSHTMLTextDocumentType
               }
     documentAttributes:nil error:nil];
    
    
    return attributeString;
    
}

#pragma mark - delegate

- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)TextRun atPoint:(CGPoint)point {
    NSLog(@"textStorageClickedAtPoint");
    
    if ([TextRun isKindOfClass:[TYLinkTextStorage class]]) {
        
        id linkStr = ((TYLinkTextStorage*)TextRun).linkData;
        if ([linkStr isKindOfClass:[NSString class]]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点击提示" message:linkStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }else if ([TextRun isKindOfClass:[TYImageStorage class]]) {
        TYImageStorage *imageStorage = (TYImageStorage *)TextRun;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点击提示" message:[NSString stringWithFormat:@"你点击了%@图片",imageStorage.imageName? imageStorage.imageName: imageStorage.imageURL] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

@end
