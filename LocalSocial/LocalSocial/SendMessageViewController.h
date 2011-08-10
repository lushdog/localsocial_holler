//
//  LocalSocialViewController.h
//  LocalSocial
//
//  Created by Matthew Moore on 11-07-29.
//  Copyright 2011 Matt Moore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendMessageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (strong, nonatomic) UITextView *text;
@property (strong, nonatomic) UIButton *send;
@property (strong, nonatomic) UIButton *done;
@property (strong, nonatomic) UIButton *info;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlay;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator; 

-(IBAction)sendText:(id)sender;
-(void)sendMessageWithText:(NSString*)text;
-(void)setLoadingViewVisible:(BOOL)isVisible;

@end
