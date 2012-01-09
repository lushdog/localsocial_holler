//
//  LocalSocialAppDelegate.m
//  LocalSocial
//
//  Created by Matthew Moore on 11-07-29.
//  Copyright 2011 Matt Moore. All rights reserved.
//

#import "AppDelegate.h"
#import "SendMessageViewController.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = __rootViewController;
@synthesize sendMessageViewController = __sendMessageViewController;
@synthesize deviceTokenString = __deviceTokenString;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.sendMessageViewController = [[SendMessageViewController alloc] initWithNibName:@"SendMessageViewController" bundle:[NSBundle mainBundle]];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.sendMessageViewController];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.deviceTokenString = [[[[deviceToken description]
                                   stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                  stringByReplacingOccurrencesOfString: @">" withString: @""]
                                 stringByReplacingOccurrencesOfString: @" " withString: @""];
    [self.sendMessageViewController registerToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // get state
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        NSString *message = nil;
        id alertDict = [userInfo objectForKey:@"aps"];
        id alert = [alertDict objectForKey:@"alert"];
        if ([alert isKindOfClass:[NSString class]]) {
            message = alert;
        } else if ([alert isKindOfClass:[NSDictionary class]]) {
            message = [alert objectForKey:@"body"];
        }
        if (alert) {
            //TODO: if a ton of hollers coming in how can you do anything if the app is open?
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Holler!"
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Continue"
                                                      otherButtonTitles:nil];   
            [alertView show];
        }
    }
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
