//
//  QRCodePresentVC.h
//  hairdresser
//
//  Created by fallen on 16/10/26.
//
//

/**
 *  1. 显示
 
    用户信息，二维码信息
 
 *  2. 功能键
 
    保存图片，扫描二维码
 */
#import "BaseViewController.h"

@interface QRCodePresentVC : BaseViewController

// User profile

@property (nonatomic, strong) NSString *userHeadPath;

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSString *userSexImageName;

@property (nonatomic, strong) NSString *userCity;

// QRcode info

@property (nonatomic, strong) NSString *qrcodeUrl; 

@property (nonatomic, strong) NSString *qrcodeKey; // use key generate qr code

@property (nonatomic, strong) NSString *qrcodeMessage;

@end
