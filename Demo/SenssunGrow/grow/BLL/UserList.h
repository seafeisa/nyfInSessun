//
//  UserList.h
//  ChildGrowth
//
//  Created by admin on 14-9-23.
//  Copyright (c) 2014年 camry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"

@interface UserList : NSObject

BOOL isFirstLogin();
BOOL isLogout();

// 对象实例
+ (UserList *)sharedInstance;

// 列表实例
- (NSMutableArray *)kidsArray;

- (UserProfile *)currentKid;

- (void)setCurrentKid:(NSString*)name;
- (void)setCurrentKidForRow:(NSUInteger)row;

- (BOOL)addKid:(UserProfile *)kid;

- (BOOL)rmvKid:(UserProfile *)kid;
- (BOOL)rmvKidForRow:(NSUInteger)row;

- (BOOL)mdfKid:(NSString *)name withObject:(UserProfile *)kid;

- (UserProfile *)kidForName:(NSString *)name;
- (UserProfile *)kidForRow:(NSUInteger)row;
- (NSUInteger)rowForKid:(UserProfile *)kid;
- (NSUInteger)rowForCurrentKid;

- (void)dump;
@end
