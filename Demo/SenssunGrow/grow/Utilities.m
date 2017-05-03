//
//  Utilities.m
//  grow
//
//  Created by admin on 15-3-26.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "Utilities.h"
//#import "AppData.h"

@implementation Utilities


#pragma mark - DateTime
NSString* stringFromTime(NSDate *date)
{
    // 设置日期格式及时区
    //NSTimeZone *GMTzone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    return [dateFormatter stringFromDate:date];
}

NSString* stringFromDate(NSDate *date)
{
    // 设置日期格式及时区
    //NSTimeZone *GMTzone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:date];
}

NSDate* dateFromString(NSString *dateString)
{
    // 设置日期格式及时区
    //NSTimeZone *GMTzone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter dateFromString:dateString];
}

NSDate* midnightOfDate(NSDate *date)
{
    // 设置日期格式及GMT时区
    //NSTimeZone *GMTzone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // 格式化日期字符串
    NSString *dateString = [dateFormatter stringFromDate:date];
    // 将字符串转换为时间（0点整点）
    return [dateFormatter dateFromString:dateString];
}

NSDate* monthOfDate(NSDate *date)
{
    NSCalendar   *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:date];
    
    return [calendar dateFromComponents:comp];
}

NSDate* monthFromString(NSString *string)
{
    NSMutableString *fmt = [NSMutableString stringWithString:@"yyyy"];
    
    NSString *Year = [AppData getString:@"year"];
    NSString *Month = [AppData getString:@"Yue"];
    
    [fmt appendString:Year/*LOCALSTR_YEAR*/];
    [fmt appendString:@"MM"];
    [fmt appendString:Month/*LOCALSTR_MONTH*/];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    //[dateFormatter setDateFormat:fmt];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    
    return [dateFormatter dateFromString:string];
}

NSString* stringFromMonth(NSDate *month)
{
    NSMutableString *fmt = [NSMutableString stringWithString:@"yyyy"];
    
    NSString *Yearfmt = [AppData getString:@"year"];
    NSString *Monthfmt = [AppData getString:@"Yue"];
    
    [fmt appendString:Yearfmt/*LOCALSTR_YEAR*/];
    [fmt appendString:@"MM"];
    [fmt appendString:Monthfmt/*LOCALSTR_MONTH*/];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    //[dateFormatter setDateFormat:fmt];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    
    return [dateFormatter stringFromDate:month];
}


NSDateComponents* calcAge(NSDate *startDate, NSDate *endDate)
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    return [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                       fromDate:midnightOfDate(startDate)
                         toDate:midnightOfDate(endDate)
                        options:NSCalendarWrapComponents];
}

BOOL isSameMonth(NSDate *oneDate, NSDate *otherDate)
{
    NSUInteger unitFlag = NSCalendarUnitYear | NSCalendarUnitMonth;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:oneDate];
    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:otherDate];
    
    return ((comp1.year == comp2.year) && (comp1.month == comp2.month));
}

#pragma mark temp
// 获取本地时间
NSDate* localeDateTime()
{
    NSDate * seldate = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: seldate];
    NSDate * date = [seldate dateByAddingTimeInterval: interval];
    
    return date;
}

#define kDEFAULT_DATETIME_FORMAT (@"yyyy-MM-dd HH:mm:ss'Z'")
// 把字符串转换成NSDate
NSDate* NSStringDateToNSDate(NSString *string)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:kDEFAULT_DATETIME_FORMAT];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

// 把本地时间转换成字符串
NSString* localDateTimeString()
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:kDEFAULT_DATETIME_FORMAT];
    NSDate *now = localeDateTime();
    
    //    NSDateComponents *comp = [[NSDateComponents alloc] init];
    //    comp.year  = 2015;
    //    comp.month = 4;
    //    comp.day   = 21;
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    //    NSDate *date = [calendar dateFromComponents:comp];
    //    dbgLog(@"%@ -> %@", stringFromDate(date), stringFromDate([date dateByAddingTimeInterval:40*7*24*60*60]));
    return  [formatter stringFromDate: now];
}

#pragma mark - Plist
NSDictionary* readPlist(NSString *filename)
{
    // 读取.plist中的数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    //dbgLog(@"%@:\r\n%@",[plistPath lastPathComponent],data);
    
    return data;
}

void writePlist(NSString *filename, NSDictionary *data)
{
    // 载入配置文件
    //NSString *plistPath = [NSString stringWithFormat:@"%@/config.plist",[[Globals getResourceManager] getResPath]];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    //dbgLog(@"writing to %@ ...", [plistPath lastPathComponent]);
    NSMutableDictionary *source = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    // 修改数据
    [source setValuesForKeysWithDictionary:data];
    
    // 写入文件
    [source writeToFile:plistPath atomically:YES];
    //dbgLog(@"done!")
}

@end
