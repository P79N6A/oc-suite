//
//  WebSampleVCByLabel.m
//  startup
//
//  Created by 7 on 25/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "WebSampleVCByLabel.h"

@interface WebSampleVCByLabel ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation WebSampleVCByLabel

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Label加载HTML例子";
    
    NSString *strHtml = @"<b>提示</b><br/>1、测试测试测试测试测试测试测试测试测试测试测试测试<br/>2、测试测试测试测试测试测试测试测试测试测试";
    NSAttributedString * strAtt = [[NSAttributedString alloc] initWithData:[strHtml dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    self.label.attributedText = strAtt;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

@end
