//
//  LMDropDownMenu.m
//  LMDropDownMenu
//
//  Created by LM on 17-9-12.
//  Copyright (c) 2017年 LMfu. All rights reserved.
//

#import "LMDropDownMenu.h"

#define BackColor [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0]
// 选中颜色加深
#define SelectColor [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0]

@interface NSString (Size)

- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end

@implementation NSString (Size)

- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize textSize;
    if (CGSizeEqualToSize(size, CGSizeZero))
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        
        textSize = [self sizeWithAttributes:attributes];
    }
    else
    {
        NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        //NSStringDrawingTruncatesLastVisibleLine如果文本内容超出指定的矩形限制，文本将被截去并在最后一个字符后加上省略号。 如果指定了NSStringDrawingUsesLineFragmentOrigin选项，则该选项被忽略 NSStringDrawingUsesFontLeading计算行高时使用行间距。（字体大小+行间距=行高）
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        CGRect rect = [self boundingRectWithSize:size
                                         options:option
                                      attributes:attributes
                                         context:nil];
        
        textSize = rect.size;
    }
    return textSize;
}

@end


@interface LMTableViewCell : UITableViewCell

@property(nonatomic,readonly) UILabel *cellTextLabel;
@property(nonatomic,strong) UIImageView *cellAccessoryView;

-(void)setCellText:(NSString *)text align:(NSString*)align;

@end

@implementation LMTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _cellTextLabel = [[UILabel alloc] init];
        _cellTextLabel.textAlignment = NSTextAlignmentCenter;
        _cellTextLabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:_cellTextLabel];
    }
    return self;
}

-(void)setCellText:(NSString *)text align:(NSString*)align{
    
    _cellTextLabel.text = text;
    // 只取宽度
    CGSize textSize = [text textSizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(MAXFLOAT, 14) lineBreakMode:NSLineBreakByWordWrapping];
    //    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(MAXFLOAT, 14)];
    
    CGFloat marginX = 20;
    
    if (![@"left" isEqualToString:align]) {
        marginX = (self.frame.size.width-textSize.width)/2;
    }
    
    _cellTextLabel.frame = CGRectMake(marginX, 0, textSize.width, self.frame.size.height);
    
    if(_cellAccessoryView){
        _cellAccessoryView.frame = CGRectMake(_cellTextLabel.frame.origin.x+_cellTextLabel.frame.size.width+10, (self.frame.size.height-12)/2, 16, 12);
    }
}

-(void)setCellAccessoryView:(UIImageView *)accessoryView{
    
    if (_cellAccessoryView) {
        [_cellAccessoryView removeFromSuperview];
    }
    
    _cellAccessoryView = accessoryView;
    
    _cellAccessoryView.frame = CGRectMake(_cellTextLabel.frame.origin.x+_cellTextLabel.frame.size.width+10, (self.frame.size.height-12)/2, 16, 12);
    
    [self addSubview:_cellAccessoryView];
}

@end

@implementation LMIndexPath
- (instancetype)initWithColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight  leftRow:(NSInteger)leftRow row:(NSInteger)row {
    self = [super init];
    if (self) {
        _column = column;
        _leftOrRight = leftOrRight;
        _leftRow = leftRow;
        _row = row;
    }
    return self;
}

+ (instancetype)indexPathWithCol:(NSInteger)col leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow row:(NSInteger)row {
    LMIndexPath *indexPath = [[self alloc] initWithColumn:col leftOrRight:leftOrRight leftRow:leftRow row:row];
    return indexPath;
}
@end

#pragma mark - menu implementation

@interface LMDropDownMenu ()
@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) NSInteger numOfMenu;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UIView *bottomShadow;
@property (nonatomic, strong) UITableView *leftTableView;
//data source
@property (nonatomic, copy) NSArray *array;
//layers array
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *indicators;
@property (nonatomic, copy) NSArray *bgLayers;
@property (nonatomic, assign) NSInteger leftSelectedRow;
@property (nonatomic, assign) BOOL hadSelected;

@end


@implementation LMDropDownMenu

#pragma mark - getter
- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor blackColor];
    }
    return _indicatorColor;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

- (UIColor *)separatorColor {
    if (!_separatorColor) {
        _separatorColor = [UIColor blackColor];
    }
    return _separatorColor;
}

- (NSString *)titleForRowAtIndexPath:(LMIndexPath *)indexPath {
    return [self.dataSource menu:self titleForRowAtIndexPath:indexPath];
}

#pragma mark - 功能方法
- (void)addKVO {
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self  && [keyPath isEqualToString:@"frame"]) {
        CGRect old = [change[@"old"] CGRectValue];
        CGRect new = [change[@"new"] CGRectValue];
        NSLog(@"old:%@, new:%@", NSStringFromCGRect(old), NSStringFromCGRect(new));
        NSLog(@"");
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - setter
- (void)setDataSource:(id<LMDropDownMenuDataSource>)dataSource {
    _dataSource = dataSource;
    
    //configure view
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        _numOfMenu = [_dataSource numberOfColumnsInMenu:self];
    } else {
        _numOfMenu = 1;
    }
    
    CGFloat textLayerInterval = self.frame.size.width / ( _numOfMenu * 2);
    
    CGFloat separatorLineInterval = self.frame.size.width / _numOfMenu;
    
    CGFloat bgLayerInterval = self.frame.size.width / _numOfMenu;
    
    NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempIndicators = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempBgLayers = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    
    for (int i = 0; i < _numOfMenu; i++) {
        //bgLayer
        CGPoint bgLayerPosition = CGPointMake((i+0.5)*bgLayerInterval, self.frame.size.height/2);
        CALayer *bgLayer = [self createBgLayerWithColor:BackColor andPosition:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [tempBgLayers addObject:bgLayer];
        //title
        CGPoint titlePosition = CGPointMake( (i * 2 + 1) * textLayerInterval , self.frame.size.height / 2);
        NSString *titleString = [_dataSource menu:self titleForColumn:i];
        CATextLayer *title = [self createTextLayerWithNSString:titleString withColor:self.textColor andPosition:titlePosition];
        [self.layer addSublayer:title];
        [tempTitles addObject:title];
        //indicator
        CAShapeLayer *indicator = [self createIndicatorWithColor:self.indicatorColor andPosition:CGPointMake(titlePosition.x + title.bounds.size.width / 2 + 8, self.frame.size.height / 2)];
        [self.layer addSublayer:indicator];
        [tempIndicators addObject:indicator];
        
        //separator
        if (i != _numOfMenu - 1) {
            CGPoint separatorPosition = CGPointMake((i + 1) * separatorLineInterval, self.frame.size.height/2);
            CAShapeLayer *separator = [self createSeparatorLineWithColor:self.separatorColor andPosition:separatorPosition];
            [self.layer addSublayer:separator];
        }
    }
    
    _bottomShadow.backgroundColor = self.separatorColor;
    
    _titles = [tempTitles copy];
    _indicators = [tempIndicators copy];
    _bgLayers = [tempBgLayers copy];
}

#pragma mark - init method
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, 80, 30)];
    if (self) {
        
        [self addKVO];
        
        _origin = origin;
        
        _show = NO;
        
        _hadSelected = NO;
        
        //tableView init
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, self.frame.origin.y + self.frame.size.height, 0, 0) style:UITableViewStyleGrouped];
        _leftTableView.rowHeight = 38;
        _leftTableView.separatorColor = [UIColor colorWithRed:220.f/255.0f green:220.f/255.0f blue:220.f/255.0f alpha:1.0];
        _leftTableView.dataSource = self;
        _leftTableView.delegate = self;
        
        //self tapped
        self.backgroundColor = [UIColor whiteColor];
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        [self addGestureRecognizer:tapGesture];
        
        //background init and tapped
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, screenSize.height)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backGroundView addGestureRecognizer:gesture];
        
        //add bottom shadow
        _bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, screenSize.width, 0.5)];
        [self addSubview:_bottomShadow];
    }
    return self;
}

#pragma mark - init support
- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position {
    CALayer *layer = [CALayer layer];
    
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, self.frame.size.width/self.numOfMenu, self.frame.size.height-1);
    layer.backgroundColor = color.CGColor;
    
    return layer;
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

- (CAShapeLayer *)createSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(160,0)];
    [path addLineToPoint:CGPointMake(160, self.frame.size.height)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    
    CGPathRelease(bound);
    
    layer.position = point;
    
    return layer;
}

- (CATextLayer *)createTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point {
    
    CGSize size = [self calculateTitleSizeWithString:string];
    
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    layer.fontSize = 14.0;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.foregroundColor = color.CGColor;
    
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    layer.position = point;
    
    return layer;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    CGFloat fontSize = 14.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}

#pragma mark - gesture handle
- (void)menuTapped:(UITapGestureRecognizer *)paramSender {
    CGPoint touchPoint = [paramSender locationInView:self];
    //calculate index
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / _numOfMenu);
    
    for (int i = 0; i < _numOfMenu; i++) {
        if (i != tapIndex) {
            [self animateIndicator:_indicators[i] Forward:NO complete:^{
                [self animateTitle:_titles[i] show:NO complete:^{
                    
                }];
            }];
            [(CALayer *)self.bgLayers[i] setBackgroundColor:BackColor.CGColor];
        }
    }
    
    if (_show) {
        
        [self animateIdicator:_indicators[0] background:_backGroundView leftTableView:_leftTableView rightTableView:nil title:_titles[0] forward:NO complecte:^{
            
            _show = NO;
        }];
        
        [(CALayer *)self.bgLayers[tapIndex] setBackgroundColor:BackColor.CGColor];
    } else {
        
        _hadSelected = NO;
        
        if ([_dataSource respondsToSelector:@selector(currentLeftSelectedRow:)]) {
            
            _leftSelectedRow = [_dataSource currentLeftSelectedRow:0];
        }
        
        [_leftTableView reloadData];
        
        if (_leftTableView) {
            
            _leftTableView.frame = CGRectMake(_leftTableView.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            _leftTableView.backgroundColor = [UIColor redColor];
        }
        
        [self animateIdicator:_indicators[tapIndex] background:_backGroundView leftTableView:_leftTableView rightTableView:nil title:_titles[tapIndex] forward:YES complecte:^{
            _show = YES;
        }];
        
        [(CALayer *)self.bgLayers[tapIndex] setBackgroundColor:SelectColor.CGColor];
    }
}

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender
{
    
    [self animateIdicator:_indicators[0] background:_backGroundView leftTableView:_leftTableView rightTableView:nil title:_titles[0] forward:NO complecte:^{
        _show = NO;
    }];
    
    [(CALayer *)self.bgLayers[0] setBackgroundColor:BackColor.CGColor];
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

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    complete();
}

/**
 *动画显示下拉菜单
 */
- (void)animateLeftTableView:(UITableView *)leftTableView rightTableView:(UITableView *)rightTableView show:(BOOL)show complete:(void(^)())complete {
    
    if (show) {
        
        CGFloat leftTableViewHeight = 0;
        
        CGFloat rightTableViewHeight = 0;
        
        if (leftTableView) {
            
            leftTableView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            [self.superview addSubview:leftTableView];
            
            leftTableViewHeight = ([leftTableView numberOfRowsInSection:0] > 5) ? (5 * leftTableView.rowHeight) : ([leftTableView numberOfRowsInSection:0] * leftTableView.rowHeight);
            
        }
        
        CGFloat tableViewHeight = MAX(leftTableViewHeight, rightTableViewHeight);
        
        [UIView animateWithDuration:0.2 animations:^{
            if (leftTableView) {
                leftTableView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, tableViewHeight);
            }
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            
            if (leftTableView) {
                leftTableView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            }
            
        } completion:^(BOOL finished) {
            
            if (leftTableView) {
                [leftTableView removeFromSuperview];
            }
        }];
    }
    complete();
}

- (void)animateTitle:(CATextLayer *)title show:(BOOL)show complete:(void(^)())complete {
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    complete();
}

- (void)animateIdicator:(CAShapeLayer *)indicator background:(UIView *)background leftTableView:(UITableView *)leftTableView rightTableView:(UITableView *)rightTableView title:(CATextLayer *)title forward:(BOOL)forward complecte:(void(^)())complete{
    
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateLeftTableView:leftTableView rightTableView:rightTableView show:forward complete:^{
                }];
            }];
        }];
    }];
    
    complete();
}

- (void)animateIdicator:(CAShapeLayer *)indicator background:(UIView *)background title:(CATextLayer *)title forward:(BOOL)forward complecte:(void(^)())complete{
    
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                
            }];
        }];
    }];
    
    complete();
}

#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 0 左边   1 右边
    NSInteger leftOrRight = 0;
    
    NSAssert(self.dataSource != nil, @"menu's dataSource shouldn't be nil");
    if ([self.dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:leftOrRight: leftRow:)]) {
        return [self.dataSource menu:self numberOfRowsInColumn:0 leftOrRight:leftOrRight leftRow:_leftSelectedRow];
    } else {
        NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"DropDownMenuCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = BackColor;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = self.textColor;
    titleLabel.tag = 1;
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    
    [cell addSubview:titleLabel];
    
    //    UILabel *titleLabel = (UILabel*)[cell viewWithTag:1];
    
    CGSize textSize;
    
    if ([self.dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)]) {
        
        titleLabel.text = [self.dataSource menu:self titleForRowAtIndexPath:[LMIndexPath indexPathWithCol:0 leftOrRight:0 leftRow:_leftSelectedRow row:indexPath.row]];
        // 只取宽度
        textSize = [titleLabel.text textSizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(MAXFLOAT, 14) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.separatorInset = UIEdgeInsetsZero;
    
    CGFloat marginX = (self.frame.size.width-textSize.width)/2;
    
    titleLabel.frame = CGRectMake(marginX, 0, textSize.width, cell.frame.size.height);
    
    if (!_hadSelected && _leftSelectedRow == indexPath.row) {
        cell.backgroundColor = BackColor;
        
        UIImageView *accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_make"]];
        
        accessoryImageView.frame = CGRectMake(titleLabel.frame.origin.x+titleLabel.frame.size.width+10, (self.frame.size.height-12)/2, 16, 12);
        
        [cell addSubview:accessoryImageView];
    } else{
        
    }
    
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger leftOrRight = 0;
    _leftSelectedRow = indexPath.row;
    
    if (self.delegate || [self.delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
        
        [self confiMenuWithSelectRow:indexPath.row leftOrRight:leftOrRight];
        
        [self.delegate menu:self didSelectRowAtIndexPath:[LMIndexPath indexPathWithCol:0 leftOrRight:leftOrRight leftRow:_leftSelectedRow row:indexPath.row]];
        
    } else {
        //TODO: delegate is nil
    }
}

- (void)confiMenuWithSelectRow:(NSInteger)row leftOrRight:(NSInteger)leftOrRight{
    CATextLayer *title = (CATextLayer *)_titles[0];
    title.string = [self.dataSource menu:self titleForRowAtIndexPath:[LMIndexPath indexPathWithCol:0 leftOrRight:leftOrRight leftRow:_leftSelectedRow row:row]];
    
    [self animateIdicator:_indicators[0] background:_backGroundView leftTableView:_leftTableView rightTableView:nil title:_titles[0] forward:NO complecte:^{
        _show = NO;
    }];
    [(CALayer *)self.bgLayers[0] setBackgroundColor:BackColor.CGColor];
    
    CAShapeLayer *indicator = (CAShapeLayer *)_indicators[0];
    indicator.position = CGPointMake(title.position.x + title.frame.size.width / 2 + 8, indicator.position.y);
}

@end