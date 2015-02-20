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
NSString* const TweetTableReuseIdentifier = @"TweetCell";
NSString* const archiveKey = @"savedTweet";
NSString* const entityName = @"Tweets";

@interface SearchViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TWTRTweetViewDelegate, UIScrollViewDelegate> {
    UIView* whiteLayer;
    UIView* lightPrimary;
    AFHTTPRequestOperationManager *manager;
    
    NSArray* savedTweets;
}

@property (weak, nonatomic) IBOutlet TWTRLogInButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet TwitterBar *twitterSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterSearchBarBVS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterButtonBVS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterButtonH;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TweetTableReuseIdentifier];
    savedTweets = [[NSArray alloc] init];
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
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height+_twitterSearchBar.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
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
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
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
        _twitterSearchBar.hidden = NO;
        _twitterSearchBar.alpha = 0.0;
        [_twitterSearchBar becomeFirstResponder];
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
                        
                        NSArray* tweetArray = jsonData[@"statuses"];
                        if (tweetArray.count) {
                            [_twitterSearchBar resignFirstResponder];
                            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                            NSError *error = nil;
                            if (![self.fetchedResultsController performFetch:&error]) {
                                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            } else {
                                if (self.fetchedResultsController.fetchedObjects.count) { //Update
                                    [self easyFetchAndModify:jsonData];
                                } else { //Just insert
                                    [self insertNewObject:jsonData];
                                }
                            }
                        } else {
                            //Display to the user, no results for X text
                        }
                        
                    }
                } else {
                    
                }
                
            }];
        }
    } else {
            
    }
}

- (void)easyFetchAndModify:(NSDictionary*)json {
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    
    //No need for predicate since I only ever have to store one object
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:archiveKey ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError* error;
    NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error == nil){
        NSArray* tweetArray = [TWTRTweet tweetsWithJSONArray:json[@"statuses"]];
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:tweetArray forKey:archiveKey];
        [archiver finishEncoding];
        
        NSManagedObject* objectToModify = results[0];
        [objectToModify setValue:data forKey:archiveKey];
        
        // Save the context.
        NSError *error = nil;
        if (![self.fetchedResultsController.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    } else {
        
    }
        
}

- (void)insertNewObject:(NSDictionary*)json {
    
    NSArray* tweetArray = [TWTRTweet tweetsWithJSONArray:json[@"statuses"]];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:tweetArray forKey:archiveKey];
    [archiver finishEncoding];
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue:data forKey:archiveKey];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return savedTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TweetTableReuseIdentifier forIndexPath:indexPath];
    [cell configureWithTweet:savedTweets[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = savedTweets[indexPath.row];
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweets" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:archiveKey ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSError* error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else {
        if (self.fetchedResultsController.fetchedObjects.count == 1) {
            NSData *data = [[NSMutableData alloc] initWithData:[self.fetchedResultsController.fetchedObjects[0] valueForKey:archiveKey]];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            NSArray *tweetArray=[unarchiver decodeObjectForKey:archiveKey];
            [unarchiver finishDecoding];
            savedTweets = tweetArray;
            
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if(y> h-100) {
        _twitterButton.userInteractionEnabled = NO;
        _twitterButton.alpha = (h-y)/100.0;
    } else {
        _twitterButton.alpha = 1.0;
        _twitterButton.userInteractionEnabled = YES;
    }
}

@end
