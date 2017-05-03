//
//  DBMgr.h
//  ChildGrowth
//
//  Created by admin on 14-10-15.
//  Copyright (c) 2014年 camry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "Record.h"
#import "UserProfile.h"

@interface DBMgr : NSObject

// 数据库操作对象，封装SQLite API
@property (nonatomic, readonly)  FMDatabase * m_db;

// 单实例
+ (DBMgr *)sharedInstance;

// 关闭数据库
- (BOOL)dbClose;

/**
 * @brief 添加一条用户记录
 * @param user 需要添加的用户数据
 * @return YES/NO
 */
- (BOOL)addUser:(UserProfile *)user;

/**
 * @brief 删除一条用户数据
 * @param uname 需要删除用户的名字
 * @return YES/NO
 */
- (BOOL)deleteUser:(NSString *)uname;

/**
 * @brief 修改用户的信息
 * @param user 需要修改的用户信息
 * @return YES/NO
 */
- (BOOL)mergeUser:(NSString *)name with:(UserProfile *)user;

/**
 * @brief 添加一条测量记录
 * @param record 需要添加的测量数据
 * @return YES/NO
 */
- (BOOL)addRecord:(Record *)record;

/**
 * @brief 删除一条测量记录
 * @param measureDate 记录日期
 * @param uname 记录对应的用户名
 * @return YES/NO
 */
- (BOOL)deleteRecord:(NSDate *)measureDate fromUser:(NSString *)userName;

/**
 * @brief 修改记录
 * @param source 修改前的记录信息
 * @param target 修改后的记录信息
 * @return YES/NO
 */
- (BOOL)mergeRecord:(Record *)source with:(Record *)target;

- (BOOL)saveUserUnit:(NSString *)userName :(NSString *)unit;
/**
 * @brief 加载用户记录
 * @param
 * @return NSArray 用户列表
 */
- (NSArray *)restoreUsers;

/**
 * @brief 加载用户的测量记录
 * @param user 用户
 * @return NSDictionary 用户的测量记录列表
 */
- (NSMutableDictionary *)restoreRecordsOfUser:(NSString *)userName;

- (void)dump;

@end
