//
//  BLSliderView.m
//  pro
//
//  Created by Baird-weng on 2017/1/17.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "BLSliderView.h"
#import "BlueServerManager.h"
#import "CMDModel.h"

@interface BLSliderView(){
    int _templeIndex;
    UISlider *_slider_1;
    UISlider *_slider_2;
}

@end

@implementation BLSliderView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        UIImageView *imageView_1 = [[UIImageView alloc]init];
        [imageView_1 setImage:[UIImage imageNamed:@"brightness"]];
        [self addSubview:imageView_1];
        
        
        
        UIImageView *imageView_2 = [[UIImageView alloc]init];
        [imageView_2 setImage:[UIImage imageNamed:@"twink"]];
        [self addSubview:imageView_2];
        
        
        [imageView_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(80/2));
            make.left.top.equalTo(@0);
        }];
        
        [imageView_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(80/2));
            make.centerX.equalTo(imageView_1);
            make.top.equalTo(imageView_1.mas_bottom).offset(5);
        }];
        
        
        _slider_1 = [UISlider new];
        [_slider_1 addTarget:self action:@selector(lightValueChanged:) forControlEvents:UIControlEventValueChanged];
        _slider_1.minimumTrackTintColor = THETIMECOLOR;
        [self addSubview:_slider_1];
        [_slider_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView_1.mas_right).offset(10);
            make.centerY.equalTo(imageView_1);
            make.right.equalTo(self.mas_right).offset(-15);
        }];
        
        _slider_2 = [UISlider new];
        [_slider_2 addTarget:self action:@selector(frequencyValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_slider_2];
        _slider_2.minimumTrackTintColor = THETIMECOLOR;
        [_slider_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView_2.mas_right).offset(10);
            make.centerY.equalTo(imageView_2);
            make.right.equalTo(self.mas_right).offset(-15);
        }];
        
    }
    return self;
}
//闪烁。
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
-(void)setSliderValue1:(double)SliderValue1{
    _SliderValue1 = SliderValue1;
    [_slider_1 setValue:_SliderValue1 animated:YES];
}
-(void)setSliderValue2:(double)SliderValue2{
    _SliderValue1 = SliderValue2;
    [_slider_2 setValue:SliderValue2 animated:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
