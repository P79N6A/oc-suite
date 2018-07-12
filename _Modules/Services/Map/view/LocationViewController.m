//
//  LocationViewController.m
//  QQing
//
//  Created by 李杰 on 1/27/15.
//
//

#import "_building_precompile.h"
#import "_building_application.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "_validator.h"
#import "_app_appearance.h"
#import "LocationViewController.h"
#import "AddressInputHintViewController.h"
#import "LocationService.h"

#define SeperatorMark @","

#define kViewSpace 12
#define kItemHeight 40
#define kTipHeight 25
#define MaxNumberOfDescriptionChars 45

#define kHeightOfSectionHeader  12
#define kMapViewHWRatio         (5.f/7)

static CGFloat AutoLocationViewWidthConstant = 0;

@interface LocationViewController () <
    AddressInputHintViewControllerDelegate,
    UITextFieldDelegate,
    MAMapViewDelegate,
    AMapSearchDelegate
>

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@property (assign, nonatomic) CGFloat scrollContentHeight;

@property (strong, nonatomic) IBOutlet UIView *addressView;
@property (nonatomic, weak) IBOutlet UIView* autoLocationView;
@property (nonatomic, weak) IBOutlet UITextField *curZone;          //当前主位置
@property (weak, nonatomic) IBOutlet UIView *addressDetailView;
@property (nonatomic, weak) IBOutlet UITextField *detailAddress;    //位置补充详情
@property (weak, nonatomic) IBOutlet UIView *addressSepLine;

@property (nonatomic, weak) IBOutlet UIView *mapViewHolder;         //地图内层

@property (strong, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (nonatomic, strong) MAPointAnnotation* an;
@property (nonatomic, strong) MAPointAnnotation *bestAnnotation;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) MAPointAnnotation *curAnnotation;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *citycode;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *areaName; // distict


@property (nonatomic, assign) BOOL longPressTriggered;

#define AutoLocationViewHeightConstraintConstant 50.f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autoLocationViewHeightConstraint;
#define AddressContentViewHeightConstraintContant 101.f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressContentViewHeightConstraint;

// 第一次进入该页面
@property BOOL firstIn;

//
@property BOOL AMapPlaceSearchFromSearchVC;

// 用于长按地址搜索的点
@property (atomic, strong) MATouchPoi *longTouchPoi;

//@property (nonatomic, strong) NSMutableArray *dataArr;

//用于保存当前用户已经输入的第二行地址
@property (nonatomic, strong) NSString *textfieldExistStr;

@property (assign,nonatomic) SelectAddressType selectAddressType;
@property (strong,nonatomic) ObjectBlock completionBlock;

@end

@implementation LocationViewController

@def_prop_class(NSString *, currentCityName, setCurrentCityName)

#pragma mark - Initilizate

- (instancetype)initWithSelectAddressType:(SelectAddressType)type completionBlock:(ObjectBlock)block {
    if (self = [super init]) {
        self.firstIn = YES;
        self.AMapPlaceSearchFromSearchVC = NO;
        self.selectAddressType = type;
        self.completionBlock = block;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)initAddressView{
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickOnAutoLocationView:)];
    [self.autoLocationView addGestureRecognizer:gesture];
    
    self.curZone.textColor = font_gray_1;
    
    self.detailAddress.delegate = self;
    self.detailAddress.textColor = font_gray_1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:) name:UITextFieldTextDidChangeNotification object:self.detailAddress];
}

- (void)initMapView {
    self.mapView.frame = self.mapViewHolder.bounds;
    
    [self.mapViewHolder addSubview:self.mapView];
    
    self.mapView.touchPOIEnabled = YES; // 是否支持单击地图获取POI信息(默认为YES)
    self.mapView.showsCompass = NO; // 是否显示罗盘
    self.mapView.showsScale = NO; // 是否显示比例尺
    self.mapView.distanceFilter  = 10;//10米位置更新到服务器
    self.mapView.headingFilter   = kCLHeadingFilterNone;
    self.mapView.desiredAccuracy = kCLLocationAccuracyHundredMeters;    //降低精度，提高定位速度
    [self.mapView setZoomLevel:16.f];
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    
    //定位关闭，就提示用户自己手动搜索
    if (![LocationService sharedInstance].available) {
        self.curZone.placeholder = @"小区、街道或路名等等，必填";
        [self showAlertView:nil message:@"定位服务未开启,请在“设置-隐私-定位服务”选项中,允许发咖获得你的地理位置" cancelButtonName:@"确定" cancelHandler:nil];
    } else {
        self.mapView.showsUserLocation = YES;
        [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    }
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"街道地址";
    self.scrollContentHeight = kHeightOfSectionHeader;
    
    [self initAddressView];
    
    self.scrollContentHeight += kHeightOfSectionHeader;
    
    [self initMapView];
    
    self.commitButton.backgroundColor = color_theme;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self unobserveAllNotifications];
}

- (void)dealloc {
    [self unobserveAllNotifications];
    
    [self clearMapView];
    
    [self clearSearch];
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}

#pragma mark - Utility

- (void)setCurrentZoneAddress:(NSString *)address {
    AutoLocationViewWidthConstant = screen_width - /* leading space */ 20 - /* trailing space */30;
    NSUInteger lineCount = [address linesWithFont:font_normal_16 constrainedToWidth:AutoLocationViewWidthConstant];
    
    lineCount = lineCount <= 1 ? 1 : lineCount;
    
    self.curZone.text = address;
}

/* 地理编码 搜索. */
- (void)searchGeocodeWithKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }

    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = key;
    [self.search AMapGeocodeSearch:geo];
}

- (void)clearAndSearchGeocodeWithKey:(NSString *)key {
    /* 清除annotation. */
    [self clearAnnotations];
    
    [self searchGeocodeWithKey:key];
}

- (MAPointAnnotation *)annotionForTouchPoi:(MATouchPoi *)touchPoi {
    if (touchPoi == nil) {
        return nil;
    }
    
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate = touchPoi.coordinate;
    annotation.title = [touchPoi name];
    
    return annotation;
}

// 逆地理编码查询
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate {
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}

#pragma mark - Handle Action

- (void)didClickOnAutoLocationView:(UIGestureRecognizer*)gesture {
    AddressInputHintViewController * vc = [[AddressInputHintViewController alloc] init];
    vc.delegate = self;
    vc.initialSearchString = self.curZone.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didClickOnAddAddressButton:(id)sender {
    NSString *completeAddress = [self.curZone.text stringByAppendingString:[NSString stringWithFormat:@"%@%@", SeperatorMark, self.detailAddress.text]];

    LocationModel *location = [LocationModel modelWithAddress:completeAddress longitude:self.curAnnotation.coordinate.longitude latitude:self.curAnnotation.coordinate.latitude];
//    location.cityID = [[CityCache sharedInstance] cityIdForCityCode:self.citycode.intValue];
//    location.cityNameString = [[CityCache sharedInstance] citynameForID:self.citycode.intValue withDefault:@"未识别"];
    location.district = self.areaName;
    
    if (self.completionBlock) {
        self.completionBlock(location);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didLongPressOnOverlay:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[longPress locationInView:self.mapViewHolder]
                                                  toCoordinateFromView:self.mapView];
        [self searchReGeocodeWithCoordinate:coordinate];
        
        self.longPressTriggered = YES;

        [self addAnnotationWithCoordinate:coordinate];
    }
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if(updatingLocation) {
        //取出当前位置的坐标
        LOG(@"地址选择页.经纬度更新 latitude : %f,longitude: %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        
        // 第一进入 or 你地址搜索失败，则进行定位，同时逆地址编码，填充“所在区域”的地址信息
        if (self.firstIn ||
            [self.curZone.text length] == 0) {
            self.firstIn = NO;
            [self searchReGeocodeWithCoordinate:userLocation.coordinate];
            
            [self addAnnotationWithCoordinate:userLocation.coordinate];
        }
        
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    LOG(@"地址选择页.定位失败，errror = %@",error);
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
}

// 长按后在这里获取视图坐标
- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois {
    if (pois.count == 0) {
        return;
    }
    self.longTouchPoi = pois[0];
}

// 自定义精度的圆圈
// 高德 sdk：http://lbs.amap.com/api/ios-sdk/guide/draw-on-map/draw-plane/
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MACircle class]]) {
        LOG(@"Coordinate = (%f, %f), rect=(%f, %f, %f, %f)", overlay.coordinate.latitude, overlay.coordinate.longitude,
            overlay.boundingMapRect.origin.x, overlay.boundingMapRect.origin.y, overlay.boundingMapRect.size.width, overlay.boundingMapRect.size.height);
        
        MACircleView *accuracyCircleView = [[MACircleView alloc] initWithCircle:(MACircle *)overlay];
        accuracyCircleView.miterLimit = 0.001;
        accuracyCircleView.width = PIXEL_8;
        accuracyCircleView.lineWidth = 1.f;
        accuracyCircleView.strokeColor = [UIColor colorWithRed:42./255. green:95./255. blue:191./255. alpha:1.0];
        accuracyCircleView.fillColor = [UIColor colorWithRed:42./255. green:95./255. blue:191./255. alpha:0.2];
  
        return accuracyCircleView;
    }
    
    return nil;
}

// 创建大头针需调用的函数
// 高德 sdk：http://lbs.amap.com/api/ios-sdk/guide/draw-on-map/draw-marker/
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if (!self.firstIn) {
        self.firstIn = NO;
        self.mapView.showsUserLocation = NO;
        self.mapView.userTrackingMode = MAUserTrackingModeNone;
    }
    
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:userLocationStyleReuseIndetifier];
            annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
//            annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
            annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        }
        annotationView.image = image_named_bundled_subpath(@"purplePin", @"AMap", @"images");
        self.curAnnotation = (MAPointAnnotation *)annotation;
        return annotationView;
    } else {
        static NSString *longPressAnnotation = @"longPressAnnotation";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:longPressAnnotation];
        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:longPressAnnotation];
        }
        annotationView.image = image_named_bundled_subpath(@"purplePin", @"AMap", @"images");
        //保存一下
        self.curAnnotation = (MAPointAnnotation *)annotation;
        return annotationView;
    }
}


#pragma mark - AMapSearchDelegate

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request
                     response:(AMapReGeocodeSearchResponse *)response {
    if (response.regeocode != nil &&
        response.regeocode.formattedAddress &&
        [response.regeocode.formattedAddress length]>0) {
        if (self.AMapPlaceSearchFromSearchVC) {
            [self setCurrentZoneAddress:self.address];
        } else {
            [self setCurrentZoneAddress:response.regeocode.formattedAddress];
        }
        
        // 高德城市编码
        self.citycode = response.regeocode.addressComponent.citycode;
        // 城市名
        self.city = response.regeocode.addressComponent.city;
        
        self.areaName = response.regeocode.addressComponent.district;
    }
}

// 地理编码查询回调函数
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response {
    if (response.geocodes.count == 0) {
        return;
    }
    
    NSMutableArray *annotations = [NSMutableArray array];
    NSMutableArray *geocodes = [NSMutableArray array];

    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop) {
        [geocodes addObject:obj];
        MAPointAnnotation *userAnnotation = [[MAPointAnnotation alloc]init];
        userAnnotation.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
        [annotations addObject:userAnnotation];
    }];
    
    _bestAnnotation = annotations[0];
    
    if (annotations.count > 1) {
        _bestAnnotation = [self nearestPlaceInArray:annotations];
    }
    
    // 地址显示到编辑框
    AMapGeocode *geocode = [self nearestPlaceInArray:[response.geocodes mutableCopy]];
    
    [self setCurrentZoneAddress:geocode.formattedAddress];
    
    self.areaName = geocode.district;
    
    self.detailAddress.text = @"";
    /*
     大头针和精度圈
     */
    _coordinate = CLLocationCoordinate2DMake(geocode.location.latitude, geocode.location.longitude);
    
    [self searchReGeocodeWithCoordinate:_coordinate];
    
    [self addAnnotationWithCoordinate:_coordinate];
}

/**
 *  POI查询回调函数
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    NSMutableArray *annotations = [NSMutableArray array];
    NSMutableArray *geocodes = [NSMutableArray array];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        [geocodes addObject:obj];
        MAPointAnnotation *userAnnotation = [[MAPointAnnotation alloc]init];
        userAnnotation.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
        [annotations addObject:userAnnotation];
    }];
    
    if (response.pois.count > 0) {
        AMapPOI *mappoi = nil;
        for (int index = 0; index < response.pois.count; index++) {
            AMapPOI *poi = [response.pois objectAtIndex:index];
            if ([poi.name isEqualToString:((AMapPOIKeywordsSearchRequest*)request).keywords]) {
                mappoi = poi;
                break;
            }
        }
        if (!mappoi) {
            mappoi = [response.pois objectAtIndex:0];
        }
        
        self.detailAddress.text = @"";
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(mappoi.location.latitude, mappoi.location.longitude) animated:YES];
        
        /*
         大头针和精度圈
         */
        _coordinate = CLLocationCoordinate2DMake(mappoi.location.latitude, mappoi.location.longitude);
        
        // 逆地理编码查询
        [self searchReGeocodeWithCoordinate:_coordinate];
        
        // 添加精度圆
        [self addAnnotationWithCoordinate:_coordinate];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.detailAddress) {
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (self.detailAddress == textField) {
            NSUInteger maxLength = MaxNumberOfDescriptionChars-self.curZone.text.length-1;//加上自动定位的地址，上限是45个汉字
            if ([toBeString length] > maxLength) {
                textField.text = [toBeString substringToIndex:maxLength];
                [self showToastWithText:localized(@"定位页面.超过最大字数限制.Toast提示")];
                return NO;
            }
        }
        return YES;
    }
    
    return YES;
}

// 监听文本改变
- (void)textViewEditChanged:(NSNotification *)obj {
    UITextField *textField = (UITextField *)obj.object;
    
    if (textField == self.detailAddress) {
        NSString *toBeString = textField.text;
        NSString *lang = [[textField textInputMode] primaryLanguage]; // 键盘输入模式
        NSUInteger maxLength = MaxNumberOfDescriptionChars-self.curZone.text.length-1;//加上自动定位的地址，上限是45个汉字
        
        if ([lang hasPrefix:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
            UITextRange *selectedRange = [textField markedTextRange];
            //获取高亮部分
            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            
            if (!position) {
                if (toBeString.length > maxLength) {
                    textField.text = [toBeString substringToIndex:maxLength];
                }
                //过滤表情符号
                if ([textField.text isContainsEmoji]) {
                    textField.text = self.textfieldExistStr;
                } else {
                    self.textfieldExistStr = textField.text;
                }
            } else{       // 有高亮选择的字符串，则暂不对文字进行统计和限制
                
            }
        } else { // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
            if (toBeString.length > maxLength) {
                textField.text = [toBeString substringToIndex:maxLength];
            }
            //过滤表情符号
            if ([textField.text isContainsEmoji]) {
                textField.text = self.textfieldExistStr;
            } else {
                self.textfieldExistStr = textField.text;
            }
        }
    }
}

#pragma mark - AddressInputHintViewControllerDelegate

- (void)onAddressMapTipSelect:(id)obj {
    AMapTip *tip = obj;
    
    self.AMapPlaceSearchFromSearchVC = YES;
    
    //这个地方显示的地址就用用户输入的string
    if (tip.district.length > 0) {
        self.address = [tip.district stringByAppendingString:tip.name];
    } else {
        self.address = tip.name;
    }
    
    //发起POI搜索
    AMapPOIKeywordsSearchRequest *poiRequest = [AMapPOIKeywordsSearchRequest new];
    poiRequest.keywords = tip.name;
    poiRequest.city = tip.adcode;
    [self.search AMapPOIKeywordsSearch:poiRequest];
}

#pragma mark - Map tool

// 从AMapGeocodeSearchResponse中选取离当前位置最近的
- (id)nearestPlaceInArray:(NSMutableArray *)arr {
    if (!arr) return nil;
    
    id ret = nil;
    
    for (id obj in arr) {
        if (!ret) {
            ret = obj;
            continue;
        }
        
        if ([obj isKindOfClass:[AMapGeocode class]]) {
            AMapGeocode *geocode = ret;
            AMapGeocode *ag = obj;
            if ([LocationModel kilometerDistanceBetween:
                 [LocationModel modelWithLongitude:ag.location.longitude latitude:ag.location.latitude]
                                                    and:
                 [LocationModel modelWithLongitude:self.curAnnotation.coordinate.longitude latitude:self.curAnnotation.coordinate.latitude]]
                <
                [LocationModel kilometerDistanceBetween:
                 [LocationModel modelWithLongitude:geocode.location.longitude latitude:geocode.location.latitude]
                                                    and:
                 [LocationModel modelWithLongitude:self.curAnnotation.coordinate.longitude latitude:self.curAnnotation.coordinate.latitude]]
                ) {
                ret = ag;
            }
        } else if ([obj isKindOfClass:[MAUserLocation class]]) {
            MAUserLocation *userlocation = ret;
            MAUserLocation *ul = obj;
            if ([LocationModel kilometerDistanceBetween:
                 [LocationModel modelWithLongitude:ul.coordinate.longitude latitude:ul.coordinate.latitude]
                                                    and:
                 [LocationModel modelWithLongitude:self.curAnnotation.coordinate.longitude latitude:self.curAnnotation.coordinate.latitude]]
                <
                [LocationModel kilometerDistanceBetween:
                 [LocationModel modelWithLongitude:userlocation.coordinate.longitude latitude:userlocation.coordinate.latitude]
                                                    and:
                 [LocationModel modelWithLongitude:self.curAnnotation.coordinate.longitude latitude:self.curAnnotation.coordinate.latitude]]
                ) {
                ret = ul;
            }
        }
    }
    
    return ret;
}

// 重定为地图上的精度圈
- (void)selectCircleOnMapWithCenterCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.mapView removeOverlays:self.mapView.overlays];
    
    [self addCircleToMapWithCenterCoordinate:coordinate];
}

// 向地图增加一个精度圈
- (void)addCircleToMapWithCenterCoordinate:(CLLocationCoordinate2D)coordinate {
    MACircle *circle = [MACircle circleWithCenterCoordinate:coordinate radius:60];
    [self.mapView addOverlay:circle];
}

// 添加坐标点
- (void)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    //更改地图中心点
    [self clearAnnotations];
    
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode = MAUserTrackingModeNone;
    self.an.coordinate = coordinate;
    [self.mapView addAnnotation:self.an];
    
    self.curAnnotation = self.an;
    
    [self.mapView selectAnnotation:self.an animated:YES];
    
    [self selectCircleOnMapWithCenterCoordinate:coordinate];
}

/* 清除annotation. */
- (void)clearAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)clearMapView {
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch {
    
}

#pragma mark - Property

- (MAPointAnnotation *)an {
    if (!_an) {
        _an = [[MAPointAnnotation alloc] init];
    }
    return _an;
}

- (AMapSearchAPI*)search {
    if (!_search) {
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;
    }
    return _search;
}

- (MAMapView*)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _mapView.delegate = self;
    }
    return _mapView;
}

@end
