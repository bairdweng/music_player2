//
//  MusicViewController.m
//  pro
//
//  Created by xiaofan on 9/15/16.
//  Copyright © 2016 huaxia. All rights reserved.
//

#import "BLMusicViewController.h"
#import "MainMacos.h"
#import "VoiceHelper.h"
#import "FrequencyView.h"
#import "CMDModel.h"
#import "BlueServerManager.h"
#import "MusicListViewController.h"
#define BUTTON_SIZE CGSizeMake(50, 50);

const static CGFloat button_margin = 30;
const static CGFloat slider_margin = 22;
const static CGFloat max_height = 100;
const static CGFloat min_height = 5;

@interface BLMusicViewController ()<VoiceHelperDelegate,MusicListViewControllerDelegate> {
    CGFloat _element_height;
    UIButton *_rightButton;
    UILabel *_titleLabel;
    UIScrollView *_showScrollView;
    MusicListViewController *_listViewController;
    BOOL _on;
    BOOL _isplayer;
    double _currentValue;
}
@property (nonatomic, strong) UIButton *singleButton;
@property (nonatomic, strong) UIButton *mulButton;
@property (nonatomic, strong) UILabel *singleLabel;
@property (nonatomic, strong) UILabel *mulLabel;
@property (nonatomic, strong) UILabel *sensitivityLabel;
@property (nonatomic, strong) UISlider *sensitivitySlider;
@property (nonatomic, strong) FrequencyView *frequencyView;
@property (nonatomic, assign) BOOL flag;
@end
@implementation BLMusicViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"musci";
        UIImage *image_1 = [UIImage imageNamed:@"mic_control"];
        image_1 = [image_1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *image_2 = [UIImage imageNamed:@"mic_control_select"];
        image_2 = [image_2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:image_1 selectedImage:image_2];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    VoiceHelper *voiceHelper = [VoiceHelper sharedInstance];
    voiceHelper.delegate = self;
    _showScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-48)];
    CGFloat content = _showScrollView.frame.size.height;
    if (self.view.frame.size.height==480) {
        content = 480;
    }
    _showScrollView.contentSize = CGSizeMake(self.view.frame.size.width, content);
    [self.view addSubview:_showScrollView];
    [self configSelf];
    [self configSubview];
//    [self configMusicListView];//屏蔽音乐
    _isplayer = NO;
}
-(void)configMusicListView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MusicList" bundle:[NSBundle mainBundle]];
    _listViewController = [storyboard instantiateViewControllerWithIdentifier:@"musicList"];
    [_showScrollView addSubview:_listViewController.view];
    _listViewController.delegate = self;
    [self addChildViewController:_listViewController];
    _listViewController.view.backgroundColor = [UIColor clearColor];
    _listViewController.view.frame = CGRectMake(0, self.sensitivitySlider.frame.origin.y+30, self.view.frame.size.width, 100);
}
-(void)peakValue:(double)value{
    NSInteger temp = (NSInteger)((value * _element_height) * 1.5);
    _frequencyView.volume = temp;
    //异步发送。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *sendData;
        if (_flag) {
            sendData = [[CMDModel sharedInstance] singleMusicCMD:value];
        }
        else {
            sendData = [[CMDModel sharedInstance] musicCMD:value];
        }
        [[BlueServerManager sharedInstance] sendData:sendData];
    });
}

-(void)playerMusic:(BOOL)isplayer{
    _isplayer = isplayer;
    if (_isplayer) {
        [[VoiceHelper sharedInstance]pause];
    }
    else{
        [[VoiceHelper sharedInstance]record];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL flag = [[[NSUserDefaults standardUserDefaults]objectForKey:isConnectted] boolValue];
    if (!flag) {
        [[VoiceHelper sharedInstance] pause];
        _titleLabel.text = @"RGB Bluetooth(蓝牙未连接)";
    }
    else {
        _titleLabel.text = @"RGB Bluetooth";
        [[VoiceHelper sharedInstance] record];
        [[BlueServerManager sharedInstance] sendData:[[CMDModel sharedInstance] musicCMD:0]];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_listViewController musicPlayerStop];
    [[VoiceHelper sharedInstance] pause];
    _isplayer = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - action
- (void)clickSingleButton: (UIButton *)sender {
    self.flag = YES;
}

- (void)clickMulButton: (UIButton *)sender {
    self.flag = NO;
}

- (void)sliderValueChanged: (UISlider *)sender {
    [self reloadValue:sender];
}
-(void)reloadValue:(UISlider *)sender{
    _currentValue = 1-sender.value/100;
    if(_currentValue<0.2){
        _currentValue = 0.2;
    }
}
- (void)clickPowerButton: (UIButton *)sender {
    NSData *sendData;
    NSString *name;
    if (_on) {
        name = @"power_off.png";
        sendData = [[CMDModel sharedInstance] powerOff];
    }
    else {
        name = @"power_on.png";
        sendData = [[CMDModel sharedInstance] powerOn];
    }
    _on = !_on;
    [[BlueServerManager sharedInstance] sendData:sendData];
}
- (void)onChanged: (NSNotification *)noti {
    NSNumber *temp = noti.userInfo[@"on"];
    BOOL flag = temp.boolValue;
    NSString *name;
    name = flag ? @"power_on.png" : @"power_off.png";
    [_rightButton setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    
}
- (void)colorChanged: (NSNotification *)noti {
    id obj = noti.userInfo[@"color"];
    if ([obj isKindOfClass:[UIColor class]]) {
        UIColor *color = (UIColor *)obj;
        self.singleButton.backgroundColor = color;
    }
}

#pragma mark - VoiceHelperDelegate
- (void)volumeDidChanged:(double)volume{
    if (!_isplayer){
        if (volume<_currentValue){
            volume = 0;
        }
        NSInteger temp = (NSInteger)((volume * _element_height) * 1.5);
        _frequencyView.volume = temp;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *sendData;
            if (_flag) {
                sendData = [[CMDModel sharedInstance] singleMusicCMD:volume];
            }
            else {
                sendData = [[CMDModel sharedInstance] musicCMD:volume];
            }
            [[BlueServerManager sharedInstance] sendData:sendData];
        });
        
        
    }
}
#pragma mark - private
- (void)configSelf {
    //self.view.backgroundColor = [UIColor colorWithRed:1.0 / 255 green:1.0 / 255 blue:51.0 / 255 alpha:0.9];
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _showScrollView.contentSize.height)];
    backImageView.image = [UIImage imageNamed:@"backgroud.jpg"];
    [_showScrollView insertSubview:backImageView atIndex:0];
    self.flag = NO;
    _element_height = 240;
}
- (void)configSubview {
    [_showScrollView addSubview:self.singleButton];
    [_showScrollView addSubview:self.mulButton];
    //[self.view addSubview:self.singleLabel];
    //[self.view addSubview:self.mulLabel];
    [_showScrollView addSubview:self.sensitivityLabel];
    [_showScrollView addSubview:self.sensitivitySlider];
    CGRect frame = self.frequencyView.frame;
    frame.origin.y = _showScrollView.contentSize.height-self.frequencyView.frame.size.height;
    self.frequencyView.frame = frame;
    [_showScrollView addSubview:self.frequencyView];
}

#pragma mark - getter
- (UIButton *)singleButton {
    if (!_singleButton) {
        _singleButton = [UIButton new];
        CGRect frame;
        frame.size = BUTTON_SIZE;
        frame.origin.x = 0.5 * (SCREEN_WIDTH - button_margin) - CGRectGetWidth(frame);
        frame.origin.y = 120;
        _singleButton.frame = frame;
        //[_singleButton setBackgroundImage:[UIImage imageNamed:@"b3.png"] forState:UIControlStateNormal];
        _singleButton.backgroundColor = [UIColor redColor];
        [_singleButton addTarget:self action:@selector(clickSingleButton:) forControlEvents:UIControlEventTouchUpInside];
        _singleButton.layer.cornerRadius = 15;
        _singleButton.layer.masksToBounds = YES;
    }
    return _singleButton;
}

- (UIButton *)mulButton {
    if (!_mulButton) {
        _mulButton = [UIButton new];
        CGRect frame;
        frame.size = BUTTON_SIZE;
        frame.origin.x = 0.5 * (SCREEN_WIDTH + button_margin);
        frame.origin.y = CGRectGetMinY(self.singleButton.frame);
        _mulButton.frame = frame;
        [_mulButton setBackgroundImage:[UIImage imageNamed:@"mulColor.png"] forState:UIControlStateNormal];
        [_mulButton addTarget:self action:@selector(clickMulButton:) forControlEvents:UIControlEventTouchUpInside];
        _mulButton.layer.cornerRadius = 15;
        _mulButton.layer.masksToBounds = YES;
    }
    return _mulButton;
}

- (UILabel *)singleLabel {
    if (!_singleLabel) {
        _singleLabel = [UILabel new];
        CGRect frame = self.singleButton.frame;
        frame.origin.y = CGRectGetMaxY(frame) - 10;
        frame.size.height = 30;
        _singleLabel.frame = frame;
        _singleLabel.text = @"单色频闪";
        _singleLabel.textColor = [UIColor whiteColor];
        _singleLabel.font = [UIFont systemFontOfSize:10];
    }
    return _singleLabel;
}

- (UILabel *)mulLabel {
    if (!_mulLabel) {
        _mulLabel = [UILabel new];
        CGRect frame = self.mulButton.frame;
        frame.origin.y = CGRectGetMaxY(frame) - 10;
        frame.size.height = 30;
        _mulLabel.frame = frame;
        _mulLabel.text = @"七彩换色";
        _mulLabel.textColor = [UIColor whiteColor];
        _mulLabel.font = [UIFont systemFontOfSize:10];
    }
    return _mulLabel;
}

- (UILabel *)sensitivityLabel {
    if (!_sensitivityLabel) {
        _sensitivityLabel = [UILabel new];
        CGRect frame;
        frame.origin.x = slider_margin;
        frame.origin.y = CGRectGetMaxY(self.mulLabel.frame) + 30;
        _sensitivityLabel.frame = frame;
        _sensitivityLabel.text = NSLocalizedString(@"sensitivity", nil);
        _sensitivityLabel.textColor = [UIColor whiteColor];
        _sensitivityLabel.font = [UIFont systemFontOfSize:14];
        [_sensitivityLabel sizeToFit];
        
    }
    return _sensitivityLabel;
}

- (UISlider *)sensitivitySlider {
    if (!_sensitivitySlider) {
        _sensitivitySlider = [UISlider new];
        CGRect frame = self.sensitivityLabel.frame;
        frame.origin.x = CGRectGetMaxX(frame) + slider_margin;
        frame.size.width = SCREEN_WIDTH - CGRectGetMinX(frame) - slider_margin;
        frame.size.height = 20;
        _sensitivitySlider.frame = frame;
        CGPoint center = _sensitivitySlider.center;
        center.y = _sensitivityLabel.center.y;
        _sensitivitySlider.center = center;
        [_sensitivitySlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _sensitivitySlider.minimumValue = min_height;
        _sensitivitySlider.maximumValue = max_height;
        _sensitivitySlider.value = 0.5 * (min_height + max_height);
        if (ISTOTAKEEFFECT) {
            _sensitivitySlider.minimumTrackTintColor = THETIMECOLOR;
        }
        [self reloadValue:_sensitivitySlider];
        //_element_height = _sensitivitySlider.value;
        
    }
    return _sensitivitySlider;
}
-(FrequencyView *)frequencyView {
    if (!_frequencyView) {
        _frequencyView = [FrequencyView new];
    }
    return _frequencyView;
}
#pragma mark - setter
- (void)setFlag:(BOOL)flag{
    _flag = flag;
    if (flag) {
        [self.singleButton setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
        [self.mulButton setImage:[UIImage new] forState:UIControlStateNormal];
    }
    else {
        [self.singleButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
        [self.mulButton setImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
    }
}

@end
