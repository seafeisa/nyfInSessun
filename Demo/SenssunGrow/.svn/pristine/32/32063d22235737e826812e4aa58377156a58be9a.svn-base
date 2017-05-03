//
//  PhotoPickerView.h
//  grow
//
//  Created by admin on 15-6-10.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPImageCropperViewController.h"

@protocol PhotoPickerDelegate;

@interface PhotoPickerView : UIView <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>

@property (nonatomic, assign) id<PhotoPickerDelegate> delegate;  // default is nil. weak reference

- (void)showInView:(UIView *)view;

@end


@protocol PhotoPickerDelegate <NSObject>
@optional

- (void)photoPickerView:(PhotoPickerView *)picker didFinishPickingWithImage:(UIImage *)photo;
- (void)photoPickerDidCancel;

@end