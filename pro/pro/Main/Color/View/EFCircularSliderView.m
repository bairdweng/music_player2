//
//  EFCircularSliderView.m
//  pro
//
//  Created by Baird-weng on 2017/1/17.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "EFCircularSliderView.h"
#import "EFCircularSlider.h"
@implementation EFCircularSliderView


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        UIImageView *imageView = [UIImageView new];
        CGRect frame = self.bounds;
        imageView.frame = frame;
        imageView.image = [UIImage imageNamed:@"a16"];
        [self addSubview:imageView];
        CGFloat width = self.frame.size.width-70;
        EFCircularSlider *circularSlider = [[EFCircularSlider alloc]initWithFrame:CGRectMake((self.frame.size.width-width)/2, (self.frame.size.height-width)/2, width, width)];
        [circularSlider addTarget:self action:@selector(circularSlidervalueChanged:) forControlEvents:UIControlEventValueChanged];
        circularSlider.handleType = bigCircle;
        circularSlider.minimumValue = 0;
        circularSlider.maximumValue = 1;
        circularSlider.currentValue = 0;
        circularSlider.lineWidth = 20;
        circularSlider.handleColor = THETIMECOLOR;
        [self addSubview:circularSlider];
        
        
        CGFloat point_width = 80;
        UIView *centerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, point_width, point_width)];
        centerView.backgroundColor = [UIColor redColor];
        centerView.layer.borderWidth = 5;
        centerView.layer.borderColor = [UIColor blackColor].CGColor;
        centerView.layer.cornerRadius = centerView.frame.size.width/2;
        centerView.layer.masksToBounds = YES;
        centerView.center = circularSlider.center;
        [self addSubview:centerView];
    }
    return self;
}

-(void)circularSlidervalueChanged:(EFCircularSliderView *)SliderView{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
