//
//  Fileoperator.h
//  grow
//
//  Created by admin on 16/5/31.
//  Copyright © 2016年 senssun. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Fileoperator : NSObject

#pragma save laod file
+ (NSString*)getResourceValue:(NSString *)resource :(NSString*)key;
+ (NSString *)getFilePath:(NSString *)directory :(NSString *)fileName;
+ (BOOL)createDirectory:(NSString*)directory;
+ (NSData *)loadFile:(NSString*)path;
+ (BOOL)removeFile:(NSString*)path;
+ (void)removeDirectoryFile:(NSString*)directory;



@end
