//
//  EFCircularSliderView.m
//  pro
//
//  Created by Baird-weng on 2017/1/17.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "EFCircularSliderView.h"
#import "EFCircularSlider.h"
#import "CMDModel.h"
#import "BlueServerManager.h"
@interface EFCircularSliderView(){
    UIView *_centerView;
    EFCircularSlider *_circularSlider;
    EFCircularSliderViewEventBlock _eventBlock;
}
@end


@implementation EFCircularSliderView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        
        UIImageView *imageView = [UIImageView new];
        CGRect frame = self.bounds;
        imageView.frame = frame;
        imageView.image = [UIImage imageNamed:@"a16"];
        [self addSubview:imageView];
        CGFloat width = self.frame.size.width-20;
        
        _circularSlider = [[EFCircularSlider alloc]initWithFrame:CGRectMake((self.frame.size.width-width)/2, (self.frame.size.height-width)/2, width, width)];
        [_circularSlider addTarget:self action:@selector(circularSlidervalueChanged:) forControlEvents:UIControlEventValueChanged];
        _circularSlider.handleType = bigCircle;
        _circularSlider.minimumValue = 0;
        _circularSlider.maximumValue = 1;
        _circularSlider.lineWidth = 20;
        _circularSlider.currentValue = 0;
        _circularSlider.handleColor = THETIMECOLOR;
        [self addSubview:_circularSlider];
        
        CGFloat point_width = 80;
        UIView *centerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, point_width, point_width)];
        centerView.backgroundColor = [UIColor redColor];
        centerView.layer.borderWidth = 5;
        centerView.layer.borderColor = [UIColor blackColor].CGColor;
        centerView.layer.cornerRadius = centerView.frame.size.width/2;
        centerView.layer.masksToBounds = YES;
        centerView.center = _circularSlider.center;
        [self addSubview:centerView];
        _centerView = centerView;
    }
    return self;
}

-(void)circularSlidervalueChanged:(EFCircularSlider *)SliderView{
    static int temp;
    if (temp == SliderView.currentValue * 1422) {
        return;
    }
    temp = SliderView.currentValue * 1422;
    UIColor *color = [[CMDModel sharedInstance] singleColor:temp];
    _centerView.backgroundColor = color;
    
    NSData *sendData = [[CMDModel sharedInstance] singleColorCMD:temp];
    //NSLog(@"send data");
    [[BlueServerManager sharedInstance] sendData:sendData];
    if (_eventBlock) {
        _eventBlock(SliderView.currentValue);
    }
}
-(void)setCurrentValue:(float)currentValue{
    _currentValue = currentValue;
    int angle = 0;
    float value = _currentValue;
    if(value > 0 && value < 0.25) {
        angle = - (int)(value * 360);
    }
    else {
        angle = (int)(360 - value * 360);
    }
    _circularSlider.currentValue = _currentValue;
    [_circularSlider setPosition:angle];
    [self circularSlidervalueChanged:_circularSlider];
    
}
-(void)getEventBlck:(EFCircularSliderViewEventBlock)block{
    _eventBlock = block;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
