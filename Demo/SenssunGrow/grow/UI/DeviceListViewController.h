//
//  DeviceListViewController.h
//  grow
//
//  Created by admin on 15-7-1.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceListViewController : UIViewController <BluetoothManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *DeviceViewdevicemanage;


@end