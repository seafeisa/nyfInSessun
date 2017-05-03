//
//  COMMprotocol.m
//  grow
//
//  Created by admin on 15-6-5.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "COMMprotocol.h"

@implementation COMMprotocol
{
    NSMutableData *m_dataPacket;
}

#pragma mark - Common
- (id)init
{
//    NSLog(@"67");
    self = [super init];
    if (self) {
        self.version = 0;
        m_dataPacket = [NSMutableData data];
    }
    return self;
}

- (id)initWithPacket:(NSData *)packet
{
    self = [super init];
    if (self) {
        self.version = PROTOCOL_V2;
        m_dataPacket = [NSMutableData dataWithData:packet];
    }
    return self;
}

- (void)setPacket:(NSData *)packet
{
    [m_dataPacket setData:packet];
}

- (BOOL)isPacketIllegal
{
    BOOL flag = YES;
    
    switch (self.version)
    {
        case PROTOCOL_V0:
            flag = [self isV0PacketIllegal];
            break;
            
        case PROTOCOL_V2:
            flag = [self isV2PacketIllegal];
            break;
            
        default:
            break;
    }
    
    return flag;
}

- (BOOL)isSignalIllegal
{
    BOOL flag = YES;
    
    switch (self.version)
    {
        case PROTOCOL_V0:
            break;
            
        case PROTOCOL_V2:
            flag = [self isV2SignalIllegal];
            break;
            
        default:
            break;
    }
    
    return flag;
}

#pragma mark - V0
//=============================================================
// v0
- (BOOL)isV0PacketIllegal
{
    if (PROV0_PKT_LEN > m_dataPacket.length)
    {
        return YES;
    }
    
    BOOL rc = YES;
    
    const Byte PROTOCOL_HEAD[] = {PROV0_PREAMBLE, PROV0_PRODUCT_MODULE};
    NSUInteger headLength = sizeof(PROTOCOL_HEAD);
    NSData *proHead = [NSData dataWithBytes:PROTOCOL_HEAD length:headLength];
    //NSData *pktHead = [m_dataPacket subdataWithRange:NSMakeRange(DATA_POS_PREAMBLE, headLength)];
    NSData *pktHead = [NSData dataWithBytes:[m_dataPacket bytes] length:headLength];
    
    if ([pktHead isEqualToData:proHead])
    {
        rc = NO;
    }
    
    return rc;
}

- (BOOL)isWeightPacket
{
    Byte cmd = 0;
    [m_dataPacket getBytes:&cmd range:NSMakeRange(DATA_POS_CMDCODE, sizeof(cmd))];

    return ((CMD_WEIGHT_CHANGING == cmd) || (CMD_WEIGHT_STABLE == cmd));
}

- (BOOL)isHeightPacket
{
    Byte cmd = 0;
    [m_dataPacket getBytes:&cmd range:NSMakeRange(DATA_POS_CMDCODE, sizeof(cmd))];
    
    return ((CMD_HEIGHT_CHANGING == cmd) || (CMD_HEIGHT_STABLE == cmd));
}

- (CGFloat)getWeight
{
    ushort usWeight = 0;
    [m_dataPacket getBytes:&usWeight range:NSMakeRange(DATA_POS_DATA1_H, sizeof(usWeight))];
    usWeight = ntohs(usWeight);
    
    return MakeKgWeight(usWeight);
}

- (CGFloat)getHeight
{
    ushort usHeight = 0;
    [m_dataPacket getBytes:&usHeight range:NSMakeRange(DATA_POS_DATA1_H, sizeof(usHeight))];
    usHeight = ntohs(usHeight);
    
    return MakeCmHeight(usHeight);
}

#pragma mark - V2
//=============================================================
// v2
- (BOOL)isV2PacketIllegal
{
    if (PROV2_PKT_LEN > m_dataPacket.length)
    {
        return YES;
    }
    
    BOOL rc = YES;
    
    const Byte PROTOCOL_HEAD[] = {PROV2_PKT_HEAD};
    NSUInteger headLength = sizeof(PROTOCOL_HEAD);
    NSData *proHead = [NSData dataWithBytes:PROTOCOL_HEAD length:headLength];
    NSData *pktHead = [NSData dataWithBytes:[m_dataPacket bytes] length:headLength];
    
    if ([pktHead isEqualToData:proHead])
    {
        rc = NO;
    }
    
    return rc;
}

- (PROV2IMDATA)getImmediateData
{
    ushort mtrWeight = [self ushortValueAtField:PROV2_FIELD_DATA1_H];
    ushort brWeight  = [self ushortValueAtField:PROV2_FIELD_DATA2_H];
    ushort mtrHeight = [self ushortValueAtField:PROV2_FIELD_DATA3_H];
    Byte   flag      = [self byteValueAtField:PROV2_FIELD_FLAG];
    
    PROV2IMDATA data = {0};
    data.brWeight   = MakeLbWeight(brWeight);
    data.mtrWeight  = MakeKgWeight(mtrWeight);
    data.mtrHeight  = MakeCmHeight(mtrHeight);
    data.flag       = flag;
    
    return data;
}

- (PROV2HISDATA)getHistoryData
{
    ushort mtrWeight = [self ushortValueAtField:PROV2_FIELD_HIS_DATA1_H];
    ushort mtrHeight = [self ushortValueAtField:PROV2_FIELD_HIS_DATA2_H];
    
    PROV2HISDATA data = {0};
    data.userID     = [self byteValueAtField:PROV2_FIELD_USER_ID];
    data.year       = [self byteValueAtField:PROV2_FIELD_HIS_YEAR];
    data.dayOfYear  = [self ushortValueAtField:PROV2_FIELD_HIS_DAY_H];
    data.sequence   = [self byteValueAtField:PROV2_FIELD_HIS_SEQUENCE];
    data.total      = [self byteValueAtField:PROV2_FIELD_HIS_TOTAL];
    data.mtrWeight  = MakeKgWeight(mtrWeight);
    data.mtrHeight  = MakeCmHeight(mtrHeight);
    
    return data;
}

- (BOOL)isImmediateData
{
    Byte cmd = [self byteValueAtField:PROV2_FIELD_CMDWORD];
    //[m_dataPacket getBytes:&cmd range:NSMakeRange(PROV2_FIELD_CMDWORD, sizeof(cmd))];
    
    return (CMDV2_IMMEDIATE_DATA == cmd);
}

- (BOOL)isHistoryData
{
    Byte cmd = [self byteValueAtField:PROV2_FIELD_CMDWORD];
    //[m_dataPacket getBytes:&cmd range:NSMakeRange(PROV2_FIELD_CMDWORD, sizeof(cmd))];
    
    return (CMDV2_HISTORY_DATA == cmd);
}

- (BOOL)isV2SignalIllegal
{
    if (PROV2_SIG_LEN > m_dataPacket.length)
    {
        return YES;
    }
    
    BOOL rc = YES;
    
    const Byte PROTOCOL_HEAD[] = {PROV2_SIG_HEAD};
    NSUInteger headLength = sizeof(PROTOCOL_HEAD);
    NSData *proHead = [NSData dataWithBytes:PROTOCOL_HEAD length:headLength];
    NSData *pktHead = [NSData dataWithBytes:[m_dataPacket bytes] length:headLength];
    
    if ([pktHead isEqualToData:proHead])
    {
        rc = NO;
    }
    
    return rc;
}

- (BOOL)isUserAddSIG
{
    Byte cmd = [self byteValueAtField:PROV2_FIELD_CMDWORD];
    
    return (CMDV2_ADD_USER == cmd);
}

- (BOOL)isUserRemoveSIG
{
    Byte cmd = [self byteValueAtField:PROV2_FIELD_CMDWORD];
    
    return (CMDV2_RMV_USER == cmd);
}

- (BOOL)isUserSelectSIG
{
    Byte cmd = [self byteValueAtField:PROV2_FIELD_CMDWORD];
    
    return (CMDV2_SEL_USER == cmd);
}

- (BOOL)isTimeSyncSIG
{
    Byte cmd = [self byteValueAtField:PROV2_FIELD_CMDWORD];
    
    return (CMDV2_SYNC_TIME == cmd);
}

- (BOOL)isHistorySyncSIG
{
    Byte cmd = [self byteValueAtField:PROV2_FIELD_CMDWORD];
    
    return (CMDV2_SYNC_DATA_ALL == cmd) || (CMDV2_SYNC_DATA_NEW == cmd);
}

+ (NSData *)makeAddUserSIG:(NSUInteger)uID
{
    Byte acData[PROV2_SIG_LEN] = {PROV2_SIG_HEAD, CMDV2_ADD_USER, uID, 0, 0, 0, 0, 0, 0};
//    memset(acData, 0, sizeof(acData));
//    acData[SIGV2_FIELD_PREAMBLE] = PROV2_SIG_HEAD;
//    acData[SIGV2_FIELD_CMDWORD]  = CMDV2_ADD_USER;
//    acData[SIGV2_FIELD_UID]      = uID;
    for (int i = SIGV2_FIELD_CMDWORD; i < SIGV2_FIELD_CHECKSUM; i++)
    {
        acData[SIGV2_FIELD_CHECKSUM] += acData[i];
    }
    
    NSData *data = [NSData dataWithBytes:acData length:PROV2_SIG_LEN];
    return data;
}

+ (NSData *)makeRemoveUserSIG:(NSUInteger)uID
{
    Byte acData[PROV2_SIG_LEN] = {PROV2_SIG_HEAD, CMDV2_RMV_USER, uID, 0, 0, 0, 0, 0, 0};
    for (int i = SIGV2_FIELD_CMDWORD; i < SIGV2_FIELD_CHECKSUM; i++)
    {
        acData[SIGV2_FIELD_CHECKSUM] += acData[i];
    }
    
    NSData *data = [NSData dataWithBytes:acData length:PROV2_SIG_LEN];
    return data;
}

+ (NSData *)makeSelectUserSIG:(NSUInteger)uID
{
    Byte acData[PROV2_SIG_LEN] = {PROV2_SIG_HEAD, CMDV2_SEL_USER, uID, 0, 0, 0, 0, 0, 0};
    for (int i = SIGV2_FIELD_CMDWORD; i < SIGV2_FIELD_CHECKSUM; i++)
    {
        acData[SIGV2_FIELD_CHECKSUM] += acData[i];
    }
    
    NSData *data = [NSData dataWithBytes:acData length:PROV2_SIG_LEN];
    return data;
}

+ (NSData *)makeSyncNewRecordSIG:(NSUInteger)uID
{
    Byte acData[PROV2_SIG_LEN] = {PROV2_SIG_HEAD, CMDV2_SYNC_DATA_NEW, uID, 0, 0, 0, 0, 0, 0};
    for (int i = SIGV2_FIELD_CMDWORD; i < SIGV2_FIELD_CHECKSUM; i++)
    {
        acData[SIGV2_FIELD_CHECKSUM] += acData[i];
    }
    
    NSData *data = [NSData dataWithBytes:acData length:PROV2_SIG_LEN];
    return data;
}

+ (NSData *)makeSyncAllRecordSIG:(NSUInteger)uID
{
    Byte acData[PROV2_SIG_LEN] = {PROV2_SIG_HEAD, CMDV2_SYNC_DATA_ALL, uID, 0, 0, 0, 0, 0, 0};
    for (int i = SIGV2_FIELD_CMDWORD; i < SIGV2_FIELD_CHECKSUM; i++)
    {
        acData[SIGV2_FIELD_CHECKSUM] += acData[i];
    }
    
    NSData *data = [NSData dataWithBytes:acData length:PROV2_SIG_LEN];
    return data;
}

+ (NSData *)makeSyncTimeSIG
{
    NSUInteger flags = NSCalendarUnitYear | NSCalendarUnitDay//| NSCalendarUnitMonth ;
                     | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:flags
                                                              fromDate:dateFromString(@"2000-01-01")
                                                                toDate:[NSDate date]
                                                               options:NSCalendarWrapComponents];
    comps.day++;
    //dbgLog(@"comps:%@",comps);
    
    Byte acData[PROV2_SIG_LEN] = {PROV2_SIG_HEAD, CMDV2_SYNC_TIME, comps.year, comps.day / 256, comps.day % 256, comps.hour, comps.minute, comps.second, 0};
    for (int i = SIGV2_FIELD_CMDWORD; i < SIGV2_FIELD_CHECKSUM; i++)
    {
        acData[SIGV2_FIELD_CHECKSUM] += acData[i];
    }
    
    NSData *data = [NSData dataWithBytes:acData length:PROV2_SIG_LEN];
    return data;
}

#pragma mark - Utility
- (ushort)ushortValueAtField:(PKTFieldV2)field
{
    ushort value = 0;
    [m_dataPacket getBytes:&value range:NSMakeRange(field, sizeof(ushort))];
    NSLog(@"%@", m_dataPacket);
    value = ntohs(value);
    
    return value;
}

- (Byte)byteValueAtField:(PKTFieldV2)field
{
    Byte value = 0;
    [m_dataPacket getBytes:&value range:NSMakeRange(field, sizeof(Byte))];
    
    return value;
}

@end
