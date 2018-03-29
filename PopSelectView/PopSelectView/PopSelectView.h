//
//  PopSelectView.h
//  PopSelectView
//
//  Created by MenThu on 2018/3/29.
//  Copyright © 2018年 MenThu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ClickCallBack) (NSInteger clickIndex);

@interface PopSelectView : UIView


/**
 *  三角形是否在列表的右边,默认是右边
 */
@property (nonatomic, assign) BOOL isTriangleRight;

/**
 *  弹出一个选择框
 *  selectTitleArray    所有带展示的数据源
 *  selectIndex         默认被选中的那一行
 *  view                被突出显示的视图
 *  offset              相对于view底部中心的偏移量
 *  点击回调
 */
- (void)showWithTitle:(NSArray <NSString *> *)selectTitleArray
    defautSelectIndex:(NSInteger)selectIndex
     blowCenterOfView:(UIView *)view
          pointOffset:(CGPoint)offset
        clickCallBack:(ClickCallBack)callBack;

@end
