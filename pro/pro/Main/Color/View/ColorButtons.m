//
//  ColorButtons.m
//  pro
//
//  Created by Baird-weng on 2017/1/17.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "ColorButtons.h"

@implementation ColorButtons
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        CGSize size = CGSizeMake(20, 25);
        self.backgroundColor = [UIColor blackColor];
        UIColor *pick = [UIColor colorWithRed:1.0 green:0 blue:1.0 alpha:1.0];
        UIColor *lowblue = [UIColor colorWithRed:0 green:1.0 blue:1.0 alpha:1.0];
        NSArray *Colors = @[[UIColor redColor], [UIColor blueColor], [UIColor greenColor], pick, [UIColor yellowColor], lowblue, [UIColor whiteColor]];
        CGFloat Jg = (self.frame.size.width - size.width*[Colors count])/([Colors count]-1);
        CGFloat btn_y = (self.frame.size.height-size.height)/2;
        for (int i = 0; i<[Colors count]; i++){
            CGRect frame = CGRectMake((size.width+Jg)*i, btn_y, size.width, size.height);
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = Colors[i];
            btn.frame = frame;
            [self addSubview:btn];
        }
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
