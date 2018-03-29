//
//  ViewController.m
//  PopSelectView
//
//  Created by MenThu on 2018/3/29.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "ViewController.h"
#import "PopSelectView.h"

@interface ViewController ()

@property (nonatomic, strong) PopSelectView *selectView;
@property (nonatomic, assign) NSInteger selectIndex;
@property (weak, nonatomic) IBOutlet UIView *indicatorView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectView = [[PopSelectView alloc] init];
    self.selectIndex = 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    __weak typeof(self) weakSelf = self;
    [self.selectView showWithTitle:@[@"测试1", @"测试2", @"测试3"] defautSelectIndex:self.selectIndex blowCenterOfView:self.indicatorView pointOffset:CGPointMake(10, 3) clickCallBack:^(NSInteger clickIndex) {
        NSLog(@"clickIndex=[%ld]", (long)clickIndex);
        weakSelf.selectIndex = clickIndex;
    }];
}


@end
