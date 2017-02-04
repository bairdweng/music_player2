//
//  ControBtnView.m
//  pro
//
//  Created by Baird-weng on 2017/1/17.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "ControBtnView.h"
#import "BlueServerManager.h"
#import "CMDModel.h"
@implementation ControBtnView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        UILabel *lable_1 = [UILabel new];
        lable_1.text = NSLocalizedString(@"strobe", nil);;

        lable_1.textColor = THETIMECOLOR;
        lable_1.textAlignment = 1;
        [self addSubview:lable_1];
        
        UILabel *lable_2 = [UILabel new];
        lable_2.textColor = THETIMECOLOR;
        lable_2.text = NSLocalizedString(@"plusating", nil);;
        lable_2.textAlignment = 1;
        [self addSubview:lable_2];
        [lable_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.5);
        }];
        
        [lable_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.5);
        }];
        
        
        UIButton *btn_1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn_1 setImage:[UIImage imageNamed:@"f2"] forState:UIControlStateNormal];
        [self addSubview:btn_1];
        
        UIButton *btn_2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn_2 setImage:[UIImage imageNamed:@"newf3"] forState:UIControlStateNormal];
        [self addSubview:btn_2];
        
        UIButton *btn_3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn_3 setImage:[UIImage imageNamed:@"f2"] forState:UIControlStateNormal];
        [self addSubview:btn_3];
        
        UIButton *btn_4 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn_4 setImage:[UIImage imageNamed:@"newf3"] forState:UIControlStateNormal];
        [self addSubview:btn_4];
        
        btn_1.tag = 200;
        [btn_1 addTarget:self action:@selector(ClickOntheController:) forControlEvents:UIControlEventTouchUpInside];
        
        btn_2.tag = 201;
        [btn_2 addTarget:self action:@selector(ClickOntheController:) forControlEvents:UIControlEventTouchUpInside];
        
        btn_3.tag = 202;
        [btn_3 addTarget:self action:@selector(ClickOntheController:) forControlEvents:UIControlEventTouchUpInside];
        
        btn_4.tag = 203;
        [btn_4 addTarget:self action:@selector(ClickOntheController:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@50);
            make.top.equalTo(lable_1.mas_bottom).offset(10);
            make.centerX.equalTo(lable_1).offset(-30);
        }];
        
        [btn_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@50);
            make.centerY.equalTo(btn_1);
            make.centerX.equalTo(lable_1).offset(30);
        }];
        
        
        [btn_3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@50);
            make.top.equalTo(lable_2.mas_bottom).offset(10);
            make.centerX.equalTo(lable_2).offset(-30);
        }];
        
        [btn_4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@50);
            make.centerY.equalTo(btn_1);
            make.centerX.equalTo(lable_2).offset(30);
        }];
    }
    return self;
}


-(void)ClickOntheController:(UIButton *)sender{
    for (int i = 0; i<4; i++) {
        UIButton *btn = [self viewWithTag:i+200];
        btn.layer.cornerRadius = 25;
        btn.layer.masksToBounds = YES;
        if (sender == btn) {
            btn.backgroundColor = THETIMECOLOR;
        }
        else{
            btn.backgroundColor = [UIColor clearColor];
        }
    }
    NSInteger index = sender.tag - 200;
    CMDModel *cmd = [CMDModel sharedInstance];
    NSData *sendData;
    
    switch (index) {
        case 0:{
            sendData = cmd.threeBlinkCMD;//单色闪烁
        }
            break;
        case 1:{
            sendData = cmd.sevenBlinkCMD;//多彩闪烁。
        }
            break;
        case 2:{
            sendData = cmd.threeBreathCMD;//单色渐变。
        }
            break;
        case 3:{
            sendData = cmd.sevenBreathCMD;//多彩渐变。
        }
            break;
            
        default:
            break;
    }
    [BlueServerManager sharedInstance].mode = index;
    [[BlueServerManager sharedInstance] sendData:sendData];
}

-(void)setControMode:(NSInteger)controMode{
    _controMode = controMode;
    UIButton *btn = [self viewWithTag:_controMode+200];
    [self ClickOntheController:btn];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
