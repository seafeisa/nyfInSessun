//
//  AppDelegate.m
//  grow
//
//  Created by admin on 15-3-3.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

//static enum LangueType _Langue = LangueTypeNone;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //dbgLog(@"applicationWillResignActive");
    [AppData writeToFile];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //dbgLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //dbgLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //dbgLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //dbgLog(@"applicationWillTerminate");
    [AppData writeToFile];
}

//+ (enum LangueType)getLangue{
//    NSLog(@"判断语言");
//    if (_Langue == LangueTypeNone) {
//        NSArray *langues = [NSLocale preferredLanguages];
//        NSString *currentLangue = [langues objectAtIndex:0];
//        if ([currentLangue hasPrefix:@"zh-Hans"]) {
//            _Langue = LangueTypeCN;
//        } else if ([currentLangue rangeOfString:@"zh-Hant"].length > 0 ||[currentLangue rangeOfString:@"zh-HK"].length > 0||[currentLangue rangeOfString:@"zh-TW"].length > 0){
//            _Langue = LangueTypeCN;
//        } else if ([currentLangue rangeOfString:@"ar"].length > 0){
//            _Langue = LangueTypeEN;
//        } else if ([currentLangue rangeOfString:@"de"].length > 0){
//            _Langue = LangueTypeEN;
//        } else if ([currentLangue rangeOfString:@"es"].length > 0){
//            _Langue = LangueTypeEN;
//        } else if ([currentLangue rangeOfString:@"it"].length > 0){
//            _Langue = LangueTypeEN;
//        } else if ([currentLangue rangeOfString:@"ja"].length > 0){
//            _Langue = LangueTypeEN;
//        } else if ([currentLangue rangeOfString:@"ko"].length > 0){
//            _Langue = LangueTypeEN;
//        } else if ([currentLangue rangeOfString:@"pt"].length > 0){
//            _Langue = LangueTypeEN;
//        } else if ([currentLangue rangeOfString:@"ru"].length > 0){
//            _Langue = LangueTypeEN;
//        } else if ([currentLangue rangeOfString:@"tr"].length > 0){
//            _Langue = LangueTypeEN;
//        } else if ([currentLangue rangeOfString:@"fr"].length > 0){
//            _Langue = LangueTypeEN;
//        } else if ([currentLangue rangeOfString:@"en"].length > 0||[currentLangue rangeOfString:@"en-AU"].length > 0||[currentLangue rangeOfString:@"en-GB"].length > 0){
//            _Langue = LangueTypeEN;
//        } else {
//            _Langue = LangueTypeEN;
//        }
//    }
//    
//    return _Langue;
//    
//}
//
//+ (NSString *)getString:(NSString *)key{
//    NSLog(@"写入plist");
//    [AppDelegate getLangue];
//    NSString *filename = nil;
//    if (_Langue == LangueTypeCN) {
//        filename = @"CN";
//    } else if (_Langue == LangueTypeTW){
//        filename = @"TW";
//    } else if (_Langue == LangueTypeEN){
//        filename =@"EN";
//    }
//    //    filename = @"CN";
//    NSString *path = [[NSBundle mainBundle]pathForResource:filename     ofType:@"plist"];
//    NSLog(@"==%@==",[Fileoperator getResourceValue:path :key]);
//    return [Fileoperator getResourceValue:path :key];
//    
//}

@end
