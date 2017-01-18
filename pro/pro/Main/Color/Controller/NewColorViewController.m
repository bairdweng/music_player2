//
//  NewColorViewController.m
//  pro
//
//  Created by Baird-weng on 2017/1/16.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "NewColorViewController.h"
#import "HeaderView.h"
#import "EFCircularSlider.h"
#import "EFCircularSliderView.h"
#import "ColorButtons.h"
#import "BLSliderView.h"
#import "ControBtnView.h"
@interface NewColorViewController (){
    UIScrollView *_showScrollView;
}
@end

@implementation NewColorViewController
- (instancetype)init {
    if (self = [super init]) {
        //self.title = @"color";
        UIImage *image_1 = [UIImage imageNamed:@"tab_color"];
        image_1 = [image_1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *image_2 = [UIImage imageNamed:@"tab_color_select"];
        image_2 = [image_2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:image_1 selectedImage:image_2];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"282828"];
    HeaderView *headerView = [[HeaderView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 55)];
    headerView.title = @"LED Control";
    [self.view addSubview:headerView];
    
    _showScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-48)];
    CGFloat content = _showScrollView.frame.size.height;
    if (self.view.frame.size.height==480) {
        content = 500;
    }
    _showScrollView.contentSize = CGSizeMake(self.view.frame.size.width, content);
    [self.view addSubview:_showScrollView];
    
    CGFloat View_JG = 5;
    
    CGFloat floatY = CGRectGetMaxY(headerView.frame);
    CGFloat size_size = SCREEN_WIDTH * 0.78;
    EFCircularSliderView *CircularSliderView = [[EFCircularSliderView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-size_size)/2, floatY, size_size, size_size)];
    [_showScrollView addSubview:CircularSliderView];
    
    
    
    CGFloat colorButton_Width = SCREEN_WIDTH * 0.9;
    CGFloat ButtonView_Y = CGRectGetMaxY(CircularSliderView.frame)+View_JG;
    ColorButtons *ButtonView = [[ColorButtons alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-colorButton_Width)/2, ButtonView_Y, colorButton_Width, 50)];
    [_showScrollView addSubview:ButtonView];
    
    
    CGFloat SliderView_Width = SCREEN_WIDTH * 0.95;
    CGFloat SliderView_Y = CGRectGetMaxY(ButtonView.frame)+View_JG;
    BLSliderView *SliderView = [[BLSliderView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-SliderView_Width)/2, SliderView_Y, SliderView_Width, 100)];
    [_showScrollView addSubview:SliderView];
    
    
    CGFloat ControBtn_Width = SCREEN_WIDTH * 0.95;
    CGFloat ControBtn_Y = CGRectGetMaxY(SliderView.frame)+View_JG;
    
    
    ControBtnView *controBtnView = [[ControBtnView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-SliderView_Width)/2, ControBtn_Y, ControBtn_Width, 100)];
    [_showScrollView addSubview:controBtnView];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
