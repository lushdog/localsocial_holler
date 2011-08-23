//
//  LocalSocialViewController.h
//  LocalSocial
//
//  Created by Matthew Moore on 11-07-29.
//  Copyright 2011 Matt Moore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SendMessageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UITextView *text;
@property (strong, nonatomic) UIButton *send;
@property (strong, nonatomic) UIButton *done;
@property (strong, nonatomic) UIButton *info;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator; 
@property (strong, nonatomic) NSMutableData *dataContainer;
@property (strong, nonatomic) NSURLConnection *registerConnection;
@property (strong, nonatomic) NSURLConnection *sendMessageConnection;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSString *senderToken;

-(IBAction)sendText:(id)sender;
-(void)sendMessageWithText:(NSString*)text;
-(void)setLoadingViewVisible:(BOOL)isVisible;
-(void)registerToken;

@end
