//
//  UserProfile.m
//  ChildGrowth
//
//  Created by admin on 14-9-23.
//  Copyright (c) 2014年 camry. All rights reserved.
//

#import "DBMgr.h"
#import "UserProfile.h"

#define FMT_USER_PORTRAIT(username) [NSString stringWithFormat:@"IMG_PORTRAIT_%@.png", username]

@implementation UserProfile
{
    DBMgr   *m_db;
    UIImage *m_portraitImage;
}

@synthesize birthday = _birthday;

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        // Initialize self.
        [self initialize];
        self.name = name;
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
//    NSLog(@"63");
    //  引用数据库对象
    m_db = [DBMgr sharedInstance];
    
    // 初始化数据列表
    _recordList = [[NSMutableDictionary alloc] init];
    _diaryBooks = [[NSMutableDictionary alloc] init];
    //[self restoreFromDb];
    
    self.portrait   = IMG_DEFAULT_USERICON_L;
    self.birthday   = midnightOfDate([NSDate date]);
    self.gender     = GENDER_MALE;
    self.themeIndex = THEME_ID_DEFAULT;
    self.devMSlot   = DEV_MSLOT_MIN;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnit) name:UnitDidChangedNotification object:nil];
    [self updateUnit];
//    self.unit = @"kg";
    
    m_portraitImage = nil;
}
#pragma mark 接到单位切换的通知后会调用此方法
-(void)updateUnit {
    self.currentUnit = [[NSUserDefaults standardUserDefaults] stringForKey:CurrentUnitKey];
    
    if ([self.currentUnit isEqualToString:@"kilogramUnit"]) {
       self.unit = @"kg";
    }
    else if ([self.currentUnit isEqualToString:@"lbUnit"]) {
        self.unit = @"lb";
    }
    else if ([self.currentUnit isEqualToString:@"ozUnit"]) {
        self.unit = @"oz";
    }
    else if ([self.currentUnit isEqualToString:@"lbUnito"]) {
        self.unit = @"lb:oz";
    }
    else {
        self.unit = @"kg";
    }
//    [self saveUserUnit:self.unit];
//    NSLog(@"userprofile:==%@==",self.unit);
}

- (UIColor *)themeColor
{
    return [UserProfile colorOfTheme:self.themeIndex];
}

- (NSDate *)birthday
{
    return midnightOfDate(_birthday);
}

- (void)setBirthday:(NSDate *)birthday
{
    _birthday = midnightOfDate(birthday);
}

- (NSDateComponents *)ageWithDate:(NSDate *)date
{
    return calcAge(self.birthday, date);
}

- (NSString *)ageOnDate:(NSDate *)date
{
    NSDateComponents * ageComponents = calcAge(self.birthday, date);
    
    //NSString *descString = [NSString stringWithFormat:@"%ld%@%ld%@%ld%@", (long)ageComponents.year, LOCALSTR_AGE_YEAR, (long)ageComponents.month, LOCALSTR_AGE_MONTH, (long)ageComponents.day, LOCALSTR_AGE_DAY];
    NSString *descString = [NSString string];
    
    if (0 != ageComponents.year)
    {
        descString = [descString stringByAppendingFormat:@"%ld%@", (long)ageComponents.year, [AppData getString:@"yearold"]/*LOCALSTR_AGE_YEAR*/];
        //获取对应的文字信息
    }

    if (0 != ageComponents.month)
    {
        if (ageComponents.month > 1) {
            descString = [descString stringByAppendingFormat:@"%ld%@", (long)ageComponents.month, [AppData getString:@"yues"]/*LOCALSTR_AGE_MONTHS*/];
        } else {
            descString = [descString stringByAppendingFormat:@"%ld%@", (long)ageComponents.month, [AppData getString:@"yues"]/*LOCALSTR_AGE_MONTH*/];
        }
    }
    
    if ((0 != ageComponents.day) || ((0 == ageComponents.year) && (0 == ageComponents.month)))
    {
        descString = [descString stringByAppendingFormat:@"%ld%@", (long)ageComponents.day, [AppData getString:@"days"]/*LOCALSTR_AGE_DAY*/];
    }
    
    return descString;
}

- (BOOL)isDefaultPortrait
{
    return ([self.portrait isEqualToString:IMG_DEFAULT_USERICON_L] ||
            [self.portrait isEqualToString:IMG_DEFAULT_USERICON_S]);
}

- (UIImage *)defaultPortrait:(ENIconSize)size
{
    NSArray *names = @[IMG_DEFAULT_USERICON_S, IMG_DEFAULT_USERICON_L];
    return [UIImage imageNamed:[names objectAtIndex:size]];
}

- (UIImage *)portraitImage
{
    return m_portraitImage;
}

- (void)setPortraitImage:(UIImage *)image
{
    self.portrait   = FMT_USER_PORTRAIT(self.name);
    m_portraitImage = image;
}

- (void)savePortraitImage
{
    if ([self isDefaultPortrait])
    {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
    ^{
        [[AppData sharedInstance] savePortraitImage:m_portraitImage imageName:self.portrait];
        
        // 保存到沙盒
        //NSString *imgName = [NSString stringWithFormat:FMT_USER_PORTRAIT, self.name];
        NSString *imgPath = [[AppData sandboxDir] stringByAppendingPathComponent:self.portrait];
        NSData *data = UIImagePNGRepresentation(m_portraitImage);
        [data writeToFile:imgPath atomically:NO];
    }
    );
}

- (void)loadPortraitImage
{
    if ([self isDefaultPortrait])
    {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    ^{
        UIImageOrientation orient = [[AppData sharedInstance] portraitOrientForImage:self.portrait];
        
        // 载入图片文件
        //NSString *imgName = [NSString stringWithFormat:FMT_USER_PORTRAIT, self.name];
        NSString *imgPath = [[AppData sandboxDir] stringByAppendingPathComponent:self.portrait];
        UIImage *image    = [UIImage imageWithContentsOfFile:imgPath];
        m_portraitImage   = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:orient];
    }
    );
}

#pragma mark - Record
- (NSMutableDictionary *)recordList
{
    if (nil == _recordList)
    {
        _recordList = [[NSMutableDictionary alloc] init];
    }
    
    return _recordList;
}

- (NSArray *)sortRecordKeys
{
    // Ascending
    //return [[self.recordList allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    // Descending
    NSArray *array = [[self.recordList allKeys] sortedArrayUsingComparator:
                      ^NSComparisonResult(id obj1, id obj2)
                      {
                          NSDate *date1 = obj1;
                          NSDate *date2 = obj2;
                          return (NSOrderedSame - [date1 compare:date2]);
                      }];
    
    return array;
}

- (Record *)getRecordByKey:(NSDate *)key
{
    return [self.recordList objectForKey:midnightOfDate(key)];
}

- (Record *)getRecordByIndex:(NSInteger)index
{
    return [self.recordList objectForKey:[[self sortRecordKeys] objectAtIndex:index]];
}

- (void)addRecord:(Record *)record
{
    [self.recordList setObject:record forKey:record.measureDate];
    
    if (![m_db addRecord:record])
    {
        dbgLog(@"failed to save[%@ %@] to db", record.userName, record.measureDate);
    }
    [m_db dump];
}

- (void)addRecordWithWeight:(CGFloat)weight height:(CGFloat)height headcircle:(CGFloat)headcircle weightOZ:(CGFloat)weightOZ
{
    Record *record = [[Record alloc] initWithName:self.name];
    record.weight  = weight;
    record.height  = height;
    record.headCircle = headcircle;
    record.weightOZ = weightOZ;////////////////////
    
    [self.recordList setObject:record forKey:record.measureDate];
    
    if (![m_db addRecord:record])
    {
        dbgLog(@"failed to save[%@ %@] to db", record.userName, record.measureDate);
    }
    [m_db dump];
}

- (void)setRecord:(Record *)oldRecord withNew:(Record *)newRecord
{
    [self.recordList removeObjectForKey:oldRecord.measureDate];

    [self.recordList setObject:newRecord forKey:newRecord.measureDate];
    
    if (![m_db mergeRecord:oldRecord with:newRecord])
    {
        dbgLog(@"failed to update[%@ %@] to db", oldRecord.userName, oldRecord.measureDate);
    }
    [m_db dump];
}

- (void)delRecord:(Record *)record
{
    [self.recordList removeObjectForKey:record.measureDate];
    
    if (![m_db deleteRecord:record.measureDate fromUser:record.userName])
    {
        dbgLog(@"failed to delete[%@ %@] from db", record.userName, record.measureDate);
    }
    [m_db dump];
}

- (void)saveUserUnit:(NSString *)unit {
    self.unit = unit;
    
//    NSLog(@"unit===%@==  self.unit==%@",unit,self.unit);
    if (![m_db saveUserUnit:self.name :unit]) {
        dbgLog(@"failed to save[%@ %@] from db", self.name, self.unit);
    }
    [m_db dump];
}

#pragma mark - Diary

- (NSMutableDictionary *)diaryBooks
{
    if (nil == _diaryBooks)
    {
        _diaryBooks = [[NSMutableDictionary alloc] init];
    }
    
    return _diaryBooks;
}

- (NSArray *)sortDiaryKeys
{
    // Descending
    NSArray *array = [[self.diaryBooks allKeys] sortedArrayUsingComparator:
                      ^NSComparisonResult(id obj1, id obj2)
                      {
                          NSDate *date1 = obj1;
                          NSDate *date2 = obj2;
                          return (NSOrderedSame - [date1 compare:date2]);
                      }];
    
    return array;
}

- (DiaryBook *)getDiaryByKey:(NSDate *)key
{
    return [self.diaryBooks objectForKey:monthOfDate(key)];
}

- (DiaryBook *)getDiaryByIndex:(NSInteger)index
{
    id key = [[self sortDiaryKeys] objectAtIndex:index];
    return [self.diaryBooks objectForKey:key];
}

- (void)addDiaryBook:(DiaryBook *)obj
{
    [self.diaryBooks setObject:obj forKey:obj.month];
}

- (void)setDiaryBook:(DiaryBook *)oldBook withNew:(DiaryBook *)newBook
{
    [self.diaryBooks removeObjectForKey:oldBook.month];
    
    [self.diaryBooks setObject:newBook forKey:newBook.month];
}

- (void)delDiaryBook:(DiaryBook *)obj
{
    [self.diaryBooks removeObjectForKey:obj.month];
}

#pragma mark - Utilities
+ (NSString *)titleOfGender:(ENGender)gender
{
    NSString *boy = [AppData getString:@"babyboy"];
    NSString *girl = [AppData getString:@"babygirl"];
    
    NSArray *titles = @[boy,girl];/* @[LOCALSTR_GENDER_BOY,
                        LOCALSTR_GENDER_GIRL];*/
    
    return [titles objectAtIndex:gender];
}

+ (NSString *)titleOfTheme:(ENThemeID)theme
{
    NSString *purple = [AppData getString:@"purple"];
    NSString *green = [AppData getString:@"green"];
    NSString *yellow = [AppData getString:@"yellow"];
    
    NSArray *titles = @[purple,green,yellow];/*@[LOCALSTR_THEME_PURPLE,
                        LOCALSTR_THEME_GREEN,
                        LOCALSTR_THEME_YELLOW];*/
    
    return [titles objectAtIndex:theme];
}

+ (NSString *)titleOfDevMSlot:(ENDevMSlot)slot
{
    NSString *userOne = [AppData getString:@"oneuser"];
    NSString *userTwo = [AppData getString:@"twouser"];
    NSString *userThree = [AppData getString:@"threeuser"];
    NSString *userFour = [AppData getString:@"fouruser"];
    NSString *userFive = [AppData getString:@"fiveuser"];
    NSString *userSix = [AppData getString:@"sixuser"];
    NSString *userSeven = [AppData getString:@"sevenuser"];
    NSString *userEight = [AppData getString:@"eightuser"];
    
    NSArray *titles = @[userOne,
                        userTwo,
                        userThree,
                        userFour,
                        userFive,
                        userSix,
                        userSeven,
                        userEight];/*@[LOCALSTR_DEVMEM_SLOT1,
                        LOCALSTR_DEVMEM_SLOT2,
                        LOCALSTR_DEVMEM_SLOT3,
                        LOCALSTR_DEVMEM_SLOT4,
                        LOCALSTR_DEVMEM_SLOT5,
                        LOCALSTR_DEVMEM_SLOT6,
                        LOCALSTR_DEVMEM_SLOT7,
                        LOCALSTR_DEVMEM_SLOT8];*/
    
    return [titles objectAtIndex:(slot - 1)];
}

+ (UIImage *)iconOfGender:(ENGender)gender
{
    NSArray *images = @[IMG_PROFILE_BOY,
                        IMG_PROFILE_GIRL];
    
    return [UIImage imageNamed:[images objectAtIndex:gender]];
}

+ (UIImage *)iconOfTheme:(ENThemeID)theme
{
    NSArray *images = @[IMG_THEME_PURPLE,
                        IMG_THEME_GREEN,
                        IMG_THEME_YELLOW];
    
    return [UIImage imageNamed:[images objectAtIndex:theme]];
}

+ (UIImage *)iconOfDevMSlot:(ENDevMSlot)slot
{
    NSArray *images = @[IMG_PROFILE_DEVMSLOT,
                        IMG_PROFILE_DEVMSLOT,
                        IMG_PROFILE_DEVMSLOT];
    
    return [UIImage imageNamed:[images objectAtIndex:0]];
}

+ (UIColor *)colorOfTheme:(ENThemeID)theme
{
    NSArray *colors = @[COLOR_THEME_PURPLE,
                        COLOR_THEME_GREEN,
                        COLOR_THEME_YELLOW];
    
    return [colors objectAtIndex:theme];
}

@end
