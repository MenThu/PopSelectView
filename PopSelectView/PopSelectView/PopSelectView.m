//
//  PopSelectView.m
//  PopSelectView
//
//  Created by MenThu on 2018/3/29.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import "PopSelectView.h"

#define PopWeakSelf __weak typeof(self) weakSelf = self
static CGFloat const ROW_HEIGHT = 45.f;
static CGFloat const TABLE_WIDTH = 100.f;
static CGFloat const TRIANGLE_HEIGHT = 8.f;
static CGFloat const TRIANGLE_WIDTH = 12.f;
static CGFloat const TRIANGLE_EDGE_VIEW = 10.f;

@interface _PopCell : UITableViewCell

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIView *bottomLine;
- (void)setText:(NSString *)text selectState:(BOOL)isSelect bottomLineHidden:(BOOL)isHidden;

@end

@implementation _PopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

- (void)initView{
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:(_titleLabel = titleLabel)];
    
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:(_bottomLine = bottomLine)];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat height = CGRectGetHeight(self.contentView.bounds);
    
    self.titleLabel.frame = self.contentView.bounds;
    
    CGFloat lineHeight = 0.8f;
    CGFloat lineWidth = CGRectGetWidth(self.contentView.bounds);
    self.bottomLine.frame = CGRectMake(0, height-lineHeight, lineWidth, lineHeight);
}

- (void)setText:(NSString *)text selectState:(BOOL)isSelect bottomLineHidden:(BOOL)isHidden{
    self.titleLabel.text = text;
    self.bottomLine.hidden = isHidden;
    if (isSelect) {
        self.titleLabel.textColor = [UIColor redColor];
    }else{
        self.titleLabel.textColor = [UIColor blackColor];
    }
}

@end

@interface PopSelectView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray <NSString *> *selectTitleArray;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, copy) ClickCallBack callBack;
@property (nonatomic, weak) UIWindow *keyWindow;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, weak) CAShapeLayer *edgeLayer;
@property (nonatomic, weak) UIView *blowView;
@property (nonatomic, assign) CGPoint offset;

@end

@implementation PopSelectView

#pragma mark - LifeCircle
- (instancetype)init{
    if (self = [super init]) {
        [self initView];
    }
    return self;
}

#pragma mark - Public
- (void)showWithTitle:(NSArray <NSString *> *)selectTitleArray
    defautSelectIndex:(NSInteger)selectIndex
     blowCenterOfView:(UIView *)view
          pointOffset:(CGPoint)offset
        clickCallBack:(ClickCallBack)callBack{
    if (self.isShow) {
        return;
    }
    self.isShow = YES;
    NSAssert(callBack!=nil, @"");
    NSAssert(selectIndex <= selectTitleArray.count-1, @"");
    NSAssert([view isKindOfClass:[UIView class]], @"");
    self.selectIndex = selectIndex;
    self.selectTitleArray = selectTitleArray;
    self.callBack = callBack;
    self.blowView = view;
    self.offset = offset;
    if (self.superview != nil) {
        [self removeFromSuperview];
    }
    self.keyWindow = [UIApplication sharedApplication].keyWindow;
    self.frame = self.keyWindow.bounds;
    [self.keyWindow addSubview:self];
    [self changeSubViewFrame];
}

#pragma mark - Private
- (void)initView{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    gesture.delegate = self;
    [self addGestureRecognizer:gesture];
    
    [self initTableView];
}

- (void)initTableView{
    UIView *containerView = [UIView new];
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeZero;
    containerView.layer.shadowOpacity = 0.3;
    containerView.layer.shadowRadius = 5;
    containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:(_containerView = containerView)];
    
    CAShapeLayer *edgeLayer = [CAShapeLayer layer];
    edgeLayer.fillColor = [UIColor whiteColor].CGColor;
    [containerView.layer addSublayer:(_edgeLayer = edgeLayer)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (@available(iOS 11, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.scrollEnabled = NO;
    [tableView registerClass:[_PopCell class] forCellReuseIdentifier:@"_PopCell"];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.layer.cornerRadius = 2.f;
    tableView.layer.masksToBounds = YES;
    [containerView addSubview:(_tableView = tableView)];
    
    self.selectTitleArray = @[];
    self.isShow = NO;
    self.isTriangleRight = YES;
}

- (void)changeSubViewFrame{
    PopWeakSelf;
    CGRect viewInWindow = [self.blowView convertRect:self.blowView.bounds toView:self.keyWindow];
    CGPoint bottomCenter = CGPointMake(CGRectGetMidX(viewInWindow), CGRectGetMaxY(viewInWindow));
    CGFloat width = TABLE_WIDTH;
    CGFloat height = ROW_HEIGHT*self.selectTitleArray.count;
    CGFloat containerX = 0;
    CGFloat containerY = bottomCenter.y + self.offset.y;
    
    UIBezierPath *edgePath = [UIBezierPath bezierPath];
    if (self.isTriangleRight) {
        containerX = bottomCenter.x + self.offset.x + TRIANGLE_WIDTH/2 + TRIANGLE_EDGE_VIEW - TABLE_WIDTH;

        [edgePath moveToPoint:CGPointMake(width-TRIANGLE_EDGE_VIEW-TRIANGLE_WIDTH, TRIANGLE_HEIGHT)];//三角形左下角
        [edgePath addLineToPoint:CGPointMake(width-TRIANGLE_EDGE_VIEW-TRIANGLE_WIDTH/2, 0)];//三角形定点
        [edgePath addLineToPoint:CGPointMake(width-TRIANGLE_EDGE_VIEW, TRIANGLE_HEIGHT)];//三角形右下角
    }else{
        containerX = bottomCenter.x + self.offset.x - TRIANGLE_WIDTH/2 - TRIANGLE_EDGE_VIEW;
        
        [edgePath moveToPoint:CGPointMake(TRIANGLE_EDGE_VIEW, TRIANGLE_HEIGHT)];//三角形左下角
        [edgePath addLineToPoint:CGPointMake(TRIANGLE_EDGE_VIEW+TRIANGLE_WIDTH/2, 0)];//三角形定点
        [edgePath addLineToPoint:CGPointMake(TRIANGLE_EDGE_VIEW+TRIANGLE_WIDTH, TRIANGLE_HEIGHT)];//三角形右下角
    }
    [edgePath closePath];
    self.edgeLayer.path = edgePath.CGPath;
    
    self.containerView.frame = CGRectMake(containerX, containerY, width, height);
    self.tableView.frame = CGRectMake(0, TRIANGLE_HEIGHT, width, height);
    self.containerView.alpha = 0.f;
    self.containerView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.containerView.transform = CGAffineTransformMakeScale(1, 1);
        weakSelf.containerView.alpha = 1;
    }];
}

- (void)dismiss{
    PopWeakSelf;
    if (!self.isShow) {
        return;
    }
    self.isShow = NO;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.containerView.alpha = 0.f;
        weakSelf.containerView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        weakSelf.containerView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - UITableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.selectTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    _PopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"_PopCell" forIndexPath:indexPath];
    [cell setText:self.selectTitleArray[indexPath.row] selectState:(indexPath.row == self.selectIndex) bottomLineHidden:(indexPath.row == self.selectTitleArray.count-1)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self dismiss];
    self.callBack(indexPath.row);
}

#pragma mark - UIGestureDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint locationPoint = [gestureRecognizer locationInView:self.containerView];
    if (CGRectContainsPoint(self.tableView.frame, locationPoint)) {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - Setter
- (void)setSelectTitleArray:(NSArray<NSString *> *)selectTitleArray{
    _selectTitleArray = selectTitleArray;
    [self.tableView reloadData];
}

- (void)setIsTriangleRight:(BOOL)isTriangleRight{
    _isTriangleRight = isTriangleRight;
    CGFloat anchorPointScale = 0;
    if (isTriangleRight) {
        anchorPointScale = (TABLE_WIDTH-TRIANGLE_EDGE_VIEW-TRIANGLE_WIDTH/2) / TABLE_WIDTH;
    }else{
        anchorPointScale = (TRIANGLE_EDGE_VIEW+TRIANGLE_WIDTH/2) / TABLE_WIDTH;
    }
    self.containerView.layer.anchorPoint = CGPointMake(anchorPointScale, 0);
}

@end
