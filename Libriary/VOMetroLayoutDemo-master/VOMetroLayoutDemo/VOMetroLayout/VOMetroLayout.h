//
//  VOMetroLayout.h
//  VOMetroLayoutDemo
//
//  Created by ValoLee on 15/1/13.
//  Copyright (c) 2015年 ValoLee. All rights reserved.
//

/*
 * 示意图(header和footer在上下位置)
 *
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                                        ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃
 ┃┃          header                ┃                                        ┃          header                ┃     ┃          header                ┃┃
 ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                                        ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃
 ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃
 ┃┃┏━━━━━━━━━━━━━━┓┏━━━━━━┓┏━━━━━━┓┃ ┃┏━━━━━━━━━━━━━━┓┏━━━━━━━━━━━━━━┓┃     ┃┏━━━━━━━━━━━━━━┓┏━━━━━━━━━━━━━━┓┃     ┃┏━━━━━━━━━━━━━━┓┏━━━━━━━━━━━━━━┓┃┃
 ┃┃┃              ┃┃      ┃┃      ┃┃ ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃┃
 ┃┃┃              ┃┃  1   ┃┃   1  ┃┃ ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃┃
 ┃┃┃              ┃┗━━━━━━┛┗━━━━━━┛┃ ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃┃
 ┃┃┃      4       ┃┏━━━━━━┓┏━━━━━━┓┃ ┃┃      4       ┃┃      4       ┃┃     ┃┃      4       ┃┃      4       ┃┃     ┃┃      4       ┃┃      4       ┃┃┃
 ┃┃┃              ┃┃      ┃┃      ┃┃ ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃┃
 ┃┃┃              ┃┃  1   ┃┃   1  ┃┃ ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃┃
 ┃┃┗━━━━━━━━━━━━━━┛┗━━━━━━┛┗━━━━━━┛┃ ┃┗━━━━━━━━━━━━━━┛┗━━━━━━━━━━━━━━┛┃     ┃┗━━━━━━━━━━━━━━┛┗━━━━━━━━━━━━━━┛┃     ┃┗━━━━━━━━━━━━━━┛┗━━━━━━━━━━━━━━┛┃┃
 ┃┃┏━━━━━━━━━━━━━━┓┏━━━━━━┓┏━━━━━━┓┃ ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃     ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃     ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃┃
 ┃┃┃              ┃┃      ┃┃      ┃┃ ┃┃                              ┃┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃┃              ┃┃  1   ┃┃   1  ┃┃ ┃┃                              ┃┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃┃              ┃┗━━━━━━┛┗━━━━━━┛┃ ┃┃                              ┃┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃┃      4       ┃┏━━━━━━┓        ┃ ┃┃                              ┃┃     ┃┃               8              ┃┃     ┃┃                              ┃┃┃
 ┃┃┃              ┃┃      ┃        ┃ ┃┃                              ┃┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃┃              ┃┃  1   ┃        ┃ ┃┃                              ┃┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃┗━━━━━━━━━━━━━━┛┗━━━━━━┛        ┃ ┃┃              16              ┃┃     ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃     ┃┃              16              ┃┃┃
 ┃┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃ ┃┃                              ┃┃     ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃     ┃┃                              ┃┃┃
 ┃┃┃                              ┃┃ ┃┃                              ┃┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃┃                              ┃┃ ┃┃                              ┃┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃┃                              ┃┃ ┃┃                              ┃┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃┃               8              ┃┃ ┃┃                              ┃┃     ┃┃               8              ┃┃     ┃┃                              ┃┃┃
 ┃┃┃                              ┃┃ ┃┃                              ┃┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃┃                              ┃┃ ┃┃                              ┃┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃ ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃     ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃     ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃┃
 ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃
 ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                                        ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃
 ┃┃          footer                ┃                                        ┃          footer                ┃     ┃          footer                ┃┃
 ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                                        ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 *
 * 说明:
 * UICollectionView  = section + section + ...
 * section = secionHeader + Area + sectionFooter + Area + Area +...
 * Area = Cell + Cell + ...
 * Cell 分为4类, 对应不同的unit数量
 */

/*
 * 示意图(header和footer在左右位置)
 *
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃┏━━━┓┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┏━━━┓     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃
 ┃┃   ┃┃┏━━━━━━━━━━━━━━┓┏━━━━━━┓┏━━━━━━┓┃ ┃┏━━━━━━━━━━━━━━┓┏━━━━━━━━━━━━━━┓┃┃   ┃     ┃┏━━━━━━━━━━━━━━┓┏━━━━━━━━━━━━━━┓┃     ┃┏━━━━━━━━━━━━━━┓┏━━━━━━━━━━━━━━┓┃┃
 ┃┃   ┃┃┃              ┃┃      ┃┃      ┃┃ ┃┃              ┃┃              ┃┃┃   ┃     ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃┃
 ┃┃   ┃┃┃              ┃┃  1   ┃┃   1  ┃┃ ┃┃              ┃┃              ┃┃┃   ┃     ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃┃
 ┃┃   ┃┃┃              ┃┗━━━━━━┛┗━━━━━━┛┃ ┃┃              ┃┃              ┃┃┃   ┃     ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃┃
 ┃┃   ┃┃┃      4       ┃┏━━━━━━┓┏━━━━━━┓┃ ┃┃      4       ┃┃      4       ┃┃┃   ┃     ┃┃      4       ┃┃      4       ┃┃     ┃┃      4       ┃┃      4       ┃┃┃
 ┃┃   ┃┃┃              ┃┃      ┃┃      ┃┃ ┃┃              ┃┃              ┃┃┃   ┃     ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃┃
 ┃┃   ┃┃┃              ┃┃  1   ┃┃   1  ┃┃ ┃┃              ┃┃              ┃┃┃   ┃     ┃┃              ┃┃              ┃┃     ┃┃              ┃┃              ┃┃┃
 ┃┃   ┃┃┗━━━━━━━━━━━━━━┛┗━━━━━━┛┗━━━━━━┛┃ ┃┗━━━━━━━━━━━━━━┛┗━━━━━━━━━━━━━━┛┃┃   ┃     ┃┗━━━━━━━━━━━━━━┛┗━━━━━━━━━━━━━━┛┃     ┃┗━━━━━━━━━━━━━━┛┗━━━━━━━━━━━━━━┛┃┃
 ┃┃ h ┃┃┏━━━━━━━━━━━━━━┓┏━━━━━━┓┏━━━━━━┓┃ ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃┃ f ┃     ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃     ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃┃
 ┃┃ e ┃┃┃              ┃┃      ┃┃      ┃┃ ┃┃                              ┃┃┃ o ┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃ a ┃┃┃              ┃┃  1   ┃┃   1  ┃┃ ┃┃                              ┃┃┃ o ┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃ d ┃┃┃              ┃┗━━━━━━┛┗━━━━━━┛┃ ┃┃                              ┃┃┃ t ┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃ e ┃┃┃      4       ┃┏━━━━━━┓        ┃ ┃┃                              ┃┃┃ e ┃     ┃┃               8              ┃┃     ┃┃                              ┃┃┃
 ┃┃ r ┃┃┃              ┃┃      ┃        ┃ ┃┃                              ┃┃┃ r ┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃   ┃┃┃              ┃┃  1   ┃        ┃ ┃┃                              ┃┃┃   ┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃   ┃┃┗━━━━━━━━━━━━━━┛┗━━━━━━┛        ┃ ┃┃              16              ┃┃┃   ┃     ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃     ┃┃              16              ┃┃┃
 ┃┃   ┃┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃ ┃┃                              ┃┃┃   ┃     ┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓┃     ┃┃                              ┃┃┃
 ┃┃   ┃┃┃                              ┃┃ ┃┃                              ┃┃┃   ┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃   ┃┃┃                              ┃┃ ┃┃                              ┃┃┃   ┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃   ┃┃┃                              ┃┃ ┃┃                              ┃┃┃   ┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃   ┃┃┃               8              ┃┃ ┃┃                              ┃┃┃   ┃     ┃┃               8              ┃┃     ┃┃                              ┃┃┃
 ┃┃   ┃┃┃                              ┃┃ ┃┃                              ┃┃┃   ┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃   ┃┃┃                              ┃┃ ┃┃                              ┃┃┃   ┃     ┃┃                              ┃┃     ┃┃                              ┃┃┃
 ┃┃   ┃┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃ ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃┃   ┃     ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃     ┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃┃
 ┃┗━━━┛┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┗━━━┛     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 *
 * 说明:
 * UICollectionView  = section + section + ...
 * section = secionHeader + Area  + Area + ... + sectionFooter
 * Area = Cell + Cell + ...
 * Cell 分为4类, 对应不同的unit数量
 */


#import <UIKit/UIKit.h>

/**
 *  cell的形状(大小), 每种形状对应不同的unit数量
 */
typedef NS_ENUM(NSUInteger, VOMetroCellStyle) {
    VOMetroCellSmallSquare = 0,     // 小正方形, 1个unit
    VOMetroCellNormalSquare,        // 普通正方形, 4个units
    VOMetroCellRectangle,           // 长方形, 8个units
    VOMetroCellLargeSquare,         // 大正方形, 16个units
    VOMetroCellLargeRectangle,      // 大长方形, 24个units
};

typedef NS_ENUM(NSUInteger, VOMetroHeaderFooterPosition) {
    VOMetroHeaderFooterPositionVertical,        //header和footer在上下
    VOMetroHeaderFooterPositionHorizontal       //header和footer在左右
};


@interface VOMetroLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) NSArray    *styleArray;    //布局数据,VOMetroCellStyle 组成的数组
@property (nonatomic, assign) CGFloat    areaSpacing;    //每个区域的间距, 默认为minimumInteritemSpacing的2倍
@property (nonatomic, assign) NSUInteger unitsPerSide;   //每个高度(纵向为宽度,暂不支持)能容纳unit数量

/**
 * header和footer
 * 它们的大小使用flowLayout的headerReferenceSize和footerReferenceSize
 * 它们的位置不使用flowLayout根据滚动方向自动判断的方式.使用以下这个属性进行设置
 */
@property (nonatomic, assign) VOMetroHeaderFooterPosition  headerFooterPostion;    // 默认为VOMetroHeaderFooterPositionVertical, 在上下位置

- (instancetype)initWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout;

@end