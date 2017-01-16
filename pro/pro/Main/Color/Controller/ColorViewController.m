//
//  ColorViewController.m
//  pro
//
//  Created by xiaofan on 9/15/16.
//  Copyright © 2016 huaxia. All rights reserved.
//

#import "ColorViewController.h"
#import "MainMacos.h"
#import "BlueServerManager.h"
#import "CMDModel.h"
#import "EFCircularSlider.h"
#import "MBProgressHUD.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
#define COLOR_BTN_SIZE CGSizeMake(40, 40)
#define MODE_BTN_SIZE CGSizeMake(38,38)
#define SLIDER_IMAGE_SIZE CGSizeMake(90, 35)
#define SLIDER_TABLE_SIZE CGSizeMake(240, 480)

static NSString *const cellId = @"cellId";
//const static CGFloat originY = 360;
//const static CGFloat rowMargin = 20;
const static CGFloat columnMargin = 20;
@interface ColorViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSArray<NSString *> *_backColors;
    NSArray<NSString *> *_selectedBackColors;
    NSArray<NSString *> *_btnTittles;
    NSArray<UIImage *> *_backImage;
    NSArray<UIColor *> *_colors;
    NSData *_currentData;
    NSArray<CBPeripheral *> *_peripherals;
    UIScrollView *_showScrollView;
    CGFloat _JGValue;
    NSInteger _senderTwice;//发送次数。最多3次。
    int _templeIndex;
    BOOL _isplus;
    BOOL _on;
}
@property (nonatomic, strong) NSArray<UIButton *> *colorButtons;
@property (nonatomic, strong) UISlider *lightSlider;
@property (nonatomic, strong) UILabel *lightLabel;
@property (nonatomic, strong) UISlider *frequencySlider;
@property (nonatomic, strong) UILabel *frequenceLabel;
@property (nonatomic, strong) NSArray<UIButton *> *flickerButtons;
@property (nonatomic, strong) NSArray<UIButton *> *breatheButtons;
@property (nonatomic, strong) EFCircularSlider *circularSlider;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *indictorView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *powerButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, assign) int mode;
@property (nonatomic, strong) UITableView *sliderTableView;
@property (nonatomic, strong) NSArray<NSString *> *dataSource;
@property (nonatomic, strong) NSArray<CBPeripheral *> *Peripherals;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, strong) UIView *maskTableView;
@end
@implementation ColorViewController
- (instancetype)init {
    if (self = [super init]) {
        //self.title = @"color";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"adjust", nil) image:[UIImage imageNamed:@"color.png"] selectedImage:[UIImage imageNamed:@"color_selected.png"]];
    }
    return self;
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

- (BOOL)isContain:(CBPeripheral *)peripheral withperipherals:(NSMutableArray *)peripherals{
    for (CBPeripheral *obj in peripherals) {
        if ([obj.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            return YES;
        }
    }
    return NO;
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
        self.Peripherals = peripherals;
        [self.sliderTableView reloadData];
    }];
    [[BabyBluetooth shareBabyBluetooth]setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [self showMiddleHint:@"连接失败" WithLoading:NO];
        [[BabyBluetooth shareBabyBluetooth]cancelScan];
        [self ConnectSucessError];
    }];
    [[BabyBluetooth shareBabyBluetooth]setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral){
        self.isShow = NO;
        [self showMiddleHint:@"连接成功" WithLoading:NO];
        [self ConnectSucessDeal];
    }];
    [[BabyBluetooth shareBabyBluetooth]setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [self showMiddleHint:@"蓝牙已断开" WithLoading:NO];
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
    self.isShow = NO;
    _titleLabel.hidden = YES;
    [_backButton setBackgroundImage:[UIImage imageNamed:@"backto"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:isConnectted];
}
//连接失败的处理。
-(void)ConnectSucessError{
    _titleLabel.hidden = NO;
    [_backButton setBackgroundImage:[UIImage imageNamed:@"backto_off.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:isConnectted];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//获取数据的处理
-(void)didSendQueryData:(Byte [])bytes{
    if(bytes[0] == 1) {
        self.mode = 0;
    }
    else if (bytes[0] == 3) {
        self.mode = 1;
    }
    else if (bytes[0] == 5) {
        self.mode = 2;
    }
    else if (bytes[0] == 8) {
        self.mode = 3;
    }
    else {
        return;
    }
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
    
    
    self.circularSlider.currentValue = progess / 1422.0;
    [self circularSlidervalueChanged:self.circularSlider];
    // NSLog(@"%f",self.circularSlider.currentValue);
    //self.circularSlider.currentValue = 1;
    int angle = 0;
    float value = self.circularSlider.currentValue;
    if(value > 0 && value < 0.25) {
        angle = - (int)(value * 360);
    }
    else {
        angle = (int)(360 - value * 360);
    }
    [_circularSlider setPosition:angle];
    self.lightSlider.value = bytes[4] / 100.0;
    self.frequencySlider.value = bytes[5] / 10.0;
    [[CMDModel sharedInstance] writeCMD:bytes];
    int btnTag = [self GetCololorBtn:bytes];
    if (btnTag != -1){
        UIButton *colorbtn = [self.view viewWithTag:btnTag+50];
        [self clickColorsButton:colorbtn];
    }
    else{
        //颜色按钮复位。
        [_colorButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setBackgroundImage:[UIImage imageNamed:_backColors[idx]] forState:UIControlStateNormal];
        }];
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

-(void)viewDidLoad {
    [super viewDidLoad];
    _showScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-48)];
    CGFloat content = _showScrollView.frame.size.height;
    if (self.view.frame.size.height==480) {
        content = 500;
    }
    if (SCREEN_HEIGHT==736) {
        _JGValue = 45;
    }
    else if (SCREEN_HEIGHT == 667){
        _JGValue = 30;
    }
    else{
        _JGValue = 10;
    }
    _showScrollView.contentSize = CGSizeMake(self.view.frame.size.width, content);
    [self.view addSubview:_showScrollView];
    [self configSelf];
    [self configSubviews];
    [self bluetoothConfig];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_currentData) {
        [[BlueServerManager sharedInstance] sendData:_currentData];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _currentData = [[CMDModel sharedInstance] getCuttentData];
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.Peripherals.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    CBPeripheral *Peripheral = self.Peripherals[indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@#%@",Peripheral.name,Peripheral.identifier.UUIDString];
    NSArray<NSString *> *strings = [text componentsSeparatedByString:@"#"];
    if (strings && strings.count >= 1) {
        cell.textLabel.text = strings[0];
        cell.detailTextLabel.text = strings[1];
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //连接蓝牙。
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral *Peripheral = self.Peripherals[indexPath.row];
    [BabyBluetooth shareBabyBluetooth].having(Peripheral).connectToPeripherals().discoverServices().discoverCharacteristics()
    .readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    [BlueServerManager sharedInstance].currentPeripheral = Peripheral;
    [self showMiddleHint:@"正在连接" WithLoading:YES];
    [BlueServerManager sharedInstance].isSender = YES;
    _senderTwice = 0;
}

#pragma mark - button action

- (void)clickflickerButton: (UIButton *)sender {
    NSInteger index = sender.tag - 60;
    CMDModel *cmd = [CMDModel sharedInstance];
    NSData *sendData;
    if (index == 0) {
        return;
    }
    else if (index == 1) {
        sendData = cmd.threeBlinkCMD;//单色闪烁
        self.mode = 0;
    }
    else if (index == 2) {
        sendData = cmd.sevenBlinkCMD;//多彩闪烁。
        self.mode = 1;
    }
    [[BlueServerManager sharedInstance] sendData:sendData];
}

- (void)clickBreatheButton: (UIButton *)sender {
    NSInteger index = sender.tag - 70;
    CMDModel *cmd = [CMDModel sharedInstance];
    NSData *sendData;
    if (index == 0) {
        return;
    }
    else if (index == 1) {
        sendData = cmd.threeBreathCMD;//单色渐变。
        self.mode = 2;
    }
    else if (index == 2) {
        sendData = cmd.sevenBreathCMD;//多彩渐变。
        self.mode = 3;
    }
    [[BlueServerManager sharedInstance] sendData:sendData];
}
//滑动切换颜色
- (void)circularSlidervalueChanged: (EFCircularSlider *)sender {
    static int temp;
    if (temp == sender.currentValue * 1422) {
        return;
    }
    temp = sender.currentValue * 1422;
    
    UIColor *color = [[CMDModel sharedInstance] singleColor:temp];
    self.indictorView.backgroundColor = color;
    self.flickerButtons[1].backgroundColor = color;
    self.breatheButtons[1].backgroundColor = color;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sigleColorChanged" object:nil userInfo:@{@"color": color}];
    NSData *sendData = [[CMDModel sharedInstance] singleColorCMD:temp];
    //NSLog(@"send data");
    [[BlueServerManager sharedInstance] sendData:sendData];
    //按钮复位。
    if (self.mode == 3){
        UIButton *btn = [self.view viewWithTag:71];
        [self clickBreatheButton:btn];
    }
    else if (self.mode == 1){
        UIButton *btn = [self.view viewWithTag:61];
        [self clickflickerButton:btn];
    }
    [_colorButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setBackgroundImage:[UIImage imageNamed:_backColors[idx]] forState:UIControlStateNormal];
    }];
}
//点击按钮切换颜色。
- (void)clickColorsButton: (UIButton *)sender {
    NSInteger index = sender.tag - 50;
    [sender setBackgroundImage:[UIImage imageNamed:_selectedBackColors[index]] forState:UIControlStateNormal];
    [_colorButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (index != idx) {
            [obj setBackgroundImage:[UIImage imageNamed:_backColors[idx]] forState:UIControlStateNormal];
        }
    }];
    UIColor *color = _colors[index];
    self.flickerButtons[1].backgroundColor = color;
    self.breatheButtons[1].backgroundColor = color;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sigleColorChanged" object:nil userInfo:@{@"color": color}];
    //记住模式位。
    NSData *sendData = [[CMDModel sharedInstance] singleColors][index];
    Byte *testByte = (Byte *)[sendData bytes];
    //单色闪烁到多彩渐变。
    switch (self.mode) {
        case 0:{
            testByte[1] = 1;
        }
            break;
        case 1:{
            testByte[1] = 1;
            self.mode = 0;
        }
            break;
        case 2:{
            testByte[1] = 5;
        }
            break;
        case 3:{
            testByte[1] = 5;
            self.mode = 2;
        }
            break;
            
        default:
            break;
    }
    NSData *newData =  [[NSData alloc] initWithBytes:testByte length:8];
    [[BlueServerManager sharedInstance] sendData:newData];
}
- (void)lightValueChanged: (UISlider *)sender {
    static int temp;
    if (temp == sender.value * 100) {
        return;
    }
    temp = sender.value * 100;
    NSData *sendData = [[CMDModel sharedInstance] brightnessCMD:(temp)];
    [[BlueServerManager sharedInstance] sendData:sendData];
}
//频率滑块。
- (void)frequencyValueChanged: (UISlider *)sender {
    static int temp;
    if (temp == sender.value * 10) {
        return;
    }
    temp = sender.value * 10;
    //值改变再发送数据
    if (_templeIndex != temp) {
        _templeIndex = temp;
        //等于0的时候延迟执行，防止蓝牙数据丢失。
        if (_templeIndex == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSData *sendData = [[CMDModel sharedInstance] speedCMD:(temp)];
                [[BlueServerManager sharedInstance] sendData:sendData];
            });
        }
        else{
            NSData *sendData = [[CMDModel sharedInstance] speedCMD:(temp)];
            [[BlueServerManager sharedInstance] sendData:sendData];
        }
    }
}

- (void)clickPowerButton: (UIButton *)sender {
    NSData *sendData;
    NSString *name;
    if (_on) {
        name = @"power_on";
        sendData = [[CMDModel sharedInstance] powerOff];
    }
    else {
        name = @"power_off";
        sendData = [[CMDModel sharedInstance] powerOn];
    }
    _on = !_on;
    [_powerButton setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [[BlueServerManager sharedInstance] sendData:sendData];
}
- (void)clickBackButton: (UIButton *)sender{
    self.isShow = !_isShow;
}
#pragma mark - notification
- (void)bluDidDisconnectd: (NSNotification *)noti {
    _titleLabel.hidden = NO;
    [_backButton setBackgroundImage:[UIImage imageNamed:@"backto_off.png"] forState:UIControlStateNormal];
}
#pragma mark - gesture
- (void)tapMaskView {
    self.isShow = NO;
}
#pragma mark - private
- (void) configSelf {
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _showScrollView.contentSize.height)];
    backImageView.image = [UIImage imageNamed:@"backgroud.jpg"];
    [_showScrollView insertSubview:backImageView atIndex:0];
    _backColors = @[@"red_off.png", @"blue_off.png", @"green_off.png", @"pick_off.png", @"yellow_off.png", @"lowblue_off.png", @"white_off.png"];
    _selectedBackColors = @[@"red_on.png", @"blue_on.png", @"green_on.png", @"pick_on.png", @"yellow_on.png", @"lowblue_on.png", @"white_on.png"];
    _btnTittles = @[@"频闪",@"三色",@"七色"];
    UIColor *pick = [UIColor colorWithRed:1.0 green:0 blue:1.0 alpha:1.0];
    UIColor *lowblue = [UIColor colorWithRed:0 green:1.0 blue:1.0 alpha:1.0];
    _backImage = @[[UIImage imageNamed:@"b3.png"],[UIImage imageNamed:@"b3.png"],[UIImage imageNamed:@"mulColor.png"]];
    _colors = @[[UIColor redColor], [UIColor blueColor], [UIColor greenColor], pick, [UIColor yellowColor], lowblue, [UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluDidDisconnectd:) name:@"BluServerDidDisconnected" object:nil];
}
- (void)sliderTableViewShow {
    //开始扫描
    [self ShowStartscanForPeripherals];
    [[BabyBluetooth shareBabyBluetooth]cancelAllPeripheralsConnection];
    [BlueServerManager sharedInstance].currentcharacteristic = nil;
    [BlueServerManager sharedInstance].currentPeripheral = nil;

    CGRect frame = self.sliderTableView.frame;
    frame.origin.x = 0;
    [UIView animateWithDuration:0.8 animations:^{
        _sliderTableView.frame = frame;
    } completion:^(BOOL finished) {
    }];
}
- (void)sliderTableViewHidden {
    //取消扫描。
    [[BabyBluetooth shareBabyBluetooth]cancelScan];
    CGRect frame = self.sliderTableView.frame;
    frame.origin.x = - CGRectGetWidth(frame);
    [UIView animateWithDuration:0.8  animations:^{
        _sliderTableView.frame = frame;
    } completion:^(BOOL finished) {
        [self showDissMiss];
    }];
}

- (void)configSubviews {
    [self.colorButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_showScrollView addSubview:obj];
    }];
    [_showScrollView addSubview:self.lightSlider];
    [_showScrollView addSubview:self.frequencySlider];
 
    [_showScrollView addSubview:self.circularSlider];
    [_showScrollView insertSubview:self.imageView belowSubview:_circularSlider];
    [_showScrollView insertSubview:self.indictorView belowSubview:_circularSlider];
    [_showScrollView addSubview:self.lightLabel];
    [_showScrollView addSubview:self.frequenceLabel];
    [_showScrollView addSubview:self.lineView];
    [_showScrollView addSubview:self.powerButton];
    [_showScrollView addSubview:self.titleLabel];
    [_showScrollView addSubview:self.backButton];
    _sliderTableView.tag = 1000;
    [self.flickerButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_showScrollView addSubview:obj];
    }];
    [self.breatheButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_showScrollView addSubview:obj];
    }];
    
    UIButton *lastBtn;
    for (int i = 0; i<[self.flickerButtons count]; i++) {
        UIButton *btn = self.flickerButtons[i];
        if (i == 0){
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lineView.mas_bottom).offset(_JGValue);
                make.width.equalTo(@50);
                make.height.equalTo(@38);
                make.left.equalTo(@15);
            }];
        }
        else{
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(lastBtn);
                make.left.equalTo(lastBtn.mas_right).offset(8);
                make.width.height.equalTo(@38);
            }];
        }
        lastBtn = btn;
    }
    for (int i = (int)[self.breatheButtons count]-1; i>=0; i--) {
        UIButton *btn = self.breatheButtons[i];
        if (i == (int)[self.breatheButtons count]-1){
            [btn mas_makeConstraints:^(MASConstraintMaker *make){
                make.right.equalTo(self.view.mas_right).offset(-15);
                make.width.height.equalTo(@38);
                make.centerY.equalTo(lastBtn);
            }];
        }
        else if (i == 0){
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(lastBtn);
                make.right.equalTo(lastBtn.mas_left).offset(-8);
                make.width.equalTo(@50);
                make.height.equalTo(@38);
            }];
        }
        else{
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.centerY.equalTo(lastBtn);
                make.right.equalTo(lastBtn.mas_left).offset(-8);
            }];
        }
        lastBtn = btn;
        
    }
    [_showScrollView addSubview:self.sliderTableView];
    [_showScrollView insertSubview:self.maskTableView belowSubview:_sliderTableView];
    CGRect frame = _flickerButtons[0].frame;
    frame.origin.x = CGRectGetMinX(_flickerButtons[1].frame) - CGRectGetWidth(frame) + 0.0266667 * SCREEN_WIDTH;
    _flickerButtons[0].frame = frame;
    
    frame = _breatheButtons[0].frame;
    frame.origin.x = CGRectGetMinX(_breatheButtons[1].frame) - CGRectGetWidth(frame) + 0.013333 * SCREEN_WIDTH;
    _breatheButtons[0].frame = frame;
    //self.mode = 0;
    self.isShow = YES;
    
    //mas布局
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@60);
        make.width.equalTo(@65);
        make.height.equalTo(@30);
    }];
    self.backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.powerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.width.equalTo(@65);
        make.height.equalTo(@30);
        make.top.equalTo(@60);
    }];
    
}

#pragma mark - getter
- (NSArray<UIButton *> *)colorButtons {
    if (!_colorButtons) {
        NSMutableArray<UIButton *> *temp = [NSMutableArray array];
        CGSize size = COLOR_BTN_SIZE;
        CGFloat margin = (SCREEN_WIDTH - 2 * columnMargin - 7 * size.width) / 6;
        for (int i = 0; i < 7; i++) {
            UIButton *btn = [UIButton new];
            [btn setBackgroundImage:[UIImage imageNamed:_backColors[i]] forState:UIControlStateNormal];
            
            CGRect frame;
            frame.size = COLOR_BTN_SIZE;
            CGFloat pointY = CGRectGetMaxY(self.frequencySlider.frame) + _JGValue;
            CGFloat pointX = columnMargin + (CGRectGetWidth(frame) + margin) * i;
            frame.origin = CGPointMake(pointX, pointY);
            btn.frame = frame;
            
            [btn addTarget:self action:@selector(clickColorsButton:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 50 + i;
            btn.layer.cornerRadius = 8;
            btn.layer.masksToBounds = YES;
            [temp addObject:btn];
        }
        _colorButtons = [temp copy];
    }
    return _colorButtons;
}

- (UISlider *)lightSlider {
    if (!_lightSlider) {
        _lightSlider = [UISlider new];
        CGRect frame;
        frame.origin.x = CGRectGetMaxX(self.lightLabel.frame) + columnMargin;
        frame.size.width = SCREEN_WIDTH - CGRectGetMinX(frame) - columnMargin;
        frame.size.height = 20;
        if (ISTOTAKEEFFECT) {
            _lightSlider.minimumTrackTintColor = THETIMECOLOR;
        }
        frame.origin.y = CGRectGetMaxY(self.circularSlider.frame) + SCREEN_HEIGHT * 0.045;
        _lightSlider.frame = frame;
        _lightSlider.value = 1;
        [_lightSlider addTarget:self action:@selector(lightValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _lightSlider;
}

- (UISlider *)frequencySlider {
    if (!_frequencySlider) {
        _frequencySlider = [UISlider new];
        CGRect frame;
        frame.origin.x = CGRectGetMaxX(self.lightLabel.frame) + columnMargin;
        frame.size.width = SCREEN_WIDTH - CGRectGetMinX(frame) - columnMargin;
        frame.size.height = 20;
        frame.origin.y = CGRectGetMaxY(self.lightSlider.frame) + 0.045 * SCREEN_HEIGHT;
        _frequencySlider.minimumValue = 0;
        _frequencySlider.frame = frame;
        _frequencySlider.value = 0;
        if (ISTOTAKEEFFECT) {
            _frequencySlider.minimumTrackTintColor = THETIMECOLOR;
        }
        [_frequencySlider addTarget:self action:@selector(frequencyValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _frequencySlider;
}

- (NSArray<UIButton *> *)flickerButtons {
    if (!_flickerButtons) {
        NSMutableArray<UIButton *> *temp = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            UIButton *btn = [UIButton new];
            [btn addTarget:self action:@selector(clickflickerButton:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 60 + i;
            [temp addObject:btn];
            
            if (i == 0) {
                [btn setTitle:NSLocalizedString(@"strobe", nil) forState:UIControlStateNormal];
            }
            else if (i == 2) {
                [btn setBackgroundImage:_backImage[i] forState:UIControlStateNormal];
            }
            else {
                btn.backgroundColor = [UIColor redColor];
            }
            btn.layer.cornerRadius = 12;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
        }
        _flickerButtons = [temp copy];
    }
    return _flickerButtons;
}

- (NSArray<UIButton *> *)breatheButtons {
    if (!_breatheButtons) {
        NSMutableArray<UIButton *> *temp = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            UIButton *btn = [UIButton new];
            [btn addTarget:self action:@selector(clickBreatheButton:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 70 + i;
            [temp addObject:btn];
            
            if (i == 0) {
                [btn setTitle:NSLocalizedString(@"plusating", nil) forState:UIControlStateNormal];
            }
            else if(i == 2){
                [btn setBackgroundImage:_backImage[i] forState:UIControlStateNormal];
            }
            else {
                btn.backgroundColor = [UIColor redColor];
            }
            btn.layer.cornerRadius = 12;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
        }
        _breatheButtons = [temp copy];
    }
    return _breatheButtons;
}

- (EFCircularSlider *)circularSlider {
    if (!_circularSlider) {
        CGFloat size_size = SCREEN_WIDTH * 0.58;
        CGFloat y = CGRectGetMaxY(self.backButton.frame) + 0.06 * SCREEN_HEIGHT;
        CGRect frame = CGRectMake(50, y, size_size, size_size);
         _circularSlider = [[EFCircularSlider alloc] initWithFrame:frame];
        CGPoint center = _circularSlider.center;
        center.x = self.view.center.x;
        _circularSlider.center = center;
        if (ISTOTAKEEFFECT) {
            _circularSlider.handleColor = THETIMECOLOR;
        }
         [_circularSlider addTarget:self action:@selector(circularSlidervalueChanged:) forControlEvents:UIControlEventValueChanged];
        _circularSlider.handleType = bigCircle;
        _circularSlider.minimumValue = 0;
        _circularSlider.maximumValue = 1;
        _circularSlider.currentValue = 0;
    }
    return _circularSlider;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        
        CGRect frame = self.circularSlider.frame;
        _imageView.frame = CGRectInset(frame, -5, -5);
        _imageView.image = [UIImage imageNamed:@"circleColor.png"];
    }
    return _imageView;
}

- (UIView *)indictorView {
    if (!_indictorView) {
        _indictorView = [UIView new];
        CGRect frame;
        CGFloat width = 0.13 * SCREEN_WIDTH;
        frame.size = CGSizeMake(width, width);
        _indictorView.frame = frame;
        _indictorView.center = self.circularSlider.center;
        _indictorView.layer.cornerRadius = 0.5 * CGRectGetHeight(frame);
        _indictorView.layer.masksToBounds = YES;
        _indictorView.backgroundColor = [UIColor redColor];
    }
    return _indictorView;
}


- (UILabel *)lightLabel {
    if (!_lightLabel) {
        _lightLabel = [UILabel new];
        CGRect frame = CGRectZero;
        frame.size = SLIDER_IMAGE_SIZE;
        frame.origin.x = 10;
        _lightLabel.frame = frame;
        CGPoint center = _lightLabel.center;
        center.y = self.lightSlider.center.y;
        _lightLabel.center = center;
        _lightLabel.textAlignment = NSTextAlignmentCenter;
        _lightLabel.font = [UIFont systemFontOfSize:14];
        _lightLabel.text = NSLocalizedString(@"bright", nil);
        _lightLabel.textColor = [UIColor whiteColor];
        _lightLabel.textAlignment = NSTextAlignmentRight;
    }
    return _lightLabel;
}

-(UILabel *)frequenceLabel {
    if (!_frequenceLabel) {
        _frequenceLabel = [UILabel new];
        CGRect frame = CGRectZero;
        frame.size = SLIDER_IMAGE_SIZE;
        frame.origin.x = 10;
        _frequenceLabel.frame = frame;
        CGPoint center = _frequenceLabel.center;
        center.y = self.frequencySlider.center.y;
        _frequenceLabel.center = center;
        _frequenceLabel.textAlignment = NSTextAlignmentCenter;
        _frequenceLabel.text = NSLocalizedString(@"frequency", nil);
        _frequenceLabel.textColor = [UIColor whiteColor];
        _frequenceLabel.font = [UIFont systemFontOfSize:14];
        _frequenceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _frequenceLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        CGRect frame;
        frame.origin.x = CGRectGetMinX(self.frequenceLabel.frame);
        frame.origin.y = CGRectGetMaxY(self.colorButtons[0].frame) + 5;
        frame.size.width = SCREEN_WIDTH - 2 * CGRectGetMinX(frame);
        frame.size.height = 1.5;
        _lineView.frame = frame;
        _lineView.backgroundColor = [UIColor colorWithRed:181 / 255.0 green:181 / 255.0 blue:183 / 255.0 alpha:1.0];
        
    }
    return _lineView;
}

- (UIButton *)powerButton {
    if (!_powerButton) {
        _powerButton = [UIButton new];
        _powerButton.frame = CGRectMake(SCREEN_WIDTH - 88 -15, 54, 88, 40);
        [_powerButton addTarget:self action:@selector(clickPowerButton:) forControlEvents:UIControlEventTouchUpInside];
        [_powerButton setBackgroundImage:[UIImage imageNamed:@"power_off"] forState:UIControlStateNormal];
        _on = YES;
    }
    return _powerButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.frame = CGRectMake(0, 20, SCREEN_WIDTH, 38);
        _titleLabel.text = NSLocalizedString(@"status", nil);
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton new];
        CGRect frame = CGRectMake(15, 54, 60, 26);
        _backButton.frame = frame;
        UIImage *img = [UIImage imageNamed:@"backto_off"];
        [_backButton setBackgroundImage:img forState:UIControlStateNormal];
        
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UITableView *)sliderTableView {
    if (!_sliderTableView) {
        _sliderTableView = [UITableView new];
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(240, _showScrollView.contentSize.height-CGRectGetMaxY(self.backButton.frame)-10);
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(self.backButton.frame) + 10;
        _sliderTableView.frame = frame;
        _sliderTableView.delegate = self;
        _sliderTableView.dataSource = self;
        _sliderTableView.backgroundColor = [UIColor colorWithRed:17.0 / 255 green:18.0 / 255 blue:67.0 / 255 alpha:0.75];
    }
    return _sliderTableView;
}

- (BlueServerManager *)manager {
    
    return nil;
//    if (!_manager) {
//        _manager = [BlueServerManager sharedInstance];
//        _manager.delegate = self;
//    }
//    return _manager;
}

- (UIView *)maskTableView {
    if (!_maskTableView) {
        _maskTableView = [[UIView alloc] initWithFrame:MAINSCREEN];
        _maskTableView.userInteractionEnabled = YES;
        _maskTableView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskView)];
        [_maskTableView addGestureRecognizer:tapGesture];
    }
    return _maskTableView;
}


#pragma mark - setter
- (void)setMode:(int)mode {
    _mode = mode;
    //单色闪烁
    if (mode == 0) {
        [self.flickerButtons[1] setImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
        [self.flickerButtons[2] setImage:[UIImage new] forState:UIControlStateNormal];
        [self.breatheButtons[1] setImage:[UIImage new] forState:UIControlStateNormal];
        [self.breatheButtons[2] setImage:[UIImage new] forState:UIControlStateNormal];
        
    }
    //多彩闪烁
    else if (mode == 1) {
        [self.flickerButtons[1] setImage:[UIImage new] forState:UIControlStateNormal];
        [self.flickerButtons[2] setImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
        [self.breatheButtons[1] setImage:[UIImage new] forState:UIControlStateNormal];
        [self.breatheButtons[2] setImage:[UIImage new] forState:UIControlStateNormal];
        [self.colorButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setBackgroundImage:[UIImage imageNamed:_backColors[idx]] forState:UIControlStateNormal];
        }];

    }
    //单色渐变
    else if (mode == 2) {
        [self.flickerButtons[1] setImage:[UIImage new] forState:UIControlStateNormal];
        [self.flickerButtons[2] setImage:[UIImage new] forState:UIControlStateNormal];
        [self.breatheButtons[1] setImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
        [self.breatheButtons[2] setImage:[UIImage new] forState:UIControlStateNormal];
    }
    //多彩渐变
    else {
        [self.flickerButtons[1] setImage:[UIImage new] forState:UIControlStateNormal];
        [self.flickerButtons[2] setImage:[UIImage new] forState:UIControlStateNormal];
        [self.breatheButtons[1] setImage:[UIImage new] forState:UIControlStateNormal];
        [self.breatheButtons[2] setImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
        [self.colorButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setBackgroundImage:[UIImage imageNamed:_backColors[idx]] forState:UIControlStateNormal];
        }];
    }
}
- (void)setDataSource:(NSArray<NSString *> *)dataSource {
    _dataSource = dataSource;
    [self.sliderTableView reloadData];
}
- (void)setIsShow:(BOOL)isShow{
    _isShow = isShow;
    if (_isShow) {
        [self sliderTableViewShow];
        
    }
    else {
        [self sliderTableViewHidden];
    }
    _maskTableView.hidden = !_isShow;
}

#pragma mark - delayMethod
- (void)delayMethod {
    if (_dataSource && _dataSource.count > 0) {
        return;
    }
    if (_titleLabel.hidden) {
        return;
    }
    self.isShow = NO;
}
- (void)showMiddleHint:(NSString *)hint WithLoading:(BOOL)loading {
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
@end
