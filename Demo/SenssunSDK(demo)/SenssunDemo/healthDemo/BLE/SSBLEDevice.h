#import "BodyMeasure.h"
#import "HistoryWater.h"
#import "CBPeripheralAdditions.h"
#import "SSBLEReadWriteData.h"


typedef NS_ENUM(int, SSBLEDeviceTypeEnum) {
    SSBLESENSSUNSCALEBODY = 100,
    SSBLESENSSUNSCALEKITCHEN = 200,
    SSBLESENSSUNWRISTSTRAP = 300,
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
@property (nonatomic, readonly, retain) NSDictionary *serviceMap;
@property (nonatomic, readonly) int maxConnectCount;
@property (nonatomic, readonly, retain) NSMutableDictionary *serialNOToPeripheralMap;

- (NSDictionary *)shortServiceUUIDs;
- (NSDictionary *)serviceUUIDs;

#pragma mark parse data
+ (NSString *)dataToHexString:(NSData *)data;
+ (NSMutableDictionary *)parseData:(NSData *)data deviceType:(SSBLEDeviceTypeEnum)type model:(NSString *)model protocol:(int)protocol ;
+ (NSDictionary *)getDevicesMap:(NSArray *)deviceTypes;
+ (NSDictionary *)getAcceptableManufacturerIDs;
+ (NSDictionary *)parseSerialNO:(NSString *)serialNO;
+ (NSDictionary *)modelToDeviceTypeMap;
+ (int)getDeviceTypeByModel:(NSString *)model;

@end
