//
//  BLSliderView.m
//  pro
//
//  Created by Baird-weng on 2017/1/17.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "BLSliderView.h"

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
        
        
        UISlider *slider_1 = [UISlider new];
        slider_1.minimumTrackTintColor = THETIMECOLOR;
        [self addSubview:slider_1];
        [slider_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView_1.mas_right).offset(10);
            make.centerY.equalTo(imageView_1);
            make.right.equalTo(self.mas_right).offset(-15);
        }];
        
        UISlider *slider_2 = [UISlider new];
        [self addSubview:slider_2];
        slider_2.minimumTrackTintColor = THETIMECOLOR;
        [slider_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView_2.mas_right).offset(10);
            make.centerY.equalTo(imageView_2);
            make.right.equalTo(self.mas_right).offset(-15);
        }];
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
