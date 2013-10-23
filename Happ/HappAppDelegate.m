//
//  HappAppDelegate.m
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappAppDelegate.h"

#import "HappViewController.h"
#import "HappModelEnums.h"

@implementation HappAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[HappViewController alloc] initWithNibName:@"HappViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Dismiss any alert that is set to be dismissed on close.
    if (self.alertToDismiss) {
        [self.alertToDismiss dismissWithClickedButtonIndex:0 animated:NO];
    }
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if (!url || !url.host) {
        return NO;
    }
    NSString *realVerificationCode = [[NSUserDefaults standardUserDefaults] objectForKey:VERIFICATION_CODE_KEY];
    if (realVerificationCode && [realVerificationCode isEqualToString:url.host]) {
        // Phone number is verified.
        NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:UNVERIFIED_PHONE_NUMBER_KEY];
        if (phoneNumber) {
            [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:PHONE_NUMBER_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        self.viewController = [[HappViewController alloc] initWithNibName:@"HappViewController" bundle:nil];
        self.window.rootViewController = self.viewController;
        return YES;
    } 
    return NO;
}

@end
