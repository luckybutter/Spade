//
//  SearchViewController
//  Spade
//
//  Created by Matthew Canoy on 2/18/15.
//  Copyright (c) 2015 Luckybutter. All rights reserved.
//

#import "SearchViewController.h"
#import <Fabric/Fabric.h>
#import "TwitterBar.h"
#import <TwitterKit/TwitterKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/AFNetworking.h>

#define RIPPLE_DURATION 0.70
#define RIPPLE_DELAY (RIPPLE_DURATION/2.0)
#define TWITTER_BUTTON_DISAPPEAR_DISTANCE 20

NSString* const twitterSearchURL = @"https://api.twitter.com/1.1/search/tweets.json";

@interface SearchViewController () {
    UIView* whiteLayer;
    UIView* lightPrimary;
    AFHTTPRequestOperationManager *manager;
}

@property (weak, nonatomic) IBOutlet TWTRLogInButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet TwitterBar *twitterSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterSearchBarBVS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterButtonBVS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterButtonH;

@end

@implementation SearchViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    int screenHeight = [UIScreen mainScreen].bounds.size.height+100;
    whiteLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenHeight, screenHeight)];
    whiteLayer.layer.cornerRadius = whiteLayer.bounds.size.width / 2.0;
    whiteLayer.backgroundColor = UIColor.whiteColor;
    
    lightPrimary = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenHeight, screenHeight)];
    lightPrimary.backgroundColor =  LIGHT_PRIMARY_COLOR;
    lightPrimary.layer.cornerRadius = lightPrimary.bounds.size.width / 2.0;
    
    [self.view addSubview:lightPrimary];
    [self.view addSubview:whiteLayer];
    [self.view bringSubviewToFront:_loginButton];
    
    lightPrimary.center = whiteLayer.center = self.view.center;
    lightPrimary.layer.anchorPoint = CGPointMake(0.5, 0.5);
    whiteLayer.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    _twitterButton.layer.cornerRadius = _twitterButton.bounds.size.width / 2.0;
    _twitterButton.transform = CGAffineTransformMakeScale(0.001, 0.001);
    _twitterButtonBVS.constant = self.view.height/2-_twitterButtonH.constant/2;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _twitterSearchBar.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_twitterSearchBar setLeftViewMode:UITextFieldViewModeAlways];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button setImage:[UIImage imageNamed:@"twitterWhite"] forState:UIControlStateNormal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [button addTarget:self action:@selector(twitterSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    _twitterSearchBar.leftView = button;
    
    manager = [AFHTTPRequestOperationManager manager];
    //logging out everytime for ease
//    [[Twitter sharedInstance] logOut];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    _twitterSearchBarBVS.constant = keyboardSize.height;
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_twitterSearchBar layoutIfNeeded];
        _twitterSearchBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    _twitterSearchBarBVS.constant = 0;
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_twitterSearchBar layoutIfNeeded];
        _twitterSearchBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        _twitterButtonBVS.constant = 10;
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_twitterButton layoutIfNeeded];
            _twitterButton.alpha = 1.0;
        } completion:^(BOOL finished) {
            _twitterButton.userInteractionEnabled = YES;
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([Twitter sharedInstance].session == nil) {
        _loginButton.hidden = false;
        _loginButton.logInCompletion =  ^(TWTRSession *session, NSError *error) {
            if (session) {
                NSLog(@"signed in as %@", [session userName]);
                [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    _loginButton.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [self ripple];
                }];
            } else {
                NSLog(@"error: %@", [error localizedDescription]);
            }
        };
    } else {
        [self ripple];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ripple {
    //Rippling effect with circles
    [UIView animateWithDuration:RIPPLE_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        whiteLayer.transform = CGAffineTransformMakeScale(0.001, 0.001);
    } completion: ^(BOOL finished) {
        [whiteLayer removeFromSuperview];
    }];

    [UIView animateWithDuration:RIPPLE_DURATION delay:RIPPLE_DELAY options:UIViewAnimationOptionCurveEaseInOut animations:^{
        lightPrimary.transform = CGAffineTransformMakeScale(0.001, 0.001);
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [lightPrimary removeFromSuperview];
        
        [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _twitterButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _twitterButton.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                _twitterButtonBVS.constant = 10;
                [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [_twitterButton layoutIfNeeded];
                } completion:^(BOOL finished) {
                    _twitterButton.userInteractionEnabled = YES;
                }];
            }];
        }];
    }];
}

- (IBAction)startSearch:(id)sender {
    _twitterButton.userInteractionEnabled = NO;
    _twitterButtonBVS.constant = -10;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_twitterButton layoutIfNeeded];
        _twitterButton.alpha = 0.0;
    } completion:^(BOOL finished) {
//        _twitterSearchBarBVS.constant += _twitterSearchBar.height;
        _twitterSearchBar.hidden = NO;
        _twitterSearchBar.alpha = 0.0;
//        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            [_twitterSearchBar layoutIfNeeded];
//        } completion:^(BOOL finished) {
            [_twitterSearchBar becomeFirstResponder];
//        }];
    }];
}

- (void)twitterSearch:(UIButton*)sender {
    
    if(_twitterSearchBar.text.length) {
        NSError* error = nil;
        NSURLRequest* request = [[Twitter sharedInstance].APIClient URLRequestWithMethod:@"GET" URL:twitterSearchURL parameters:@{@"q":_twitterSearchBar.text} error:&error];
        if (error == nil) {
            [[Twitter sharedInstance].APIClient sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (connectionError == nil) {
                    NSError* serializationError = nil;
                    NSDictionary* jsonData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
                    if (serializationError == nil) {
                        NSLog(@"%@ %@", response, jsonData.description);
                    }
                } else {
                    
                }
                
            }];
        }
        } else {
            
        }
}


#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Fetched results controller


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return NO;
}

@end
