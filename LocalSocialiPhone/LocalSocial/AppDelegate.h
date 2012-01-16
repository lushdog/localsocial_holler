//
//  LocalSocialAppDelegate.h
//  LocalSocial
//
//  Created by Matthew Moore on 11-07-29.
//  Copyright 2011 Matt Moore. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewMessageViewController;
@class MapViewController;
@class SendMessageViewController;
@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) SendMessageViewController *sendMessageViewController;
@property (strong, nonatomic) ViewMessageViewController *viewMessageViewController;
@property (strong, nonatomic) MapViewController *mapViewController;
@property (strong, nonatomic) NSString *deviceTokenString;

@end
