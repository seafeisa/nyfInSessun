#import <Foundation/Foundation.h>
#import "SSBLEDevice.h"


typedef NS_ENUM(int, SSBLEModeEnum) {
    SSBLEModeNone = 0,
    SSBLEModeConnectManual = 1,
    SSBLEModeConnectAuto = 2
};

/*
 本蓝牙连接管理类，用于连接香山自主品牌的蓝牙产品，
 当连接到蓝牙产品后，本类自动管理这些已连接蓝牙产品，
 蓝牙产品最大连接数为1，
 异常断开连接的蓝牙产品，本类自动重新连接，
 调用断开连接命令，后取消连接的蓝牙产品，不回自动再次连接
*/

@interface SSBLEDeviceManager : NSObject

//
@property (nonatomic, assign) BOOL ifTestPeripheral;
//返回已连接设备的映射表
@property (nonatomic, readonly, retain) NSMutableDictionary *serialNOToPeripheralMap;

//返回已连接设备的数量
- (NSInteger)peripheralsCount;

//初始化方法 deviceTypes表示需要连接的设备类型 rssiMin表示连接设备的最差信号强度，范围值（－1～－127），当值为－1时，不限制需要连接的设备的信号强度
- (id)initWithDeviceTypes:(NSArray *)deviceTypes rssiMin:(int)rssiMin;
- (void)setRewriteCount:(NSInteger)count;
- (void)setMaxConnectCount:(NSInteger)count;

#pragma mark add/remove delegate
//添加代理
- (void)addDelegate:(id)delegate;
//移除代理
- (void)removeDelegate:(id)delegate;

#pragma mark connect/disconnect BLE
//重置内部变量的值，作用相当于初始化
- (void)reset;
//搜索设备
- (void)scanPeripherals;
//连接给定serialNO的设备
- (void)connectWithSerialNOs:(NSArray *)serialNOs;
//断开给定serialNO的设备
- (void)disconnectWithSerialNOs:(NSArray *)serialNOs;
//自动连接设备
- (void)connect;
//断开所有连接设备
- (void)disconnect;

#pragma mark write data to SENSSUNSCALEBODY
- (void)sendSENSSUNSCALEBODYStopMeasureData:(CBPeripheral *)peripheral;
- (void)sendSENSSUNSCALEBODYSyncUserData:(CBPeripheral *)peripheral :(int)operation :(int)number :(int)pin :(int)sex :(int)heightCM :(int)age :(int)sportMode :(NSString *)unitID :(int)bodyMassKG;
- (void)sendSENSSUNSCALEBODYSyncHistoryData:(CBPeripheral *)peripheral :(int)pin;
- (void)sendSENSSUNSCALEBODYSyncDateTime:(CBPeripheral *)peripheral;
- (void)sendSENSSUNSCALEBODYGetSerialNO:(CBPeripheral *)peripheral;
- (void)sendSENSSUNSCALEBODYGetBattery:(CBPeripheral *)peripheral;
- (void)sendSENSSUNSCALEBODYResetScale:(CBPeripheral *)peripheral;
- (void)sendSENSSUNSCALEBODYGetUserData:(CBPeripheral *)peripheral;

@end
