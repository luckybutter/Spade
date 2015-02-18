//
//  SearchViewController
//  Spade
//
//  Created by Matthew Canoy on 2/18/15.
//  Copyright (c) 2015 Luckybutter. All rights reserved.
//

#import "SearchViewController.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    if ([Twitter sharedInstance].session == nil) {
//        _loginButton.logInCompletion =  ^(TWTRSession *session, NSError *error) {
//            if (session) {
//                NSLog(@"signed in as %@", [session userName]);
//            } else {
//                NSLog(@"error: %@", [error localizedDescription]);
//            }
//        };
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
