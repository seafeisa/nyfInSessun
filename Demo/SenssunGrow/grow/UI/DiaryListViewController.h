//
//  DiaryListViewController.h
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiaryListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *DiaryListViewgrowthnotename;
@property (weak, nonatomic) IBOutlet UIButton *DiaryListViewwritenotename;

@property (nonatomic, assign) NSInteger superBook;
@property (weak, nonatomic) IBOutlet UIButton *DiaryViewdeleteAlltitle;
@property (weak, nonatomic) IBOutlet UIButton *DiaryViewdeteletitle;

@end
