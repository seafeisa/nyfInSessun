#import "BodyMeasure.h"
#import "HistoryWater.h"
#import "CBPeripheralAdditions.h"
#import "SSBLEReadWriteData.h"


typedef NS_ENUM(int, SSBLEDeviceTypeEnum) {
    SSBLESENSSUNBODY = 1,
    SSBLESENSSUNFAT = 2,
    SSBLESENSSUNHEART = 3,
    SSBLESENSSUNSUPERFAT = 4,
    SSBLESENSSUN = 5,
    SSBLESENSSUNFOOD = 6,
    SSBLESENSSUNPAD = 7,
    SSBLESENSSUNTRACK = 8,
    SSBLESENSSUNALI = 9,
    SSBLESENSSUNMWS1 = 10,
    SSBLESENSSUNEQi99 = 11,
    SSBLESENSSUNBODYCLOCK = 12,
    SSBLESENSSUNEQi912 = 13,
    SSBLESENSSUNFATCLOCK = 14,
    SSBLESENSSUNGROWTH = 15,
    SSBLESENSSUNJOINTOWN = 16,
    SSBLESENSSUNFATPIN = 19,
    SSBLESENSSUNLETVB1 = 20
};


@protocol SSBLEDeviceDelegate <NSObject>
@optional
- (void)peripheralDidDiscover:(CBPeripheral *)peripheral;
- (void)peripheralDidConnect:(CBPeripheral *)peripheral;
- (void)peripheralDidFailToConnect:(CBPeripheral *)peripheral;
- (void)peripheralDidDisconnect:(CBPeripheral *)peripheral;
- (void)peripheralDidAllowWrite:(CBPeripheral *)peripheral;
//当value的DataType＝DataTypeWeigh，表示接收到秤重数据，此时values＝nil
//当value的DataType＝DataTypeTestFat，表示接收到测试脂肪数据，此时values＝nil
//当value的DataType＝DataTypeHistory，表示接收到历史数据，此时values＝nil
//当values!=nil时，表示接收完所有历史数据，历史数据存储在values对象中，此时value＝nil
//此接口仅供：体重，体脂，八电极秤体使用
- (void)peripheralDidReceived:(CBPeripheral *)peripheral value:(BodyMeasure *)value values:(NSMutableArray *)values;
//此接口仅供带历史数据的体脂秤使用
- (void)peripheralDidReceivedAllHistoryData:(CBPeripheral *)peripheral;
//此接口仅供：智能杯垫使用
- (void)peripheralDidReceived:(CBPeripheral *)peripheral water:(HistoryWater *)water waters:(NSMutableArray *)values;
//此接口仅供：除体重，体脂，八电极外的秤体使用
- (void)peripheralDidReceived:(CBPeripheral *)peripheral data:(SSBLEReadWriteData *)data datas:(NSArray *)datas;
- (void)peripheralDidWrite:(CBPeripheral *)peripheral data:(SSBLEReadWriteData *)data;
- (void)peripheralDidFailToWrite:(CBPeripheral *)peripheral data:(SSBLEReadWriteData *)data;
- (void)peripheralDidConnecting:(CBPeripheral *)peripheral;
- (void)peripheralDidReceived:(CBPeripheral *)peripheral wrongData:(NSData *)data;
@end


@interface SSBLEDevice : NSObject

@property (nonatomic, readonly, assign) SSBLEDeviceTypeEnum deviceType;
@property (nonatomic, readonly, retain) NSDictionary *nameToServiceMap;
@property (nonatomic, readonly) BOOL ifBroadcast;
@property (nonatomic, readonly) BOOL ifPrefixName;

- (NSMutableDictionary *)shortServiceUUIDs;
- (NSMutableDictionary *)serviceUUIDs;

#pragma mark parse data
+ (NSMutableDictionary *)parseData:(NSData *)data deviceType:(SSBLEDeviceTypeEnum)type ;
+ (NSMutableDictionary *)getDevicesNameMap:(NSMutableDictionary *)nameToConnectDeviceMap :(NSMutableDictionary *)nameToBroadcastDeviceMap :(NSArray *)deviceTypes;

@end
