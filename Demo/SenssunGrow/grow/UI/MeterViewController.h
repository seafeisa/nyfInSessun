//
//  MeterViewController.h
//  grow
//
//  Created by admin on 15-4-2.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeterViewController : UIViewController <BluetoothManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *MeterViewWeightname;
@property (weak, nonatomic) IBOutlet UILabel *MeterViewheightname;
@property (weak, nonatomic) IBOutlet UILabel *MeterViewheadsizename;

@property (nonatomic, copy) NSString *currentUnit;
@end
