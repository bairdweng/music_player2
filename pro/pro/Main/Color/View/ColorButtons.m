//
//  ColorButtons.m
//  pro
//
//  Created by Baird-weng on 2017/1/17.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "ColorButtons.h"
#import "CMDModel.h"
#import "BlueServerManager.h"


@interface ColorButtons(){
    NSArray *_Colors;
    ColorButtonsEventBlock _block;
}
@end


@implementation ColorButtons
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        CGSize size = CGSizeMake(20, 40);
        UIColor *pick = [UIColor colorWithRed:1.0 green:0 blue:1.0 alpha:1.0];
        UIColor *lowblue = [UIColor colorWithRed:0 green:1.0 blue:1.0 alpha:1.0];
        _Colors = @[[UIColor redColor], [UIColor blueColor], [UIColor greenColor], pick, [UIColor yellowColor], lowblue, [UIColor whiteColor]];
        CGFloat Jg = (self.frame.size.width - size.width*[_Colors count])/([_Colors count]-1);
        CGFloat btn_y = (self.frame.size.height-size.height)/2;
        for (int i = 0; i<[_Colors count]; i++){
            CGRect frame = CGRectMake((size.width+Jg)*i, btn_y, size.width, size.height);
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
            btn.tag = i+100;
            [btn addTarget:self action:@selector(ClickOntheBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = _Colors[i];
            btn.frame = frame;
            [self addSubview:btn];
        }
    }
    return self;
}
-(void)ClickOntheBtn:(UIButton *)sender{
    for (int i = 0; i<[_Colors count]; i++) {
        UIButton *btn = [self viewWithTag:100+i];
        if (btn == sender) {
            btn.selected = YES;
        }
        else{
            btn.selected = NO;
        }
    }
    if (_block) {
        _block(sender.tag-100);
    }
}
//按钮复位。
-(void)reset{
    for (int i = 0; i<[_Colors count]; i++) {
        UIButton *btn = [self viewWithTag:100+i];
        btn.selected = NO;
    }
}
-(void)setBtnSelectIndex:(NSInteger)btnSelectIndex{
    _btnSelectIndex = btnSelectIndex;
    UIButton *btn = [self viewWithTag:100+_btnSelectIndex];
    [self ClickOntheBtn:btn];
}
-(void)getEventBlck:(ColorButtonsEventBlock)block{
    _block = block;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
