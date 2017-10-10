//
//  LMTitleView.h
//  LMDropDownMenuDemo
//
//  Created by 凯东源 on 2017/9/18.
//  Copyright © 2017年 LMfu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LMTitleView;



@protocol LMTitleViewDataSource <NSObject>

@required
- (NSString *)menu:(LMTitleView *)menu titleForRowAtIndexPath:(NSUInteger)indexPath_row;

@end


@protocol LMTitleViewDelegate <NSObject>

@optional
- (void)menu:(LMTitleView *)menu didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface LMTitleView : UIView

- (instancetype)initLMTitleView:(UIViewController *)vc andUINavigationItem:(UINavigationItem *)navigationItem;


- (void)LMTitleViewOnclick;

- (void)LMTitleViewCoverOnclick;

@property (copy, nonatomic) NSString *titleText;

@property (assign, nonatomic) NSInteger menuCount;

@property (nonatomic, weak) id <LMTitleViewDataSource> dataSource;

@property (nonatomic, weak) id <LMTitleViewDelegate> dalegate;

@end
