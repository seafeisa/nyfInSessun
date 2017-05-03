//
//  BthMgr.h
//  ChildGrowth
//
//  Created by admin on 14-11-18.
//  Copyright (c) 2014年 camry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "COMMprotocol.h"

#define PERIPHERAL_DEVICE_NAME          @"SENSSUN Growth"

///**只有一个服务*/
#define PERIPHERAL_SERVICE_UUIDOLD         [CBUUID UUIDWithString:@"FFB0"]
#define PERIPHERAL_CHARACTERISTIC_UUIDOLD  [CBUUID UUIDWithString:@"FFB2"]

/*两个服务*/
///**特征1*/
//#define PERIPHERAL_SERVICE_UUID         [CBUUID UUIDWithString:@"FFF01"]
//#define PERIPHERAL_CHARACTERISTIC_UUID  [CBUUID UUIDWithString:@"FFF11"]
/**特征2*/
#define PERIPHERAL_SERVICE_UUID1         [CBUUID UUIDWithString:@"FFF0"]
#define PERIPHERAL_CHARACTERISTIC_NOTIFY_UUID  [CBUUID UUIDWithString:@"FFF1"]
#define PERIPHERAL_CHARACTERISTIC_WRITE_UUID  [CBUUID UUIDWithString:@"FFF2"]



typedef enum
{
    LINK_AUTO,
    LINK_MANUAL
} BLELinkMode;

typedef enum
{
    SCAN_ONCE,
    SCAN_ALWAYS
} BLEScanMode;

@protocol BluetoothManagerDelegate <NSObject>
@optional

- (void)bluetoothDidDiscoverPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI;
- (void)bluetoothDidConnectPeripheral:(CBPeripheral *)peripheral;
- (void)bluetoothDidReceiveData:(NSData *)data;
//- (void)bluetoothDidReceiveIMData:(PROV2IMDATA)data;
//- (void)bluetoothDidReceiveHisData:(PROV2HISDATA)data;

@end

//@protocol BluetoothManagerDatasource <NSObject>
//@required
//
//- (CBUUID *)peripheralServiceUUID;
//- (CBUUID *)peripheralCharacteristicUUID;
//
//@end

@interface BthMgr : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, assign) id<BluetoothManagerDelegate>   delegate;   // default is nil. weak reference
//@property (nonatomic, assign) id<BluetoothManagerDatasource> dataSource; // default is nil. weak reference

+ (BthMgr *)sharedInstance;

- (void)appointPeripheralWithUUID:(NSString *)UUIDString;

- (void)startScan;
- (void)keepScannig;
- (void)stopScan;
- (void)connect;
- (void)stopConnect;
- (void)sendMSG:(NSData *)data;

@end
