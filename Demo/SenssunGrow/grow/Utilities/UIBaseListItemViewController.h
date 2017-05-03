//
//  UIBaseListItemViewController.h
//  grow
//
//  Created by admin on 15-5-13.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBaseListItemViewController : UIViewController

@property (nonatomic, assign) ENAccessMode accessMode;
@property (nonatomic, assign) NSInteger    selectedItem;     // accessMode != CREATE 时有效

@end
