//
//  NewColorViewController.m
//  pro
//
//  Created by Baird-weng on 2017/1/16.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "NewColorViewController.h"
#import "HeaderView.h"
@interface NewColorViewController ()

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
    [self.view addSubview:headerView];
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
