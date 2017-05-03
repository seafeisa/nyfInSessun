#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@class SSBLEReadWriteManager;


@interface CBPeripheral (CBPeripheralAdditions)

@property (nonatomic, readonly) NSString *deviceID;
@property (nonatomic, copy) NSString *serialNO;
@property (nonatomic, copy) NSString *manufacturerID;
@property (nonatomic, copy) NSString *protocol;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, retain) NSNumber *deviceType;
@property (nonatomic, retain) NSNumber *maxReConnectCount;
@property (nonatomic, retain) NSNumber *connectDateTime;
@property (nonatomic, retain) NSNumber *newRSSI;
@property (nonatomic, retain) NSNumber *ifExpectDisconnect;
@property (nonatomic, retain) NSNumber *seq;
@property (nonatomic, retain) SSBLEReadWriteManager *readWriteMgr;

@property (nonatomic, retain) NSDictionary *deviceInfo;
@property (nonatomic, retain) NSArray *sensors;

@end
