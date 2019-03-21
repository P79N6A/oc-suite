//
//  NetworkingViewController.m
//  gege
//
//  Created by fallen.ink on 2019/3/14.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import "NetworkingViewController.h"
#import "AppDelegate.h"
#import "ExampleRequest.h"

@interface NetworkingViewController ()

@property (nonatomic, strong) _NetRestful *net;

@end

@implementation NetworkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.net = [[_NetRestful alloc] initWithHostname:@"daily.api-eyas.alisports.com" paramEncoding:NetRequestParameterEncodingJSON secure:NO];
    self.net.headerAppendHandler = ^NSDictionary *(NSString *apiname) {
        NSString *token = cacheInst[@"token"];
        NSString *uid = cacheInst[@"uid"];
        
        NSMutableDictionary *header = [@{} mutableCopy];
        if (token) {
            header[@"token"] = token;
        }
        if (uid) {
            header[@"uid"] = uid;
        }
        
        return header;
    };
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)get {
    NSDictionary *params = @{
                             @"video_uuid": @"fafw234dsfa54"
                             };
    [self.net GET:@"/api/v1/video/detail" param:params success:^(id data) {
        // 参考楼下
    } failure:^(NSError *error) {
        
    }];
}

- (void)post {
    MemberCarddetailRequest *req = [MemberCarddetailRequest new];
    req.card_id = 0;
    
    [self.net POST:@"/api/v1/member/cardbindparent"
        parameters:req.yy_modelToJSONObject
           headers:nil
           success:^(id data) {
               
               MemberBindcardsResponse *res = [MemberBindcardsResponse yy_modelWithDictionary:data];
               
               UNUSED(res)
               
           } failure:^(NSError *error) {
               
           }];
}

@end
