//
//  AppDelegate.m
//  CustomPasscode
//
//  Created by Mickey on 2017/12/22.
//  Copyright © 2017年 Mickey. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "PasscodeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController *vc = [[ViewController alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = self.navController;
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([PasscodeViewController doesPasscodeExist]) {
            [self showLockView];
        }
    });

    return YES;
}

- (void)showLockView {
    if ([self isPasscodeViewControllerExist]) return;

    PasscodeViewController *vc = [[PasscodeViewController alloc] init];
    vc.passcodeStatus = PASSCODE_LAUNCHAPP;
    vc.isUsingBiometrics = [PasscodeViewController allowUnlockWithBiometrics];
    __weak PasscodeViewController *wvc = vc;
    vc.dismissBlockValue = ^() {
        [wvc.navigationController dismissViewControllerAnimated:YES completion:nil];
    };
    UINavigationController *masterNav = [[UINavigationController alloc] initWithRootViewController:vc];
    UIViewController *topController = [self getVisibleViewControllerFrom:self.window.rootViewController];
    [topController presentViewController:masterNav animated:YES completion:nil];
    [vc showTouchIDUnlock];
}

- (BOOL)isPasscodeViewControllerExist {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getUIViewControllerStackFrom:self.window.rootViewController array:&array];

    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:array];
    for (NSInteger i=tempArray.count-1; i>= 0; i--) {
        [array removeObjectAtIndex:i];
        UIViewController *vc = [tempArray objectAtIndex:i];
        if ([vc isKindOfClass:[PasscodeViewController class]]) {
            return YES;
        }
    }

    return NO;
}

- (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

- (UIViewController *)getUIViewControllerStackFrom:(UIViewController *)vc array:(NSMutableArray **)arrayPtr {
    NSMutableArray *array = (*arrayPtr);
    if (vc) {
        [array addObject:vc];
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getUIViewControllerStackFrom:[((UINavigationController *) vc) visibleViewController] array:arrayPtr];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getUIViewControllerStackFrom:[((UITabBarController *) vc) selectedViewController] array:arrayPtr];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        return [self getUIViewControllerStackFrom:[((UISplitViewController *) vc).viewControllers objectAtIndex:0] array:arrayPtr];
    } else {
        if (vc.presentedViewController) {
            return [self getUIViewControllerStackFrom:vc.presentedViewController array:arrayPtr];
        } else {
            return vc;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([PasscodeViewController doesPasscodeExist]) {
        [self showLockView];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
