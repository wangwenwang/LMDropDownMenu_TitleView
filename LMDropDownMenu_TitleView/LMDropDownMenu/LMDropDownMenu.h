//
//  LMDropDownMenu.h
//  LMDropDownMenu
//
//  Created by LM on 17-9-12.
//  Copyright (c) 2017年 LMfu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

@interface LMIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;
// 0 左边   1 右边
@property (nonatomic, assign) NSInteger leftOrRight;
// 左边行
@property (nonatomic, assign) NSInteger leftRow;
// 右边行
@property (nonatomic, assign) NSInteger row;

- (instancetype)initWithColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow row:(NSInteger)row;
+ (instancetype)indexPathWithCol:(NSInteger)col leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow row:(NSInteger)row;

@end

#pragma mark - data source protocol
@class LMDropDownMenu;

@protocol LMDropDownMenuDataSource <NSObject>

@required
- (NSInteger)menu:(LMDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow;
- (NSString *)menu:(LMDropDownMenu *)menu titleForRowAtIndexPath:(LMIndexPath *)indexPath;
- (NSString *)menu:(LMDropDownMenu *)menu titleForColumn:(NSInteger)column;
/**
 * 表视图显示时，是否需要两个表显示
 */
- (BOOL)haveRightTableViewInColumn:(NSInteger)column;

/**
 * 返回当前菜单左边表选中行
 */
- (NSInteger)currentLeftSelectedRow:(NSInteger)column;

@optional
//default value is 1
- (NSInteger)numberOfColumnsInMenu:(LMDropDownMenu *)menu;

@end

#pragma mark - delegate
@protocol LMDropDownMenuDelegate <NSObject>
@optional
- (void)menu:(LMDropDownMenu *)menu didSelectRowAtIndexPath:(LMIndexPath *)indexPath;
@end

#pragma mark - interface
@interface LMDropDownMenu : UIView <UITableViewDataSource, UITableViewDelegate >

@property (nonatomic, weak) id <LMDropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id <LMDropDownMenuDelegate> delegate;

@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *separatorColor;
/**
 *  the width of menu will be set to screen width defaultly
 *
 *  @param origin the origin of this view's frame
 *  @param height menu's height
 *
 *  @return menu
 */
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;
- (NSString *)titleForRowAtIndexPath:(LMIndexPath *)indexPath;


- (void)titleViewOnclick;

@end
