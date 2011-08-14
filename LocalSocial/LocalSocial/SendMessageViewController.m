//
//  LocalSocialViewController.m
//  LocalSocial
//
//  Created by Matthew Moore on 11-07-29.
//  Copyright 2011 Matt Moore. All rights reserved.
//

#import "SendMessageViewController.h"
#import "InfoViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation SendMessageViewController

@synthesize text = __text;
@synthesize send = __send;
@synthesize tableView = __tableView;
@synthesize activityIndicator = __activityIndicator;
@synthesize loadingOverlay = __loadingOverlay;
@synthesize done = __done;
@synthesize info = __info;
@synthesize dataContainer = __dataContainer;
@synthesize sendMessageConnection = __sendMessageConnection;
@synthesize registerConnection = __registerConnection;


#pragma mark - Table View Stuff

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            
        case 0:
            return 150;
            break;
        case 1:
            return 80;
            break;
        default:
            return 40;
            break;
    }   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
     
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        for (int i = 0; i < [[cell subviews] count]; i++) {
            [[[cell subviews] objectAtIndex:i] removeFromSuperview];
        }
    }
    
    switch (indexPath.row) {
        
        case 0:
            
            self.text = [[UITextView alloc] initWithFrame:CGRectMake(20, 10, 280, 130)];
            self.text.delegate = self;
            self.text.text = @"lalalalalala";
            self.text.editable = YES;
            self.text.font = [UIFont systemFontOfSize:18.0];
            self.text.backgroundColor = [UIColor whiteColor];
            self.text.userInteractionEnabled = YES;
            self.text.textColor = [UIColor blackColor];
            self.text.keyboardType = UIKeyboardTypeTwitter;
            self.text.returnKeyType = UIReturnKeyDefault;
            self.text.enablesReturnKeyAutomatically = YES;
            self.text.layer.borderColor = [UIColor grayColor].CGColor;
            self.text.layer.borderWidth = 0.5;
            
            [cell addSubview:self.text];
            
            break;
        
        case 1:
            
            self.send = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.send.frame = CGRectMake(85, 20, 140, 40);
            [self.send setTitle:@"Broadcast 1KM" forState:UIControlStateNormal];
            [self.send addTarget:self action:@selector(sendText:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview: self.send]; 
 
            break;

        default:
            break;
    }
    
    return cell;
}

#pragma mark - Button Stuff

-(IBAction)sendText:(id)sender
{
    [self.text resignFirstResponder];
    [self sendMessageWithText:self.text.text];
}

-(void)sendMessageWithText:(NSString *)text
{
    [self setLoadingViewVisible:YES];
    NSURL *messageURL = [NSURL URLWithString:@"http://localsocial.appspot.com/message"];
    NSMutableURLRequest *messageRequest = [NSMutableURLRequest requestWithURL:messageURL];
    messageRequest.HTTPMethod = @"POST";
    NSString *messageBody = @"POST Content.......";
    messageRequest.HTTPBody = [messageBody dataUsingEncoding:NSUTF8StringEncoding];
    self.sendMessageConnection = [[NSURLConnection alloc] initWithRequest:messageRequest delegate:self];
}

-(void)setLoadingViewVisible:(BOOL)isVisible
{
    if (isVisible)
    {
        self.loadingOverlay.hidden = NO;
        [self.activityIndicator startAnimating];
    }
    else
    {
        self.loadingOverlay.hidden = YES;
        [self.activityIndicator stopAnimating];
    }
}

-(void)showInfo:(id)sender
{
    InfoViewController *infoViewController = [[InfoViewController alloc]initWithNibName:@"InfoViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:infoViewController animated:YES];
}

#pragma mark - TextView Stuff

- (void)textViewDidBeginEditing:(UITextView *)textView
{   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.done];
}

-(void)closeKeyboard:(id)sender
{
    [self.text resignFirstResponder];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.info];
}

#pragma mark - URL Connection Stuff

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.dataContainer.length = 0;
    
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode >= 400)
        {
            [connection cancel];  // stop connecting; no more delegate messages
            NSDictionary *errorInfo
            = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
                                                  NSLocalizedString(@"Server returned status code %d",@""),
                                                  statusCode]
                                          forKey:NSLocalizedDescriptionKey];
            
            NSString *errorMsg;
            if (connection == self.registerConnection)
                errorMsg = @"Error With Register Server";
            else
                errorMsg = @"Error With Intermediate Push Server";
            
            NSError *statusError
            = [NSError errorWithDomain:errorMsg
                                  code:statusCode
                              userInfo:errorInfo];
            [self connection:connection didFailWithError:statusError];
        }
    }
}
    
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.domain message:[error.userInfo objectForKey:NSLocalizedDescriptionKey] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [alert show];
    [self setLoadingViewVisible:NO];
}
        
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.dataContainer appendData:data];
}

    
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    if (connection == self.registerConnection)
    {}
    
    if (connection == self.sendMessageConnection)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Message sent" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
    }
    
    [self setLoadingViewVisible:NO];
}
    


#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Local Social";
    self.info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [self.info addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.info];
    
    self.done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.done.frame = CGRectMake(0, 0, 60, 20);
    [self.done setTitle:@"Done" forState:UIControlStateNormal];
    [self.done addTarget:self action:@selector(closeKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    NSURL *registerURL = [NSURL URLWithString:@"http://localhost:8080/register"];
    NSMutableURLRequest *registerRequest = [NSMutableURLRequest requestWithURL:registerURL];
    registerRequest.HTTPMethod = @"POST";
    
    NSString *deviceToken = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).deviceTokenString;
    NSString *registerBody = [NSString stringWithFormat:@"version=1&uuid=%@",@"FE66489F304DC75B8D6E8200DFF8A456E8DAEACEC428B427E9518741C92C6660"];
    
    registerRequest.HTTPBody = [registerBody dataUsingEncoding:NSUTF8StringEncoding];
    self.registerConnection = [[NSURLConnection alloc] initWithRequest:registerRequest delegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


#pragma mark - Orientation Stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
