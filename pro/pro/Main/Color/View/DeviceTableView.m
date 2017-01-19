//
//  DeviceTableView.m
//  pro
//
//  Created by Baird-weng on 2017/1/19.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import "DeviceTableView.h"
@interface DeviceTableView()<UITableViewDelegate,UITableViewDataSource>{
    selectIndexBlock _block;
}
@end
@implementation DeviceTableView
-(void)setDataSoureArray:(NSArray *)dataSoureArray{
    _dataSoureArray = dataSoureArray;
    [self reloadData];
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        self.dataSource = self;
        self.delegate = self;
        self.backgroundColor = [UIColor colorWithRed:17.0 / 255 green:18.0 / 255 blue:67.0 / 255 alpha:0.75];
    }
    return self;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSoureArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CBPeripheral *Peripheral = self.dataSoureArray[indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@#%@",Peripheral.name,Peripheral.identifier.UUIDString];
    NSArray<NSString *> *strings = [text componentsSeparatedByString:@"#"];
    if (strings && strings.count >= 1) {
        cell.textLabel.text = strings[0];
        cell.detailTextLabel.text = strings[1];
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    return cell;
}
-(void)GetselectIndexBlock:(selectIndexBlock)block{
    _block = block;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_block) {
        _block(_dataSoureArray[indexPath.row]);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
