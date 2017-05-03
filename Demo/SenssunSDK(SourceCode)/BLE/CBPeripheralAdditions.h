#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@class SSBLEReadWriteManager;


@interface CBPeripheral (CBPeripheralAdditions)

@property (nonatomic, readonly) NSString *deviceID;
@property (nonatomic, retain) NSNumber *deviceType;
@property (nonatomic, copy) NSString *advertiseName;
@property (nonatomic, copy) NSString *serialNO;
@property (nonatomic, retain) NSNumber *maxReConnectCount;
@property (nonatomic, retain) NSNumber *connectDateTime;
@property (nonatomic, retain) NSNumber *newRSSI;
@property (nonatomic, retain) NSNumber *ifBroadcast;
@property (nonatomic, retain) NSNumber *ifExpectDisconnect;
@property (nonatomic, retain) SSBLEReadWriteManager *readWriteMgr;

@end
