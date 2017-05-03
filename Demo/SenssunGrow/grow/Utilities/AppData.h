//
//  AppData.h
//  grow
//
//  Created by admin on 15-5-22.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Diary.h"



enum LangueType{
    LangueTypeNone=0,
    LangueTypeCN=1,
    LangueTypeTW=2,
    LangueTypeEN=3,
    LangueTypeAR = 4,
    LangueTypeDE = 5,
    LangueTypeES = 6,
    LangueTypeIT = 7,
    LangueTypeJA = 8,
    LangueTypeKO = 9,
    LangueTypePT = 10,
    LangueTypeRU = 11,
    LangueTypeTR = 12,
    LangueTypeFR = 13,
    
};





@interface AppData : NSUserDefaults


#pragma langueType

+ (enum LangueType)getLangue;
+(NSString *)getString:(NSString *)key;
/*******/
+ (AppData *)sharedInstance;

+ (NSString *)sandboxDir;

+ (BOOL)writeToFile;

+ (NSString *)currentUser;
+ (void)saveCurrentUser:(NSString *)userName;

+ (NSDictionary *)diaryBooksForUser:(NSString *)userName;
+ (void)saveDiaryBook:(DiaryBook *)diary forUser:(NSString *)userName;
+ (void)removeDiaryBook:(DiaryBook *)diary withUser:(NSString *)userName;
+ (void)removeAllDiarysOfUser:(NSString *)userName;

- (UIImage *)backgndImage;
- (void)setBackgndImage:(UIImage *)image;

- (UIImageOrientation)portraitOrientForImage:(NSString *)imageName;
- (void)savePortraitImage:(UIImage *)image imageName:(NSString *)imageName;

- (UIImageOrientation)coverOrientForImage:(NSString *)imageName;
- (void)saveCoverImage:(UIImage *)image imageName:(NSString *)imageName;

- (UIImageOrientation)photoOrientForImage:(NSString *)imageName;
- (void)savePhotoImage:(UIImage *)image imageName:(NSString *)imageName;

- (BOOL)isGuidePresented;
- (void)markGuidePresent;

@end
