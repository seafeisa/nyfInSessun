#import <Foundation/Foundation.h>
#import "SSBLEDeviceManager.h"


@interface SSBLEReadWriteManager : NSObject

@property (nonatomic, retain) CBCharacteristic *notifyCharacteristic;
@property (nonatomic, retain) CBCharacteristic *writeCharacteristic;
@property (nonatomic, readonly, retain) NSMutableData *readBuffer;
@property (nonatomic, readonly, retain) NSMutableArray *writeBuffer;
@property (nonatomic, assign) NSInteger readDateTime;

- (void)addWriteData:(NSData *)data :(int)dataType :(NSInteger)maxRewriteCount;
- (void)readData:(NSData *)data :(SSBLEDevice *)device :(CBPeripheral *)peripheral :(NSMutableArray *)targetDelegates :(SSBLEDeviceManager *)deviceMgr;

@end
