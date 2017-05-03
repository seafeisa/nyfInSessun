//
//  Record.m
//  ChildGrowth
//
//  Created by admin on 14-12-3.
//  Copyright (c) 2014年 camry. All rights reserved.
//

#import "Record.h"
#import "UserList.h"

@interface Record ()

@end

@implementation Record

@synthesize measureDate = _measureDate;

- (id)initWithName:(NSString *)userName
{
    self = [super init];
    if (self)
    {
        [self initialize];
        _userName = userName;
    }
    
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
//    NSLog(@"64");
    _measureDate = midnightOfDate([NSDate date]);
    _height      = 0.0;
    _weight      = 0.0;
    _weightLB    = 0.0;
    _weightOZ    = 0.0;
    _headCircle  = 0.0;
    _unit = @"kg";
}

- (NSDateComponents *)ageWithBirthday:(NSDate *)birthday
{
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    return [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
//                       fromDate:midnightOfDate(birthday)
//                         toDate:midnightOfDate(_measureDate)
//                        options:NSWrapCalendarComponents];
    return calcAge(birthday, _measureDate);
}

- (NSDate *)measureDate
{
    return midnightOfDate(_measureDate);
}

- (void)setMeasureDate:(NSDate *)aDate
{
    _measureDate = midnightOfDate(aDate);
}

- (CGFloat)BMI
{
    CGFloat BMI = -1;
    
    if (0 != _height)
    {
        BMI = _weight / sqrtf(_height / 100);
    }
    
    return BMI;
}

- (NSComparisonResult)compareRecordByDate:(Record *)other
{
    dbgLog(@"compare %@ %@", self.measureDate ,other.measureDate);
    return [self.measureDate compare:other.measureDate];
}

@end
