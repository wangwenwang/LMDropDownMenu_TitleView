//
//  MainViewController.m
//  LMDropDownMenuDemo
//
//  Created by 凯东源 on 2017/9/15.
//  Copyright © 2017年 LMfu. All rights reserved.
//

#import "MainViewController.h"
#import "LMTitleView.h"


@interface MainViewController ()<LMTitleViewDataSource, LMTitleViewDelegate>

@property (strong, nonatomic) LMTitleView *lmTitleView;

@property (strong, nonatomic) NSArray *menuTexts;

@end

@implementation MainViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"主页";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _lmTitleView = [[LMTitleView alloc] initLMTitleView:self andUINavigationItem:self.navigationItem];
    _lmTitleView.dataSource = self;
    _lmTitleView.dalegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _menuTexts = @[@"全部", @"出库", @"入库"];
    _lmTitleView.titleText = _menuTexts[0];
    _lmTitleView.menuCount = _menuTexts.count;
}


#pragma mark - LMTitleViewDataSource

- (NSString *)menu:(LMTitleView *)menu titleForRowAtIndexPath:(NSUInteger)indexPath_row {
    
    return _menuTexts[indexPath_row];
}


#pragma mark - LMTitleViewDelegate

- (void)menu:(LMTitleView *)menu didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _lmTitleView.titleText = _menuTexts[indexPath.row];
}


#pragma mark - 事件

// 点击Cell
- (void)LMTitleViewOnclick {
    
    [_lmTitleView LMTitleViewOnclick];
}


// 点击灰色区域取消
- (void)LMTitleViewCoverOnclick {
    
    [_lmTitleView LMTitleViewCoverOnclick];
}

@end
