#import "CBPeripheralAdditions.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


static const void *deviceTypeKey = &deviceTypeKey;
static const void *advertiseNameKey = &advertiseNameKey;
static const void *serialNOKey = &serialNOKey;
static const void *maxReConnectCountKey = &maxReConnectCountKey;
static const void *connectDateTimeKey = &connectDateTimeKey;
static const void *newRSSIKey = &newRSSIKey;
static const void *ifBroadcastKey = &ifBroadcastKey;
static const void *ifExpectDisconnectKey = &ifExpectDisconnectKey;
static const void *readWriteMgrKey = &readWriteMgrKey;


@implementation CBPeripheral (CBPeripheralAdditions)

@dynamic deviceType;
@dynamic advertiseName;
@dynamic serialNO;
@dynamic maxReConnectCount;
@dynamic connectDateTime;
@dynamic newRSSI;
@dynamic ifBroadcast;
@dynamic ifExpectDisconnect;
@dynamic readWriteMgr;

- (NSString *)deviceID {
    return self.identifier.UUIDString;
}

- (NSNumber *)deviceType {
    return objc_getAssociatedObject(self, deviceTypeKey);
}

- (void)setDeviceType:(NSNumber *)deviceType {
    objc_setAssociatedObject(self, deviceTypeKey, deviceType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)advertiseName {
    return objc_getAssociatedObject(self, advertiseNameKey);
}

- (void)setAdvertiseName:(NSString *)advertiseName {
    objc_setAssociatedObject(self, advertiseNameKey, advertiseName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)serialNO {
    return objc_getAssociatedObject(self, serialNOKey);
}

- (void)setSerialNO:(NSString *)serialNO {
    objc_setAssociatedObject(self, serialNOKey, serialNO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

- (NSNumber *)ifBroadcast {
    return objc_getAssociatedObject(self, ifBroadcastKey);
}

- (void)setIfBroadcast:(NSNumber *)ifBroadcast {
    objc_setAssociatedObject(self, ifBroadcastKey, ifBroadcast, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)ifExpectDisconnect {
    return objc_getAssociatedObject(self, ifExpectDisconnectKey);
}

- (void)setIfExpectDisconnect:(NSNumber *)ifExpectDisconnect {
    objc_setAssociatedObject(self, ifExpectDisconnectKey, ifExpectDisconnect, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SSBLEReadWriteManager *)readWriteMgr {
    return objc_getAssociatedObject(self, readWriteMgrKey);
}

- (void)setReadWriteMgr:(SSBLEReadWriteManager *)readWriteMgr {
    objc_setAssociatedObject(self, readWriteMgrKey, readWriteMgr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
