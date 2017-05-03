//
//  HomeViewController.h
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <PhotoPickerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *Growthcurve;
@property (weak, nonatomic) IBOutlet UILabel *GroethDiary;
@property (weak, nonatomic) IBOutlet UILabel *Meadure;
@property (weak, nonatomic) IBOutlet UILabel *Users;
@property (weak, nonatomic) IBOutlet UILabel *Setting;

@end
