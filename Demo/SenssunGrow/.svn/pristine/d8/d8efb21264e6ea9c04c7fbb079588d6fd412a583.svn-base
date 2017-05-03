//
//  PickerView.h
//  grow
//
//  Created by admin on 15-3-19.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerViewDelegate;

@interface PickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) id<PickerViewDelegate> delegate;  // default is nil. weak reference
@property (nonatomic, assign) BOOL isDatePicker;                // default is NO.

- (void)changeMode:(NSString *)mode;

@end

@protocol PickerViewDelegate<NSObject>

@optional

- (void)pikerviewDidHide:(PickerView *)pickerView;
- (void)pikerviewDidShow:(PickerView *)pickerView;

- (void)pikerviewDidCancel:(PickerView *)pickerView;
- (void)pikerviewDidConfirm:(PickerView *)pickerView selectedRowTitle:(NSString *)rowTitle forRow:(NSInteger)row;
- (void)pikerviewDidConfirm:(PickerView *)pickerView selectedDate:(NSDate *)date;

@end