//
//  AETextInputViewController.m
//  PingYuJiaYuan
//
//  Created by Qian Ye on 16/6/2.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import "TextInputViewController.h"

@interface TextInputViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIView *gapView;

- (void)done;

- (void)showAlert:(NSString *)msg;

@end

@implementation TextInputViewController

- (void)setShowingTitle:(NSString *)showingTitle {
    _showingTitle = showingTitle;
//    _navigationTitle = showingTitle;
}

- (void)setPlaceholderString:(NSString *)placeholderString {
    _placeholderString = placeholderString;
    [self.textField setPlaceholder:placeholderString];
}

- (void)setInfo:(NSString *)info {
    _info = info;
    [self.infoLabel setText:info];
}

- (void)viewDidLoad {
//    self.bTapToEndEditing = YES;
    [super viewDidLoad];
//    _navigationTitle = self.showingTitle;
    // Do any additional setup after loading the view from its nib.
    self.textField.delegate = self;
    
    [self.textField setPlaceholder:self.placeholderString];
    [self.infoLabel setText:self.info];
    
    if (self.maxLength == 0) {
        self.maxLength = UINT_MAX;
    }
    
//    [self setupRightBarButton:@"确定" target:self action:@selector(done) frontImage:nil andBackImage:nil];
    
    [self.textField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 40)]];
    [self.textField setLeftViewMode:UITextFieldViewModeAlways];
    [self.textField setRightView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 40)]];
    [self.textField setRightViewMode:UITextFieldViewModeAlways];
    
    [self.gapView resetFirstLayoutAttribute:NSLayoutAttributeHeight withConstant:border_width];
}

#pragma mark UITextFieldDelegate

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSInteger number = [string length];
//    if (number > self.maxLength) {
//        [self showAlert:@"您输入的内容超过最大长度限制"];
//        textField.text = [textField.text substringToIndex:self.maxLength];
//    }
//
//    return YES;
//}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSInteger number = [textField.text length];
    if (number > self.maxLength) {
        [self showAlert:@"您输入的内容超过最大长度限制"];
        textField.text = [textField.text substringToIndex:self.maxLength];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self done];
    return YES;
}

#pragma mark Private methods

- (void)done {
    if ([self.textField.text length] > self.maxLength) {
        [self showAlert:@"您输入的内容超过最大长度限制"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    if (weakSelf.validation) {
        NSError *error = weakSelf.validation(weakSelf.textField.text);
        if (error) {
            NSString *errMsg = @"";
            if (error.userInfo) {
//                errMsg = [error.userInfo objectForKey:kErrMsgKey];
            }
            if ([errMsg length] == 0) {
                errMsg = @"输入的内容不合法";
            }
            [self showAlert:errMsg];
            return;
        }
    }
    if (weakSelf.finish) {
        weakSelf.finish(weakSelf.textField.text);
    }
    
    [self onBack];
}

- (void)showAlert:(NSString *)msg {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:confirm];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
