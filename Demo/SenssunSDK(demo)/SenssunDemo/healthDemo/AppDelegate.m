#import "AppDelegate.h"
#import "DeviceSearchController.h"  


@implementation AppDelegate

@synthesize bleMgr = _bleMgr;

- (SSBLEDeviceManager *)bleMgr {
    if (!_bleMgr) {
        _bleMgr = [[SSBLEDeviceManager alloc] initWithDeviceTypes:@[
                                                                    @(SSBLESENSSUNBODY),
                                                                    //@(SSBLESENSSUNBODYCLOCK),
                                                                    @(SSBLESENSSUNFAT),
                                                                    //@(SSBLESENSSUNFATCLOCK),
                                                                    //@(SSBLESENSSUNSUPERFAT),
                                                                    //@(SSBLESENSSUNHEART),
                                                                    //@(SSBLESENSSUNFOOD),
                                                                    @(SSBLESENSSUNGROWTH)
                                                                    ]
                                                          rssiMin:-127];
    }
    return _bleMgr;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _bleMgr = [self bleMgr];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    DeviceSearchController *vc = [[DeviceSearchController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.navigationBarHidden = YES;
    [self.window setRootViewController:navVC];

    [self.window makeKeyAndVisible];

    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //[self.bleMgr disconnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //[self.bleMgr connect];
}

@end
