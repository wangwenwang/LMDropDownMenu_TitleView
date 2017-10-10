//
//  LMTitleView.m
//  LMDropDownMenuDemo
//
//  Created by 凯东源 on 2017/9/18.
//  Copyright © 2017年 LMfu. All rights reserved.
//

#import "LMTitleView.h"

#pragma mark - TitleView

@interface TitleView : UIView

@property (assign, nonatomic) BOOL selected;

@end

@implementation TitleView

@end


#pragma mark - LMTitleView

@interface LMTitleView ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) TitleView *titleView;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) CAShapeLayer *indicator;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UIView *coverView;

@end

@implementation LMTitleView


#pragma mark initUI

- (instancetype)initLMTitleView:(UIViewController *)vc andUINavigationItem:(UINavigationItem *)navigationItem {
    
    // self
    self = [self initWithFrame:CGRectMake(0, 0, 80, 40)];
    
    if(self) {
        
        // TitleView
        _titleView = [[TitleView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        navigationItem.titleView = _titleView;
        
        // 手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(LMTitleViewOnclick)];
        tap.numberOfTapsRequired = 1;
        [_titleView addGestureRecognizer:tap];
        
        // label
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_titleView.frame), CGRectGetHeight(_titleView.frame))];
        [_titleLabel setFont:[UIFont systemFontOfSize:17]];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleView addSubview:_titleLabel];
        
        // cover
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0;
        [vc.view addSubview:_coverView];
        
        // 手势
        UITapGestureRecognizer *tap_cover = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(LMTitleViewCoverOnclick)];
        tap_cover.numberOfTapsRequired = 1;
        [_coverView addGestureRecognizer:tap_cover];
        
        // TableView
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, 0)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [vc.view addSubview:_tableView];
        
        // indicator
        CGFloat textLayerInterval = self.frame.size.width / ( 1 * 2);
        CGPoint titlePosition = CGPointMake(textLayerInterval, self.frame.size.height / 2);
        CAShapeLayer *indicator = [self createIndicatorWithColor:[UIColor blackColor] andPosition:CGPointMake(titlePosition.x + _titleLabel.bounds.size.width / 2 + 8, self.frame.size.height / 2)];
        indicator.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blueColor]);
        _indicator = indicator;
        [_titleView.layer addSublayer:indicator];
    }
    return self;
}


#pragma mark - animation method

- (void)animateIndicator:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)())complete {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    complete();
}


- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(4, 5)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.fillColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    
    CGPathRelease(bound);
    
    layer.position = point;
    
    return layer;
}


#pragma mark - 手势

- (void)LMTitleViewOnclick {
    
    _titleView.selected = !_titleView.selected;
    
    [self animateBackGroundView:nil show:_titleView.selected complete:^{
        
        [self animateIndicator:_indicator Forward:_titleView.selected complete:^{
            
        }];
    }];
    
    NSLog(@"fds");
}


- (void)LMTitleViewCoverOnclick {
    
    _titleView.selected = NO;
    [self animateBackGroundView:nil show:_titleView.selected complete:^{
        
        [self animateIndicator:_indicator Forward:_titleView.selected complete:^{
            
        }];
    }];
}


- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    
    if(show) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect rect = _tableView.frame;
            rect.size.height = 44 * _menuCount;
            [_tableView setFrame:rect];
            _coverView.alpha = 0.3;
        }];
    } else {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect rect = _tableView.frame;
            rect.size.height = 0;
            [_tableView setFrame:rect];
            _coverView.alpha = 0;
        }];
    }
    complete();
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _menuCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellid = @"fds";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    
    if(!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, cell.frame.size.height);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    if ([self.dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)]) {
        
        titleLabel.text = [self.dataSource menu:self titleForRowAtIndexPath:indexPath.row];
    }
    
    [cell addSubview:titleLabel];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _titleView.selected = NO;
    
    [self animateBackGroundView:nil show:_titleView.selected complete:^{
        
        [self animateIndicator:_indicator Forward:_titleView.selected complete:^{
            
        }];
    }];
    
    if([_dataSource respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
        
        [_dalegate menu:self didSelectRowAtIndexPath:indexPath];
    }
}


#pragma mark - SET方法

- (void)setTitleText:(NSString *)titleText {
    
    _titleLabel.text = titleText;
}

@end
