//
//  AEDatePickerViewController.m
//  PingYuJiaYuan
//
//  Created by Qian Ye on 16/6/5.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import "AEDatePickerViewController.h"

@interface AEDatePickerViewController ()

@property (weak, nonatomic) IBOutlet UIView *alphaView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (void)didTappedOnAlphaView;

- (IBAction)didClickedConfirmButton:(id)sender;
- (IBAction)didClickedCancelButton:(id)sender;

@end

@implementation AEDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.alphaView setHidden:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTappedOnAlphaView)];
    [self.alphaView addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.alphaView setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.alphaView setHidden:YES];
}

#pragma mark Private methods

- (void)didTappedOnAlphaView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didClickedConfirmButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        __weak typeof(self) weakSelf = self;
        if (weakSelf.finishBlock) {
            weakSelf.finishBlock([weakSelf.datePicker date]);
        }
    }];
}

- (IBAction)didClickedCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Public methods

+ (instancetype)showFromViewControler:(UIViewController *)controller {
    AEDatePickerViewController *pickVC = [[AEDatePickerViewController alloc] init];
    pickVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [controller presentViewController:pickVC animated:YES completion:nil];
    return pickVC;
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
