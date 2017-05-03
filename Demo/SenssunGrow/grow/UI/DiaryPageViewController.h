//
//  DiaryPageViewController.h
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerView.h"
#import "PhotoPickerView.h"
#import "QBImagePickerController.h"

@interface DiaryPageViewController : UIBaseListItemViewController <UITextFieldDelegate, UITextViewDelegate,
                                                                   PickerViewDelegate, PhotoPickerDelegate,
                                                                   QBImagePickerControllerDelegate>

//@property (nonatomic, assign) ENAccessMode accessMode;
//@property (nonatomic, assign) NSInteger    selectedItem;     // accessMode != CREATE 时有效
//@property (nonatomic, strong) DiaryPage    *diary;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DairyPageViewmeasure;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DairypageViewConfirmtitle;

@property (weak, nonatomic) IBOutlet UIButton *DairyPageViewButtonConfirm;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DairyPageViewCanceltitle;
@property (weak, nonatomic) IBOutlet UILabel *DairyPageViewgrowthnote;
@property (nonatomic, assign) NSInteger superBook;

@end


@interface PhotoViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *photo;

@end