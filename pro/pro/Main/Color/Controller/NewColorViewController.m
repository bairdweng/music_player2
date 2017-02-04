//
//  NewColorViewController.m
//  pro
//
//  Created by Baird-weng on 2017/1/16.
//  Copyright © 2017年 huaxia. All rights reserved.
//
#import "MBProgressHUD.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
#import "BlueServerManager.h"
#import "NewColorViewController.h"
#import "HeaderView.h"
#import "EFCircularSlider.h"
#import "EFCircularSliderView.h"
#import "ColorButtons.h"
#import "BLSliderView.h"
#import "ControBtnView.h"
#import "DeviceTableView.h"
#import "CMDModel.h"
@interface NewColorViewController (){
    UIScrollView *_showScrollView;
    UILabel *_titleLabel;
    UIButton *_leftBtn;
    EFCircularSliderView *_efCircularSliderView;
    ColorButtons *_colorButtons;
    BLSliderView *_blSliderView;
    ControBtnView *_controBtnView;
    DeviceTableView *_deviceTableView;
    BOOL _showDevice;
    NSData *_currentData;
}
@property(nonatomic,assign)BOOL ShowDeviceTableView;
@property (nonatomic, assign) BOOL isShow;
@end

@implementation NewColorViewController
- (instancetype)init {
    if (self = [super init]) {
        //self.title = @"color";
        UIImage *image_1 = [UIImage imageNamed:@"tab_color"];
        image_1 = [image_1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *image_2 = [UIImage imageNamed:@"tab_color_select"];
        image_2 = [image_2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:image_1 selectedImage:image_2];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_currentData){
        
        Byte *testByte = (Byte *)[_currentData bytes];
        //模式位。
        testByte[1] = [BlueServerManager sharedInstance].modeOftype;
        NSData *newData =  [[NSData alloc] initWithBytes:testByte length:8];
        [[BlueServerManager sharedInstance] sendData:newData];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _currentData = [[CMDModel sharedInstance] getCuttentData];
}
-(void)setShowDeviceTableView:(BOOL)ShowDeviceTableView{
    _ShowDeviceTableView = ShowDeviceTableView;
    _showDevice = _ShowDeviceTableView;
    if (ShowDeviceTableView){
        [self ShowStartscanForPeripherals];
        [[BabyBluetooth shareBabyBluetooth]cancelAllPeripheralsConnection];
        [BlueServerManager sharedInstance].currentcharacteristic = nil;
        [BlueServerManager sharedInstance].currentPeripheral = nil;
        
        CGRect _deviceframe = _deviceTableView.frame;
        _deviceframe.origin.x = 0;
        [UIView animateWithDuration:0.5 animations:^{
            _deviceTableView.frame = _deviceframe;
        }];
    }
    else{
        //取消扫描。
        [[BabyBluetooth shareBabyBluetooth]cancelScan];
        CGRect _deviceframe = _deviceTableView.frame;
        _deviceframe.origin.x = -_deviceTableView.frame.size.width;
        [UIView animateWithDuration:0.5 animations:^{
            _deviceTableView.frame = _deviceframe;
        }completion:^(BOOL finished) {
            [self showDissMiss];
        }];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    HeaderView *headerView = [[HeaderView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    headerView.title = @"RockFun";
    [self.view addSubview:headerView];
    
    
    _showScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), self.view.frame.size.width, self.view.frame.size.height-CGRectGetMaxY(headerView.frame)-48)];
    [self.view addSubview:_showScrollView];
    
    
    _leftBtn = [UIButton new];
    CGRect frame = CGRectMake(15, 10, 60, 26);
    _leftBtn.frame = frame;
    UIImage *img = [UIImage imageNamed:@"backto_off"];
    [_leftBtn setBackgroundImage:img forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(clickleftBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_showScrollView addSubview:_leftBtn];
    
    _titleLabel = [UILabel new];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = NSLocalizedString(@"status", nil);
    _titleLabel.textAlignment = 1;
    [_showScrollView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_leftBtn);
        make.width.equalTo(self.view);
    }];
    
    CGFloat View_JG = 0;
    
    if (SCREEN_HEIGHT >= 736) {
        View_JG = 10;
    }
    else if (SCREEN_HEIGHT == 667){
        View_JG = 5;
    }
    CGFloat size_size = SCREEN_WIDTH * 0.7;
    _efCircularSliderView = [[EFCircularSliderView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-size_size)/2, CGRectGetMaxY(_leftBtn.frame)+10, size_size, size_size)];
    [_efCircularSliderView getEventBlck:^(double value){
        if ([BlueServerManager sharedInstance].mode == 1) {
            [BlueServerManager sharedInstance].mode = 0;
            _controBtnView.controMode = 0;
        }
        else if ([BlueServerManager sharedInstance].mode == 3){
            [BlueServerManager sharedInstance].mode = 2;
            _controBtnView.controMode = 2;
        }
        
        
        [_colorButtons reset];
    }];
    [_showScrollView addSubview:_efCircularSliderView];
    
    CGFloat colorButton_Width = SCREEN_WIDTH * 0.8;
    CGFloat ButtonView_Y = CGRectGetMaxY(_efCircularSliderView.frame)+View_JG;
    
    _colorButtons= [[ColorButtons alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-colorButton_Width)/2, ButtonView_Y, colorButton_Width, 50)];
    [_showScrollView addSubview:_colorButtons];
    
    [_colorButtons getEventBlck:^(NSInteger index){
        NSData *sendData = [[CMDModel sharedInstance] singleColors][index];
        Byte *testByte = (Byte *)[sendData bytes];
        if ([BlueServerManager sharedInstance].mode == 1) {
            [BlueServerManager sharedInstance].mode = 0;
            _controBtnView.controMode = 0;
        }
        else if ([BlueServerManager sharedInstance].mode == 3){
            [BlueServerManager sharedInstance].mode = 2;
            _controBtnView.controMode = 2;
        }
        testByte[1] = [BlueServerManager sharedInstance].modeOftype;
        NSData *newData =  [[NSData alloc] initWithBytes:testByte length:8];
        [[BlueServerManager sharedInstance] sendData:newData];
    }];
    
    
    CGFloat SliderView_Width = SCREEN_WIDTH * 0.95;
    CGFloat SliderView_Y = CGRectGetMaxY(_colorButtons.frame)+View_JG;
    _blSliderView = [[BLSliderView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-SliderView_Width)/2, SliderView_Y, SliderView_Width, 90)];
    [_showScrollView addSubview:_blSliderView];
    
    CGFloat ControBtn_Width = SCREEN_WIDTH * 0.95;
    CGFloat ControBtn_Y = CGRectGetMaxY(_blSliderView.frame)+View_JG;
    
    _controBtnView = [[ControBtnView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-SliderView_Width)/2, ControBtn_Y, ControBtn_Width, 80)];
    [_showScrollView addSubview:_controBtnView];
    _showScrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(_controBtnView.frame)+10);
    
    
    UITapGestureRecognizer *tapGet = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ClickOntheTap)];
    [_showScrollView addGestureRecognizer:tapGet];
    
    _deviceTableView = [[DeviceTableView alloc]init];
    CGFloat dev_y = 120;
    _deviceTableView.frame = CGRectMake(0, dev_y, SCREEN_WIDTH*0.7, SCREEN_HEIGHT-dev_y-48);
    [self.view addSubview:_deviceTableView];
    //点击设备链接。
    __weak typeof(self)WeakSelf = self;
    [_deviceTableView GetselectIndexBlock:^(CBPeripheral *peripheral) {
        [BabyBluetooth shareBabyBluetooth].having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics()
        .readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
        [BlueServerManager sharedInstance].currentPeripheral = peripheral;
        [WeakSelf showMiddleHint:NSLocalizedString(@"blueContent", nil)WithLoading:YES];
        [BlueServerManager sharedInstance].isSender = YES;
    }];
    [self bluetoothConfig];
    // Do any additional setup after loading the view.
}
/**
  单击
 */
-(void)ClickOntheTap{
    self.ShowDeviceTableView = NO;
}

/**
 点击左边按钮
 @param sender
 */
-(void)clickleftBtn:(UIButton *)sender{
    self.ShowDeviceTableView = !_showDevice;
}
/**
 蓝牙配置
 */
-(void)bluetoothConfig{
    [self ShowStartscanForPeripherals];
    [self babyDelegate];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态
}
-(void)ShowStartscanForPeripherals{
    [BabyBluetooth shareBabyBluetooth].scanForPeripherals().begin();
}
/**
 委托方法。
 */
-(void)babyDelegate{
    NSMutableArray *peripherals = [[NSMutableArray alloc]init];
    [[BabyBluetooth shareBabyBluetooth] setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (peripherals.count > 0) {
            if (![self isContain:peripheral withperipherals:peripherals]) {
                [peripherals addObject:peripheral];
            }
        }
        else {
            [peripherals addObject:peripheral];
        }
        _deviceTableView.dataSoureArray = peripherals;
    }];
    [[BabyBluetooth shareBabyBluetooth]setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [self showMiddleHint:NSLocalizedString(@"blueError", nil) WithLoading:NO];
        [[BabyBluetooth shareBabyBluetooth]cancelScan];
        [self ConnectSucessError];
    }];
    [[BabyBluetooth shareBabyBluetooth]setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral){
        self.isShow = NO;
        [self showMiddleHint:NSLocalizedString(@"blueSucess", nil) WithLoading:NO];
        [self ConnectSucessDeal];
    }];
    [[BabyBluetooth shareBabyBluetooth]setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [self showMiddleHint:NSLocalizedString(@"blueDissContent", nil) WithLoading:NO];
        [self ConnectSucessError];
    }];
    //获取最新的值
    [[BabyBluetooth shareBabyBluetooth]setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error){
        if (!error){
            if ([characteristic.UUID.UUIDString isEqualToString:@"FFE1"]){
                [BlueServerManager sharedInstance].currentcharacteristic = characteristic;
                [[BlueServerManager sharedInstance].currentPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                if ([BlueServerManager sharedInstance].isSender){
                    NSData *sendData = [[CMDModel sharedInstance] queryCMD];
                    [[BlueServerManager sharedInstance] sendQueryData:sendData];
                }
            }
        }
        else{
            NSLog(@"shareBabyBluetooth错误");
        }
    }];
    //订阅改变的时候
    [[BabyBluetooth shareBabyBluetooth]setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        if (error){
            NSLog(@"订阅改变的时候错误");
            return;
        }
        NSData *data = characteristic.value;
        Byte *mybytes = (Byte *)[data bytes];
        if (data.length == 6){
            [BlueServerManager sharedInstance].isSender = NO;
            [self didSendQueryData:mybytes];
            if (mybytes[0]==9||mybytes[0]==2) {
                mybytes[0] = 1;
                NSData *datas =  [[NSData alloc] initWithBytes:mybytes length:6];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[BlueServerManager sharedInstance]sendData:datas];
                });
            }
        }
    }];
    [[BabyBluetooth shareBabyBluetooth]setBlockOnDidWriteValueForDescriptor:^(CBDescriptor *descriptor, NSError *error) {
        if (error){
            [self showMiddleHint:error.description WithLoading:YES];
        }
    }];
}
//连接成功的处理
-(void)ConnectSucessDeal{
    self.ShowDeviceTableView = NO;
    _titleLabel.hidden = YES;
    [_leftBtn setBackgroundImage:[UIImage imageNamed:@"backto"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"isConnecttedKey"];
}
//连接失败的处理。
-(void)ConnectSucessError{
    _titleLabel.hidden = NO;
    [_leftBtn setBackgroundImage:[UIImage imageNamed:@"backto_off.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:isConnectted];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
/**
 读取设备的处理
 @param bytes
 */
-(void)didSendQueryData:(Byte [])bytes{
    if(bytes[0] == 1) {
        [BlueServerManager sharedInstance].mode = 0;
    }
    else if (bytes[0] == 3) {
        [BlueServerManager sharedInstance].mode = 1;
    }
    else if (bytes[0] == 5) {
        [BlueServerManager sharedInstance].mode = 2;
    }
    else if (bytes[0] == 8) {
        [BlueServerManager sharedInstance].mode = 3;
    }
    else {
        return;
    }
    _controBtnView.controMode = [BlueServerManager sharedInstance].mode;
    int progess = 0;
    if(bytes[1] == 255  && bytes[3] == 0) {
        progess = bytes[2];
    }
    else if (bytes[2] == 255  && bytes[3] == 0) {
        progess = 458 - bytes[1];
    }
    else if (bytes[1] == 0  && bytes[2] == 255) {
        progess = 390 + bytes[3];
    }
    else if (bytes[1] == 0  && bytes[3] == 255) {
        progess = 900 - bytes[2];
    }
    else if (bytes[2] == 0  && bytes[3] == 255) {
        progess = 900 + bytes[1];
    }
    else if (bytes[1] == 255  && bytes[2] == 0) {
        progess = 1410 - bytes[3];
    }
    _efCircularSliderView.currentValue = progess/1422.0;
    _blSliderView.SliderValue1 = bytes[4]/100.0;
    _blSliderView.SliderValue2 = bytes[5]/10.0;
    int btnTag = [self GetCololorBtn:bytes];
    if (btnTag != -1){
        _colorButtons.btnSelectIndex = btnTag;
    }
    else{
        //颜色按钮复位。
        [_colorButtons reset];
    }
}
//获取数据的颜色决定按钮是否要选中。
-(int)GetCololorBtn:(Byte [])bytes{
    int bytes_0 = bytes[1];
    int bytes_1 = bytes[2];
    int bytes_2 = bytes[3];
    int bytes_3 = bytes[4];
    //红色
    if (bytes_0==255&&bytes_1==0&&bytes_2==0&&bytes_3==100){
        return 0;
    }
    else if (bytes_0==0&&bytes_1==0&&bytes_2==255&&bytes_3==100){
        return 1;
    }
    else if (bytes_0==0&&bytes_1==255&&bytes_2==0&&bytes_3==100){
        return 2;
    }
    else if (bytes_0==255&&bytes_1==0&&bytes_2==255&&bytes_3==100){
        return 3;
    }
    else if (bytes_0==255&&bytes_1==255&&bytes_2==0&&bytes_3==100){
        return 4;
    }
    else if (bytes_0==0&&bytes_1==255&&bytes_2==255&&bytes_3==100){
        return 5;
        
    }
    else if (bytes_0==255&&bytes_1==255&&bytes_2==255&&bytes_3==100){
        return 6;
    }
    return -1;
}




- (BOOL)isContain:(CBPeripheral *)peripheral withperipherals:(NSMutableArray *)peripherals{
    for (CBPeripheral *obj in peripherals) {
        if ([obj.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            return YES;
        }
    }
    return NO;
}
-(void)showMiddleHint:(NSString *)hint WithLoading:(BOOL)loading {
    [self showDissMiss];
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    if (loading) {
        hud.animationType = MBProgressHUDAnimationZoom;
    }
    else{
        hud.mode = MBProgressHUDModeText;
        [hud hideAnimated:YES afterDelay:1.5];
    }
    hud.label.text = hint;
    hud.label.font = [UIFont systemFontOfSize:15];
    hud.margin = 10.f;
    hud.offset = CGPointMake(hud.offset.x, 0);
    hud.removeFromSuperViewOnHide = YES;
}

-(void)showDissMiss{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    [MBProgressHUD hideHUDForView:view animated:YES];
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
