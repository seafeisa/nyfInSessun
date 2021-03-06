//
//  Fileoperator.m
//  grow
//
//  Created by admin on 16/5/31.
//  Copyright © 2016年 senssun. All rights reserved.
//

#import "Fileoperator.h"

@implementation Fileoperator

#pragma save load file
+ (NSString*)getResourceValue:(NSString *)resource :(NSString*)key {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:resource];
    NSString *object = [dictionary objectForKey:key];
    if (!object || [object isEqualToString:@""]) {
        object = @"";
    }
    return object;
}

+ (NSString *)getFilePath:(NSString *)directory :(NSString *)fileName {
    return [directory stringByAppendingPathComponent:fileName];;
}

+ (BOOL)createDirectory:(NSString*)directory {
    return [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (NSData *)loadFile:(NSString*)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [NSData dataWithContentsOfFile:path];
    }
    return nil;
}

+ (BOOL)removeFile:(NSString*)path {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+ (void)removeDirectoryFile:(NSString*)directory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:directory error:&error];
    if (!error) {
        for (NSString *file in fileList) {
            NSString *path = [directory stringByAppendingPathComponent:file];
            [fileManager removeItemAtPath:path error:nil];
        }
    }
}

@end
