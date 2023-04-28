//
//  AppDelegate.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 25/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "CSLRfidAppEngine.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [CSLRfidAppEngine sharedAppEngine];
    
    //override default transparent background after iOS 15
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = UIColorFromRGB(0x1F4788);
        appearance.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        
        [[UINavigationBar appearance] setStandardAppearance:appearance];
        [[UINavigationBar appearance] setScrollEdgeAppearance:[[UINavigationBar appearance] standardAppearance]];
    }

    
    [[UIBarButtonItem appearance] setTintColor:UIColorFromRGB(0xFFFFFF)];
    
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x1F4788)];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 0);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           UIColorFromRGB(0xFFFFFF), NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"Lato-Bold.ttf" size:25.0], NSFontAttributeName, nil]];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    //power off reader and disconnect before closing application
    if ([CSLRfidAppEngine sharedAppEngine].reader) {
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==CONNECTED)
        {
            [[CSLRfidAppEngine sharedAppEngine].reader barcodeReader:false];
            [[CSLRfidAppEngine sharedAppEngine].reader powerOnRfid:false];
            [[CSLRfidAppEngine sharedAppEngine].reader disconnectDevice];
        }
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}

@end
