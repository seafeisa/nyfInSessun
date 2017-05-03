//
//  COMMprotocol.h
//  grow
//
//  Created by admin on 15-6-5.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define PERIPHERAL_DEVICE_NAME          @"SENSSUN Growth"
//
///**只有一个服务*/
////#define PERIPHERAL_SERVICE_UUID         [CBUUID UUIDWithString:@"FFB0"]
////#define PERIPHERAL_CHARACTERISTIC_UUID  [CBUUID UUIDWithString:@"FFB2"]
//
///*两个服务*/
///**特征1*/
//#define PERIPHERAL_SERVICE_UUID         [CBUUID UUIDWithString:@"FFF0"]
//#define PERIPHERAL_CHARACTERISTIC_UUID  [CBUUID UUIDWithString:@"FFF1"]
///**特征2*/
//#define PERIPHERAL_SERVICE_UUID1         [CBUUID UUIDWithString:@"FFF3"]
//#define PERIPHERAL_CHARACTERISTIC_NOTIFY_UUID  [CBUUID UUIDWithString:@"FFF4"]
//#define PERIPHERAL_CHARACTERISTIC_WRITE_UUID  [CBUUID UUIDWithString:@"FFF5"]

typedef enum
{
    PROTOCOL_V0 = 0,
    PROTOCOL_V2 = 2,
    
    PROTOCOL_BUTT
} PROVer;

//=============================================================
// 通讯协议v0
// BYTE1：0xFF，引导码
// BYTE2：0Xa5，产品型号码
// BYTE3：DATA1 H，数据1高位
// BYTE4：DATA1 L，数据1低位
// BYTE5：DATA2 H，数据2高位
// BYTE6：DATA2 L，数据2低位
// BYTE7：DATA FLAG，数据标志
// BYTE8：CHECK SUM，校验和，=BYTE3+BYTE4+BYTE5+BYTE6+BYTE7

#define PROV0_PKT_LEN           8       // 帧长
#define PROV0_PREAMBLE          0xFF    // 前导码
#define PROV0_PRODUCT_MODULE    0xA5    // 产品型号

typedef enum
{
    DATA_POS_PREAMBLE = 0,
    DATA_POS_PRODUCT_MODULE,
    DATA_POS_DATA1_H,
    DATA_POS_DATA1_L,
    DATA_POS_DATA2_H,
    DATA_POS_DATA2_L,
    DATA_POS_CMDCODE,
    DATA_POS_CHECKSUM
} PKTFieldV0;

typedef enum
{
    CMD_HEIGHT_CHANGING = 0x90,
    CMD_HEIGHT_STABLE   = 0x9A,
    CMD_WEIGHT_CHANGING = 0xA0,
    CMD_WEIGHT_STABLE   = 0xAA,
    
    CMD_END = 0xFF
} CMDCodeV0;

//=============================================================
// 通讯协议v2
#define PROV2_PKT_LEN           13      // 帧长
#define PROV2_PKT_HEAD          0xFF    // 数据头
#define PROV2_SIG_LEN           9       // 命令帧长
#define PROV2_SIG_HEAD          0xA5    // 命令数据头

typedef enum
{
    PROV2_FIELD_PREAMBLE = 0,
    PROV2_FIELD_CMDWORD,
    
    PROV2_FIELD_DATA1_H,
    PROV2_FIELD_DATA1_L,
    PROV2_FIELD_DATA2_H,
    PROV2_FIELD_DATA2_L,
    PROV2_FIELD_DATA3_H,
    PROV2_FIELD_DATA3_L,
    PROV2_FIELD_FLAG,
    PROV2_FIELD_USER_ID,
    PROV2_FIELD_STABLE,
    PROV2_FIELD_RESERVED,
    
    PROV2_FIELD_HIS_YEAR     = PROV2_FIELD_DATA1_H,
    PROV2_FIELD_HIS_DAY_H,
    PROV2_FIELD_HIS_DAY_L,
    PROV2_FIELD_HIS_DATA1_H,
    PROV2_FIELD_HIS_DATA1_L,
    PROV2_FIELD_HIS_DATA2_H,
    PROV2_FIELD_HIS_DATA2_L,
    PROV2_FIELD_HIS_SEQUENCE = PROV2_FIELD_STABLE,
    PROV2_FIELD_HIS_TOTAL,
    
    PROV2_FIELD_CHECKSUM
} PKTFieldV2;

typedef enum
{
    WTFLAG_KG_PLUS = 1,
    WTFLAG_LB_PLUS,
    WTFLAG_KG_MINUS,
    WTFLAG_LB_MINUS,
    WTFLAG_OVERLOAD,
    WTFLAG_OZ_PLUS,
    WTFLAG_LBOZ_PLUS,
    WTFLAG_OZ_MINUS,
    WTFLAG_LBOZ_MINUS
} WeightFlag;

typedef enum
{
    SIGV2_FIELD_PREAMBLE = 0,
    SIGV2_FIELD_CMDWORD,
    
    SIGV2_FIELD_UID,
    
    SIGV2_FIELD_YEAR = SIGV2_FIELD_UID,
    SIGV2_FIELD_DAY_H,
    SIGV2_FIELD_DAY_L,
    SIGV2_FIELD_HOUR,
    SIGV2_FIELD_MINUTE,
    SIGV2_FIELD_SECOND,
    
    SIGV2_FIELD_CHECKSUM
} SIGFieldV2;

typedef enum
{
    // TX
    CMDV2_ADD_USER          = 0x50,
    CMDV2_RMV_USER          = 0x51,
    CMDV2_SEL_USER          = 0x52,
    CMDV2_SYNC_TIME         = 0x60,
    CMDV2_SYNC_DATA_NEW     = 0x61,
    CMDV2_SYNC_DATA_ALL     = 0x6A,
    
    // RX
    CMDV2_HISTORY_DATA      = 0x75,
    CMDV2_IMMEDIATE_DATA    = 0xA5,
    
    CMDV2_END = 0xFF
} CMDCodeV2;

typedef struct stPROV2IMDATA
{
    CGFloat mtrWeight;
    CGFloat brWeight;
    CGFloat mtrHeight;
    
    Byte    flag;
    
} PROV2IMDATA;

typedef struct stPROV2HISDATA
{
    Byte    userID;
    Byte    year;
    ushort  dayOfYear;
    CGFloat mtrWeight;
    CGFloat brWeight;
    CGFloat mtrHeight;
    Byte    sequence;
    Byte    total;
    
} PROV2HISDATA;

#define MakeKgWeight(g) ((CGFloat)(g) / 1000.0)
#define MakeLbWeight(b) ((CGFloat)(b) / 100.0)
#define MakeCmHeight(mm) ((CGFloat)(mm) / 10.0)

@interface COMMprotocol : NSObject

@property (nonatomic, assign) NSUInteger version;

- (id)initWithPacket:(NSData *)packet;
- (void)setPacket:(NSData *)packet;

- (BOOL)isPacketIllegal;
- (BOOL)isSignalIllegal;

- (BOOL)isWeightPacket;
- (BOOL)isHeightPacket;
- (CGFloat)getWeight;
- (CGFloat)getHeight;

- (BOOL)isImmediateData;
- (BOOL)isHistoryData;
- (PROV2IMDATA)getImmediateData;
- (PROV2HISDATA)getHistoryData;

- (BOOL)isUserAddSIG;
- (BOOL)isUserRemoveSIG;
- (BOOL)isUserSelectSIG;
- (BOOL)isTimeSyncSIG;
- (BOOL)isHistorySyncSIG;

+ (NSData *)makeAddUserSIG:(NSUInteger)uID;
+ (NSData *)makeRemoveUserSIG:(NSUInteger)uID;
+ (NSData *)makeSelectUserSIG:(NSUInteger)uID;
+ (NSData *)makeSyncNewRecordSIG:(NSUInteger)uID;
+ (NSData *)makeSyncAllRecordSIG:(NSUInteger)uID;
+ (NSData *)makeSyncTimeSIG;

@end
