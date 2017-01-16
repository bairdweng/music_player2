//
//  HeaderView.m
//  pro
//
//  Created by Baird-weng on 2017/1/16.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "HeaderView.h"


@interface HeaderView()
@property(nonatomic,weak)UILabel *titleLabel;
@end


@implementation HeaderView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor colorWithHexString:@"282828"];
        UIImageView *logoImage = [[UIImageView alloc]init];
        [logoImage setImage:[UIImage imageNamed:@"logo3"]];
        [self addSubview:logoImage];
        [logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.top.equalTo(@5);
            make.width.height.equalTo(@40);
        }];
        
        UILabel *titleLable = [[UILabel alloc]init];
        titleLable.text = @"LED Control";
        titleLable.textColor = [UIColor whiteColor];
        [self addSubview:titleLable];
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(logoImage.mas_right).offset(5);
            make.centerY.equalTo(logoImage);
        }];
        self.titleLabel = titleLable;
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor blackColor];
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.equalTo(@0);
            make.height.equalTo(@1.5);
            make.bottom.equalTo(self);
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
