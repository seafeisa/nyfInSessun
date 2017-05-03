#import "CBPeripheralAdditions.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


static const void *serialNOKey = &serialNOKey;
static const void *manufacturerIDKey = &manufacturerIDKey;
static const void *protocolKey = &protocolKey;
static const void *modelKey = &modelKey;
static const void *deviceTypeKey = &deviceTypeKey;
static const void *maxReConnectCountKey = &maxReConnectCountKey;
static const void *connectDateTimeKey = &connectDateTimeKey;
static const void *newRSSIKey = &newRSSIKey;
static const void *ifExpectDisconnectKey = &ifExpectDisconnectKey;
static const void *seqKey = &seqKey;
static const void *readWriteMgrKey = &readWriteMgrKey;

static const void *deviceInfoKey = &deviceInfoKey;
static const void *sensorsKey = &sensorsKey;


@implementation CBPeripheral (CBPeripheralAdditions)

@dynamic serialNO;
@dynamic manufacturerID;
@dynamic protocol;
@dynamic model;
@dynamic deviceType;
@dynamic maxReConnectCount;
@dynamic connectDateTime;
@dynamic newRSSI;
@dynamic ifExpectDisconnect;
@dynamic seq;
@dynamic readWriteMgr;

@dynamic deviceInfo;
@dynamic sensors;

- (NSString *)deviceID {
    return self.identifier.UUIDString;
}

- (NSString *)serialNO {
    return objc_getAssociatedObject(self, serialNOKey);
}

- (void)setSerialNO:(NSString *)serialNO {
    objc_setAssociatedObject(self, serialNOKey, serialNO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)manufacturerID {
    return objc_getAssociatedObject(self, manufacturerIDKey);
}

- (void)setManufacturerID:(NSString *)manufacturerID {
    objc_setAssociatedObject(self, manufacturerIDKey, manufacturerID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)protocol {
    return objc_getAssociatedObject(self, protocolKey);
}

- (void)setProtocol:(NSString *)protocol {
    objc_setAssociatedObject(self, protocolKey, protocol, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)model {
    return objc_getAssociatedObject(self, modelKey);
}

- (void)setModel:(NSString *)model {
    objc_setAssociatedObject(self, modelKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)deviceType {
    return objc_getAssociatedObject(self, deviceTypeKey);
}

- (void)setDeviceType:(NSNumber *)deviceType {
    objc_setAssociatedObject(self, deviceTypeKey, deviceType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)maxReConnectCount {
    return objc_getAssociatedObject(self, maxReConnectCountKey);
}

- (void)setMaxReConnectCount:(NSNumber *)maxReConnectCount {
    objc_setAssociatedObject(self, maxReConnectCountKey, maxReConnectCount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)connectDateTime {
    return objc_getAssociatedObject(self, connectDateTimeKey);
}

- (void)setConnectDateTime:(NSNumber *)connectInterval {
    objc_setAssociatedObject(self, connectDateTimeKey, connectInterval, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)newRSSI {
    return objc_getAssociatedObject(self, newRSSIKey);
}

- (void)setNewRSSI:(NSNumber *)newRSSI {
    objc_setAssociatedObject(self, newRSSIKey, newRSSI, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)ifExpectDisconnect {
    return objc_getAssociatedObject(self, ifExpectDisconnectKey);
}

- (void)setIfExpectDisconnect:(NSNumber *)ifExpectDisconnect {
    objc_setAssociatedObject(self, ifExpectDisconnectKey, ifExpectDisconnect, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)seq {
    return objc_getAssociatedObject(self, seqKey);
}

- (void)setSeq:(NSNumber *)seq {
    objc_setAssociatedObject(self, seqKey, seq, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SSBLEReadWriteManager *)readWriteMgr {
    return objc_getAssociatedObject(self, readWriteMgrKey);
}

- (void)setReadWriteMgr:(SSBLEReadWriteManager *)readWriteMgr {
    objc_setAssociatedObject(self, readWriteMgrKey, readWriteMgr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



- (NSDictionary *)deviceInfo {
    return objc_getAssociatedObject(self, deviceInfoKey);
}

- (void)setDeviceInfo:(NSDictionary *)deviceInfo {
    objc_setAssociatedObject(self, deviceInfoKey, deviceInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)sensors {
    return objc_getAssociatedObject(self, sensorsKey);
}

- (void)setSensors:(NSArray *)sensors {
    objc_setAssociatedObject(self, sensorsKey, sensors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
