//
//  Diary.h
//  grow
//
//  Created by admin on 15-5-11.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiaryPage : NSObject

@property (nonatomic, strong) NSDate    *date;
@property (nonatomic, strong) NSString  *text;

@property (nonatomic, strong) NSMutableArray *imageList;    // NSString array

//- (NSString *)makePhotosNameForUser:(NSString *)username;
- (NSMutableArray *)photoList;
- (void)addPhoto:(UIImage *)photo forUser:(NSString *)name;
- (void)setPhoto:(UIImage *)photo atIndex:(NSUInteger)index;
- (void)delPhotoAtIndex:(NSUInteger)index;
- (UIImage *)photoAtIndex:(NSUInteger)index;
- (void)copyPhotosFromOther:(DiaryPage *)other;

- (void)savePhotos;
- (void)loadPhotos;

@end

@interface DiaryBook : NSObject

@property (nonatomic, strong) NSDate    *month;
@property (nonatomic, strong) NSString  *imageName;

@property (nonatomic, strong) NSMutableDictionary *diaryList;   // per day

- (NSString *)title;
- (UIImage *)cover;
- (void)setCoverImage:(UIImage *)image forUser:(NSString *)name;
- (void)saveCoverImage;
- (void)loadCoverImage;

- (NSArray *)sortedKeys;
- (DiaryPage *)getSheetByKey:(NSDate *)key;
- (DiaryPage *)getSheetByIndex:(NSInteger)index;

- (void)addDiarySheet:(DiaryPage *)obj;
- (void)setDiarySheet:(DiaryPage *)oldPage withNew:(DiaryPage *)newPage;
- (void)delDiarySheet:(DiaryPage *)obj;

@end

