//
//  DiaryShelfViewController.h
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiaryShelfViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *Firstlinegrowthnote;
@property (weak, nonatomic) IBOutlet UIButton *WritenoteTitle;
@property (weak, nonatomic) IBOutlet UIButton *GrowthnoteEditTitle;

@end

@interface DiaryBookViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *cover;
@property (nonatomic, strong) IBOutlet UILabel     *title;

@end