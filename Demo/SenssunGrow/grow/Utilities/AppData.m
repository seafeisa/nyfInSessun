//
//  AppData.m
//  grow
//
//  Created by admin on 15-5-22.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "AppData.h"
#import "Fileoperator.h"


#define CURRENT_USER_KEY    @"currentUser"
#define PORTRAIT_ORIENT_KEY(imageName)  [NSString stringWithFormat:@"orient_%@", imageName]
#define COVER_ORIENT_KEY(imageName)     [NSString stringWithFormat:@"cover_%@", imageName]
#define PHOTO_ORIENT_KEY(imageName)     [NSString stringWithFormat:@"photo_%@", imageName]
#define DIARY_BOOK_KEY(userName)        [NSString stringWithFormat:@"diaryBook_%@", userName]
#define DIARY_MONTH_KEY     @"diaryMonth"
#define DIARY_COVER_KEY     @"diaryCover"
#define DIARY_PAGES_KEY     @"diaryPages"
#define SHEET_DATE_KEY      @"sheetDate"
#define SHEET_TEXT_KEY      @"sheetText"
#define SHEET_PHOTOS_KEY    @"sheetPhotos"
#define BACKGND_IMAGE_KEY   @"backgndImage"
#define BACKIMG_ORIENT_KEY  @"backimgOrient"
#define GUIDE_PRESENT_KEY   @"theGuideIsPresented"

@implementation AppData
{
    UIImage *m_backgroundImage;
}
static enum LangueType _Langue = LangueTypeNone;
#pragma getLangue-plist

+ (enum LangueType)getLangue{
//    NSLog(@"222");
    if (_Langue == LangueTypeNone) {
        NSArray *langues = [NSLocale preferredLanguages];
        NSString *currentLangue = [langues objectAtIndex:0];
        if ([currentLangue hasPrefix:@"zh-Hans"]) {
            _Langue = LangueTypeCN;
        } else if ([currentLangue rangeOfString:@"zh-Hant"].length > 0 ||[currentLangue rangeOfString:@"zh-HK"].length > 0||[currentLangue rangeOfString:@"zh-Hant-TW"].length > 0){
            _Langue = LangueTypeTW;
        } else if ([currentLangue rangeOfString:@"ar"].length > 0){
            _Langue = LangueTypeEN;
        } else if ([currentLangue rangeOfString:@"de"].length > 0){
            _Langue = LangueTypeEN;
        } else if ([currentLangue rangeOfString:@"es"].length > 0){
            _Langue = LangueTypeEN;
        } else if ([currentLangue rangeOfString:@"it"].length > 0){
            _Langue = LangueTypeEN;
        } else if ([currentLangue rangeOfString:@"ja"].length > 0){
            _Langue = LangueTypeEN;
        } else if ([currentLangue rangeOfString:@"ko"].length > 0){
            _Langue = LangueTypeKO;
        } else if ([currentLangue rangeOfString:@"pt"].length > 0){
            _Langue = LangueTypeEN;
        } else if ([currentLangue rangeOfString:@"ru"].length > 0){
            _Langue = LangueTypeEN;
        } else if ([currentLangue rangeOfString:@"tr"].length > 0){
            _Langue = LangueTypeEN;
        } else if ([currentLangue rangeOfString:@"fr"].length > 0){
            _Langue = LangueTypeEN;
        } else if ([currentLangue rangeOfString:@"en"].length > 0||[currentLangue rangeOfString:@"en-AU"].length > 0||[currentLangue rangeOfString:@"en-GB"].length > 0){
            _Langue = LangueTypeEN;
        } else {
            _Langue = LangueTypeEN;
        }
    }
    
    return _Langue;
    
}

+ (NSString *)getString:(NSString *)key{
//    NSLog(@"111");
    [AppData getLangue];
    NSString *filename = nil;
    if (_Langue == LangueTypeCN) {
        filename = @"Chinese";
    } else if (_Langue == LangueTypeTW){
        filename = @"Traditional";
    } else if (_Langue == LangueTypeEN){
        filename = @"English";
    } else if (_Langue == LangueTypeKO){
        filename = @"Korean";
    }
    //    filename = @"Chinese";
    NSString *path = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
    
//    NSLog(@"==%@==",[Fileoperator getResourceValue:path :key]);
    return [Fileoperator getResourceValue:path :key];
    
}


- (id)init
{
    self = [super init];
    if (self) {
        m_backgroundImage = nil;
    }
    return self;
}

- (UIImage *)backgndImage
{
    if (nil == m_backgroundImage)
    {
        m_backgroundImage = [self loadBackgndImage];
    }
    return m_backgroundImage;
}

- (void)setBackgndImage:(UIImage *)image
{
    m_backgroundImage = image;
    
    [self saveBackgndImage:image];
}

- (UIImage *)loadBackgndImage
{
//    NSLog(@"56");
    UIImageOrientation orient = [[NSUserDefaults standardUserDefaults] integerForKey:BACKIMG_ORIENT_KEY];
    NSData  *data = [[NSUserDefaults standardUserDefaults] dataForKey:BACKGND_IMAGE_KEY];
    
    UIImage *image = [UIImage imageWithData:data];
    
    image = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:orient];
    
    return image;
}

- (void)saveBackgndImage:(UIImage *)image
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        
        NSLog(@"one global queue  can put out data that will take how much time");
        
    });
    
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    ^{
        NSData *data = UIImagePNGRepresentation(image);
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:BACKGND_IMAGE_KEY];
        [[NSUserDefaults standardUserDefaults] setInteger:image.imageOrientation forKey:BACKIMG_ORIENT_KEY];
    }
    );
}

- (UIImageOrientation)portraitOrientForImage:(NSString *)imageName
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:PORTRAIT_ORIENT_KEY(imageName)];
}

- (void)savePortraitImage:(UIImage *)image imageName:(NSString *)imageName
{
    [[NSUserDefaults standardUserDefaults] setInteger:image.imageOrientation forKey:PORTRAIT_ORIENT_KEY(imageName)];
}

- (UIImageOrientation)coverOrientForImage:(NSString *)imageName
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:COVER_ORIENT_KEY(imageName)];
}

- (void)saveCoverImage:(UIImage *)image imageName:(NSString *)imageName
{
    [[NSUserDefaults standardUserDefaults] setInteger:image.imageOrientation forKey:COVER_ORIENT_KEY(imageName)];
}

- (UIImageOrientation)photoOrientForImage:(NSString *)imageName
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:PHOTO_ORIENT_KEY(imageName)];
}

- (void)savePhotoImage:(UIImage *)image imageName:(NSString *)imageName
{
    [[NSUserDefaults standardUserDefaults] setInteger:image.imageOrientation forKey:PHOTO_ORIENT_KEY(imageName)];
}

- (BOOL)isGuidePresented
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GUIDE_PRESENT_KEY];
}

- (void)markGuidePresent
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GUIDE_PRESENT_KEY];
}

+ (AppData *)sharedInstance
{
    static AppData *s_appData = nil;
    
    if (nil == s_appData)
    {
        s_appData = [[AppData alloc] init];
    }
    return s_appData;
}





// 获取应用的沙盒路径 .../Documents
+ (NSString *)sandboxDir
{
   /******   查看MainEnglish Listplist的路径 **** /Users/admin/Library/Developer/CoreSimulator/Devices/E715A479-4490-4080-B229-B5C3DFE24405/data/Containers/Bundle/Application/74958BED-295D-402B-9F25-5210DB67690E/grow.app/MainEnglish List.plist ******/
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"MainEnglish List" ofType:@"plist"];
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    
    
//    NSFileManager *file=[NSFileManager defaultManager];
//    
//    if ([file fileExistsAtPath:path]) {
//        NSLog(@"%@",path);
//    }
//    else
//    {
//        NSLog(@"错误");
//    }
    
//    NSLog(@"11111111111");
    
    
//    NSLog(@"%@",NSHomeDirectory());
    
//    NSLog(@"%@ %lu",path,(unsigned long)dict.count);
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}
+ (BOOL)writeToFile
{
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)currentUser
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:CURRENT_USER_KEY];
}

+ (void)saveCurrentUser:(NSString *)userName
{
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:CURRENT_USER_KEY];
}

+ (NSDictionary *)diaryBooksForUser:(NSString *)userName
{
    NSMutableDictionary *diaryBooks = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *bookList = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:DIARY_BOOK_KEY(userName)];
    for (NSDictionary *book in bookList)
    {
        DiaryBook *diary = [[DiaryBook alloc] init];
        diary.month     = [book objectForKey:DIARY_MONTH_KEY];
        diary.imageName = [book objectForKey:DIARY_COVER_KEY];
        [diary loadCoverImage];
        
        NSArray *pageList = [book objectForKey:DIARY_PAGES_KEY];
        for (NSDictionary *page in pageList)
        {
            DiaryPage *sheet = [[DiaryPage alloc] init];
            sheet.date = [page objectForKey:SHEET_DATE_KEY];
            sheet.text = [page objectForKey:SHEET_TEXT_KEY];
            sheet.imageList = [NSMutableArray arrayWithArray:[page objectForKey:SHEET_PHOTOS_KEY]];
            [sheet loadPhotos];
            
            [diary addDiarySheet:sheet];
        }
        
        [diaryBooks setObject:diary forKey:diary.month];
    }
    
    return diaryBooks;
}

+ (void)saveDiaryBook:(DiaryBook *)diary forUser:(NSString *)userName
{
    NSMutableArray *bookList = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:DIARY_BOOK_KEY(userName)];
    
    NSUInteger count = [bookList count];
    NSUInteger index = NSNotFound;
    for (NSUInteger i = 0; i < count; i++)
    {
        NSDictionary *book = [bookList objectAtIndex:i];
        
        // look for the diarybook
        if ([diary.month isEqualToDate:[book objectForKey:DIARY_MONTH_KEY]])
        {
            index = i;
            break;
        }
    }
    
    NSMutableArray *pageList = [[NSMutableArray alloc] init];
    NSArray *sheets = [diary.diaryList allValues];
    for (DiaryPage *sheet in sheets)
    {
        NSArray *photoList = [NSArray arrayWithArray:sheet.imageList];
        
         NSDictionary *page = [NSDictionary dictionaryWithObjectsAndKeys:
                              sheet.date, SHEET_DATE_KEY,
                              sheet.text, SHEET_TEXT_KEY,
                              photoList,  SHEET_PHOTOS_KEY,
                              nil];
        [pageList addObject:page];
    }
    NSArray *pages = [NSArray arrayWithArray:pageList];
    
    NSDictionary *bookObj = [NSDictionary dictionaryWithObjectsAndKeys:
                             diary.month,     DIARY_MONTH_KEY,
                             diary.imageName, DIARY_COVER_KEY,
                             pages,           DIARY_PAGES_KEY,
                             nil];
    
    if (NSNotFound == index)
    {
        [bookList addObject:bookObj];
    }
    else
    {
        // object exist
        [bookList replaceObjectAtIndex:index withObject:bookObj];
    }
}

+ (void)removeDiaryBook:(DiaryBook *)diary withUser:(NSString *)userName
{
    NSMutableArray *bookList = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:DIARY_BOOK_KEY(userName)];
    
    NSUInteger count = [bookList count];
    for (NSUInteger i = 0; i < count; i++)
    {
        NSDictionary *book = [bookList objectAtIndex:i];
        
        // look for the diarybook
        if ([diary.month isEqualToDate:[book objectForKey:DIARY_MONTH_KEY]])
        {
            [bookList removeObjectAtIndex:i];
            break;
        }
    }
}

+ (void)removeAllDiarysOfUser:(NSString *)userName
{
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:DIARY_BOOK_KEY(userName)];

    NSMutableArray *bookList = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:DIARY_BOOK_KEY(userName)];
    [bookList removeAllObjects];
}

//+ (void)saveDiarySheet:(DiaryPage *)sheet forUser:(NSString *)userName
//{
//    // book
//    NSMutableArray *bookList = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:userName];
//    
//    NSDate *diaryMonth = monthOfDate(sheet.date);
//    NSUInteger booksCount = [bookList count];
//    NSUInteger bookIndex  = NSNotFound;
//    for (NSUInteger i = 0; i < booksCount; i++)
//    {
//        NSDictionary *book = [bookList objectAtIndex:i];
//        
//        // look for the diarybook
//        if ([diaryMonth isEqualToDate:[book objectForKey:DIARY_MONTH_KEY]])
//        {
//            bookIndex = i;
//            break;
//        }
//    }
//    
//    NSDictionary *bookObj;
//    if (NSNotFound == bookIndex)
//    {
//        DiaryBook *diary = [[DiaryBook alloc] init];
//        diary.month = diaryMonth;
//        
//        NSArray *pages = [[NSArray alloc] init];
//
//        bookObj = [NSDictionary dictionaryWithObjectsAndKeys:
//                   diary.month,     DIARY_MONTH_KEY,
//                   diary.imageName, DIARY_COVER_KEY,
//                   pages,           DIARY_PAGES_KEY,
//                   nil];
//        [bookList addObject:bookObj];
//    }
//    else
//    {
//        // object exist
//        bookObj = [bookList objectAtIndex:bookIndex];
//    }
//    
//    // sheet
//    NSArray *pageList = [bookObj objectForKey:DIARY_PAGES_KEY];
//    
//    NSUInteger pagesCount = [pageList count];
//    NSUInteger pageIndex  = NSNotFound;
//    for (NSUInteger i = 0; i < pagesCount; i++)
//    {
//        NSDictionary *page = [pageList objectAtIndex:i];
//        
//        // look for the diarysheet
//        if ([sheet.date isEqualToDate:[page objectForKey:SHEET_DATE_KEY]])
//        {
//            pageIndex = i;
//            break;
//        }
//    }
//    
//    NSArray *photoList = [NSArray arrayWithArray:sheet.imageList];
//    NSDictionary *pageObj = [NSDictionary dictionaryWithObjectsAndKeys:
//                             sheet.date, SHEET_DATE_KEY,
//                             sheet.text, SHEET_TEXT_KEY,
//                             photoList,  SHEET_PHOTOS_KEY,
//                             nil];
//    
//    if (NSNotFound == pageIndex)
//    {
//        <#statements#>
//    }
//    else
//    {
//        <#statements#>
//    }
//}

@end
