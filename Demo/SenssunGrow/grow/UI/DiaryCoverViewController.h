//
//  DiaryCoverViewController.h
//  grow
//
//  Created by admin on 15-5-7.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerView.h"
#import "PhotoPickerView.h"

@interface DiaryCoverViewController : UIBaseListItemViewController <UITextFieldDelegate, PickerViewDelegate, PhotoPickerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *DairyCoverviewcreadtnotes;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DiaryCoverViewcanceltitle;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *DiaryCoverViewmeasuretitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DiaryCoverviewconfirmtitle;


@property (weak, nonatomic) IBOutlet UIButton *DiaryCoverViewbuttondone;




//@property (nonatomic, assign) ENAccessMode accessMode;
//@property (nonatomic, assign) NSInteger    selectedItem;     // accessMode != CREATE 时有效
//@property (nonatomic, strong) DiaryBook    *diaryBook;

@end
