//
//  HITAppDelegate.m
//  HITFIT_5
//
//  Created by 蒋晟 on 14-10-10.
//  Copyright (c) 2014年 himyself. All rights reserved.
//

#import "HITAppDelegate.h"
#import "HITTabBarController.h"

@implementation HITAppDelegate

@synthesize walkChartShouldRefresh, weightChartShouldRefresh, fatChartShouldRefresh;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [MobClick startWithAppkey:@"54470316fd98c5c34200f318" reportPolicy:SEND_INTERVAL   channelId:@"Web"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    //以下是添加友盟测试设备生成id用
//    Class cls = NSClassFromString(@"UMANUtil");
//    SEL deviceIDSelector = @selector(openUDIDString);
//    NSString *deviceID = nil;
//    if(cls && [cls respondsToSelector:deviceIDSelector]){
//        deviceID = [cls performSelector:deviceIDSelector];
//    }
//    NSLog(@"{\"oid\": \"%@\"}", deviceID);
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        NSLog(@"first launch第一次程序启动");
        //  [self.viewController setNsstilt:@"这是第一次启动"];
        //== 这里开始你可以放入引导画面了! ==//
        UIStoryboard *mainStoryBoard  = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HITTabBarController *initView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"UserInfoSetViewController"];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = initView;
        [self.window makeKeyAndVisible];
    }else {
        NSLog(@"second launch再次程序启动");
        //  [self.viewController setNsstilt:@"这是程序的N次启动"];

    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
