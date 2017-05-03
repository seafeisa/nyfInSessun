//
//  EditDiaryShelfViewController.h
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickerView.h"

@interface EditDiaryShelfViewController : UIViewController <PhotoPickerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *EditDairyShelfVieweditnote;
@property (weak, nonatomic) IBOutlet UIButton *EditdiaryshelfviewslectallTitle;
@property (weak, nonatomic) IBOutlet UIButton *Editdiaryshelfviewdeletetitle;
@property (weak, nonatomic) IBOutlet UIButton *Editdairyshelfviewchangecovertitle;

@end

@interface EditDiaryBookViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *cover;
@property (nonatomic, strong) IBOutlet UILabel     *title;
@property (strong, nonatomic) IBOutlet UIImageView *checkBox;

@end