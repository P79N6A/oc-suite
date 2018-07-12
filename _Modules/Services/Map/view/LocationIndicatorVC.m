//
//  GDMapVC.m
//  yzsee
//
//  Created by 三炮 on 15/10/22.
//
//

#import "_vendor_lumberjack.h"
#import "LocationService.h"
#import "LocationIndicatorVC.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>
#import "BaseWebViewController.h"
#import "ReactiveCocoa.h"
#import "_building_application.h"
#import "_pragma_push.h"

#define kGapXOfBottomView 12
#define kGapYOfBottomView 20

@interface LocationIndicatorVC () <AMapSearchDelegate, MAMapViewDelegate>

@property (nonatomic, strong) AMapSearchAPI     *searchAPI;
@property (nonatomic, strong) MAMapView         *mapView;

@property (nonatomic, strong) IBOutlet UIView   *bottomView;
@property (nonatomic, weak) IBOutlet UILabel    *destNameLabel;
@property (nonatomic, weak) IBOutlet UILabel    *distanceLabel;
@property (nonatomic, weak) IBOutlet UIButton   *goHereButton;

@property (nonatomic, strong) AMapGeocode       *destinationGeoInfo;

@end

@implementation LocationIndicatorVC

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
    {
        self.destnationName = self.params[@"LocationAddress"];
        self.destnationLocation = self.params[@"LocationCoordinate"];
    }
     */
    
    
    [self initSearchAPI];
    
    [self initMapView];
    
    [self initBottomView];
    
    [self bindViewModel];
    
    if (self.destnationLocation == nil) {
        [self searchLocationWithAddress:self.destnationName];
    } else {
        [self searchAddressWithLocation:self.destnationLocation];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = self.destnationName;
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.title = @"";
}

- (void)dealloc {
    [self clearMapView];
    
    [self clearSearch];
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initSearchAPI {
    self.searchAPI = [AMapSearchAPI new];
    self.searchAPI.delegate = self;
}

- (void)initMapView {
    self.mapView = [[MAMapView alloc]initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.mapView.touchPOIEnabled = YES;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.distanceFilter  = 10;//10米位置更新到服务器
    self.mapView.headingFilter   = kCLHeadingFilterNone;
    self.mapView.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.mapView setZoomLevel:16.f];
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
}

- (void)initBottomView {
    [self.view addSubview:self.bottomView];
    [self.bottomView bringToFront];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-kGapYOfBottomView);
        make.leading.equalTo(self.view.mas_leading).with.offset(kGapXOfBottomView);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-kGapXOfBottomView);
    }];
    
    self.destNameLabel.textColor = color_gray;
    self.distanceLabel.textColor = color_lightGray;
    [self.goHereButton setTitleColor:[UIColor colorWithRGBHex:0x10bdb1]];
    self.bottomView.hidden = YES;
}

- (void)bindViewModel {
    @weakify(self);
    RACSignal* sig_currentLocationSuccess = nil;
    if (service.location.available) {
       sig_currentLocationSuccess = [[RACObserve(self.mapView.userLocation, location) filter:^BOOL(id value) {
            return value != nil;
        }]take:1];
    }else{
        sig_currentLocationSuccess = [RACSignal return:@(YES)];
    }

    RACSignal* sig_destinationSuccess = [[RACObserve(self, destinationGeoInfo) filter:^BOOL(id value) {
        return value != nil;
    }]take:1];
    
    [[sig_destinationSuccess onMainThread]subscribeNext:^(id x) {
        @strongify(self);
        [self showDestination];
    }];
    
    [[[[RACSignal combineLatest:@[sig_currentLocationSuccess,sig_destinationSuccess]]take:1]onMainThread]subscribeNext:^(id x) {
        @strongify(self);
        [self showBottomView];
    }];
}

#pragma mark - UI Action

- (IBAction)didClickGoHereButton:(id)sender {
    if (self.destinationGeoInfo == nil) {
        return;
    }
    CLLocationCoordinate2D startLocation = self.mapView.userLocation.coordinate;
    CLLocationCoordinate2D destinationLocation = CLLocationCoordinate2DMake(self.destinationGeoInfo.location.latitude, self.destinationGeoInfo.location.longitude);
    [self openGDAppForSearchRouteWithStartLocation:startLocation destinationLocation:destinationLocation destinationName:self.destnationName];
}

#pragma mark - 跳转高德应用

#ifndef GDMapH5APIKey
#define GDMapH5APIKey @"93522d023dd42b6199591926125d8f75"
#endif

- (void)openGDAppForSearchRouteWithStartLocation:(CLLocationCoordinate2D)startLocation
                             destinationLocation:(CLLocationCoordinate2D)destinationLocation
                                 destinationName:(NSString*)destinationName {
    MARouteConfig * config = [[MARouteConfig alloc] init];
    config.startCoordinate = startLocation;
    config.destinationCoordinate = destinationLocation;
    config.appScheme = greats.device.urlSchema;
    config.appName = app_display_name;
    config.routeType = MARouteSearchTypeDriving;
    //若未调起高德地图App,跳转到高德H5应用
    NSString* url = [NSString stringWithFormat:@"http://m.amap.com/navi/?start=%f,%f&dest=%f,%f&destName=%@&naviBy=car&key=%@",startLocation.longitude,startLocation.latitude,destinationLocation.longitude,destinationLocation.latitude,destinationName,GDMapH5APIKey];
    
    DDLogDebug(@"高德H5应用URL:%@",url);
    
    NSString *encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self pushHtml:[NSURL URLWithString:encodedUrl] extraParams:@{@"title":@"高德地图"}];
}

#pragma mark - 地理编码搜索

- (void)searchLocationWithAddress:(NSString *)address {
    if (address.length == 0) {
        return;
    }
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = address;
    [self.searchAPI AMapGeocodeSearch:geo];
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response{
    if(response.geocodes.count == 0){
        return;
    }
    
    self.destinationGeoInfo = [response.geocodes firstObject];
}

#pragma mark - 地理逆编码搜索

- (void)searchAddressWithLocation:(CLLocation*)location{
    AMapReGeocodeSearchRequest* request = [AMapReGeocodeSearchRequest new];
    request.requireExtension = YES;
    request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [self.searchAPI AMapReGoecodeSearch:request];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    AMapReGeocode *regeocode = response.regeocode;
    AMapGeocode *tmpGeocode = [AMapGeocode new];
    tmpGeocode.location = [AMapGeoPoint locationWithLatitude:self.destnationLocation.coordinate.latitude longitude:self.destnationLocation.coordinate.longitude];
    tmpGeocode.province = regeocode.addressComponent.province;
    tmpGeocode.city = regeocode.addressComponent.city;
    tmpGeocode.district = regeocode.addressComponent.district;
    tmpGeocode.township = regeocode.addressComponent.township;
    tmpGeocode.neighborhood = regeocode.addressComponent.neighborhood;
    tmpGeocode.building = regeocode.addressComponent.building;
    
    self.destinationGeoInfo = tmpGeocode;
}

#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        static NSString *currentLocationIdentifier = @"currentLocation";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:currentLocationIdentifier];
        if (annotationView == nil){
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:currentLocationIdentifier];
        }
        
        annotationView.image = image_named(@"start");
        return annotationView;
    } else {
        static NSString *destinationIdentifier = @"destinationLocation";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:destinationIdentifier];
        if (annotationView == nil){
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:destinationIdentifier];
        }
        
        annotationView.image = image_named(@"end");
        annotationView.centerOffset = CGPointMake(0,-annotationView.height/2);//向上移一半像素
        return annotationView;
    }
}

#pragma mark - 显示目标地址

- (void)showDestination {
    MAPointAnnotation *userAnnotation = [[MAPointAnnotation alloc]init];
    userAnnotation.coordinate = CLLocationCoordinate2DMake(self.destinationGeoInfo.location.latitude, self.destinationGeoInfo.location.longitude);

    self.mapView.userTrackingMode = MAUserTrackingModeNone;
    [self.mapView setCenterCoordinate:userAnnotation.coordinate animated:YES];
    [self.mapView addAnnotation:userAnnotation];
}

- (void)showBottomView {
    NSMutableString* detaiAddressStr = [NSMutableString new];
    if (self.destinationGeoInfo.township) {
        [detaiAddressStr appendString:self.destinationGeoInfo.township];
    }
    if (self.destinationGeoInfo.neighborhood) {
        [detaiAddressStr appendString:self.destinationGeoInfo.neighborhood];
    }
    if (self.destinationGeoInfo.building) {
        [detaiAddressStr appendString:self.destinationGeoInfo.building];
    }
    if ([detaiAddressStr length] == 0) {
        [detaiAddressStr appendString:self.destnationName];
    }
    
    if ([detaiAddressStr isEqualToString:self.destnationName]) {
        self.destNameLabel.text = detaiAddressStr;
    } else {
        self.destNameLabel.text = self.destnationName;
    }
    
    NSMutableString* distanceStr = [NSMutableString new];
    
    //未开启定位时不显示距离
    if (service.location.available && self.mapView.userLocation.location) {
        MAUserLocation* userLocation = self.mapView.userLocation;
        LocationModel* currentLocation = [LocationModel modelWithLongitude:userLocation.coordinate.longitude latitude:userLocation.coordinate.latitude];
        LocationModel* destLocationModel = [LocationModel modelWithLongitude:self.destinationGeoInfo.location.longitude latitude:self.destinationGeoInfo.location.latitude];
        double distance = [LocationModel kilometerDistanceBetween:currentLocation and:destLocationModel];
        [distanceStr appendString:[NSString stringWithFormat:@"%.1fkm ",distance]];
    }
    
    if (self.destinationGeoInfo.city.length > 0) {
        [distanceStr appendString:self.destinationGeoInfo.city];
    } else if(self.destinationGeoInfo.province && [self.destinationGeoInfo.province contains:@"市"]) {
        [distanceStr appendString:self.destinationGeoInfo.province];
    }
    if (self.destinationGeoInfo.district) {
        [distanceStr appendString:self.destinationGeoInfo.district];
    }
    self.distanceLabel.text = distanceStr;
    self.bottomView.hidden = NO;
}

#pragma mark - 清理

- (void)clearMapView {
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch {
    self.searchAPI.delegate = nil;
}

@end

#import "_pragma_pop.h"
