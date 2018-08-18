//
//  ALSFumentWebConformer.m
//  Pay-inner
//
//  Created by  杨子民 on 2018/4/26.
//  Copyright © 2018年 yangzm. All rights reserved.
//

#import "ALSFumentWebConformer.h"
#import "ALSPayWebViewController.h"
#import "NetHelp.h"

@interface ALSFumentWebConformer ()

@property(nonatomic,weak)completedBlock block;
@property(nonatomic,weak)ALSFuCompleteCallBack fullBlock;
@property(nonatomic,strong)UINavigationController * navigation;
@end

@implementation ALSFumentWebConformer

- (void)setInitDelegate:(id)alsthirdpartypaymentInitDelegate {
    
}

- (bool)supportPlatform:(_PaymentPlatformType)platform {
    return YES;
}

- (void)startPayment:(ALSFument*)payment callback:(ALSFuCompleteCallBack)callback {
    if ( callback )
        _fullBlock = callback;
    
    ALSPayWebViewController* controller = [[ALSPayWebViewController alloc] init];
    
    NSString *formString = [NetHelp getFormDataString:payment.map];
    NSLog(@"params string = %@", formString);
    
    NSData *body = [formString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:payment.url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    
    controller.payRequest = request;
    controller.callback = callback;
    
    //[payment.control presentViewController:controller animated:YES completion:nil];
    if ( nil == _navigation )
    {
        _navigation = [[UINavigationController alloc]initWithRootViewController:controller];
        [payment.control presentViewController:_navigation animated:YES completion:^{
            
        }];
    }
}

- (void)queryPaymentWithOrderId: (NSString*)orderid  callback:(ALSFuCompleteCallBack)callback
{
    
}

-(NSDictionary *)xh_dictionary:(NSString*)str
{
    NSString *jsonString = str;
    NSData *JSONData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
}

-(NSString *)xh_URLEncodedString:(NSString*)str
{
    NSString *string = str;
    NSString *encodedString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                     (CFStringRef)string,
                                                                                                     NULL,
                                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                     kCFStringEncodingUTF8));
    return encodedString;
}

-(NSString *)xh_URLDecodedString:(NSString*)str
{
    NSString *string = str;
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)string, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return decodedString;
}

-(BOOL)handleOpenURL:(NSURL *)url
{
    NSString *urlString =  [self xh_URLDecodedString:url.absoluteString];
    
    if ([urlString containsString:@"//safepay/"]){
        NSString *resultStr = [[urlString componentsSeparatedByString:@"?"] lastObject];
        resultStr = [resultStr stringByReplacingOccurrencesOfString:@"ResultStatus" withString:@"resultStatus"];
        NSDictionary *result = [self xh_dictionary:resultStr];
        NSDictionary *resultDict = result[@"memo"];
        
        if ( _block ){
            _block( resultDict );
        }
        
        if ( _fullBlock ){
            NSInteger code = [[resultDict objectForKey:@"resultStatus"] integerValue];
            if ( 9000 == code )
                ;//_fullBlock( 0, @"", nil );
            else if( code ==  6001)// 取消
                _fullBlock( 1, @"--用户取消--", nil );
            else
                _fullBlock( 2, @"--未知错误--", nil );
        }
        
        return YES;
    }
    
    /*
    if (self.wxAppid && [urlString xh_containsString:self.wxAppid] && [urlString xh_containsString:@"//pay/"]){
        NSArray *retArray =  [urlString componentsSeparatedByString:@"&"];
        NSInteger errCode = -1;
        NSString *errStr = @"普通错误";
        for (NSString *retStr in retArray) {
            if([retStr containsString:@"ret="]){
                errCode = [[retStr stringByReplacingOccurrencesOfString:@"ret=" withString:@""] integerValue];
            }
        }
        if(errCode == 0){
            errStr = @"成功";
        }else if (errCode == -2){
            errStr = @"用户取消";
        }else if (errCode == -3){
            errStr = @"发送失败";
        }else if (errCode == -4){
            errStr = @"授权失败";
        }else if (errCode == -5){
            errStr = @"微信不支持";
        }
        NSDictionary *resultDict = @{@"errCode":@(errCode),@"errStr":errStr};
        if(self.completedBlock) self.completedBlock(resultDict);
        return YES;
    }*/
    return NO;
}

- (BOOL)handleThirdPartyPaymentCallback:(NSURL*)url
{
    [self handleOpenURL:url];
    return YES;
}

- (void)getPaymentInfor:(ALSFument*)payment callback:(ALSFuCompleteCallBack)back
{
    
}

@end
