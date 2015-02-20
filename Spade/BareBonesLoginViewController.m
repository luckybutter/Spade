//
//  BareBonesLoginViewController.m
//  Spade
//
//  Created by Matthew Canoy on 2/20/15.
//  Copyright (c) 2015 Luckybutter. All rights reserved.
//

#import "BareBonesLoginViewController.h"
#import <TwitterKit/TwitterKit.h>

@interface BareBonesLoginViewController ()

@property (weak, nonatomic) IBOutlet TWTRLogInButton *standardLogin;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoVS;
@end

@implementation BareBonesLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _standardLogin.logInCompletion =  ^(TWTRSession *session, NSError *error) {
        if (session) {
            [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _standardLogin.alpha = 0.0;
                _logo.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self performSegueWithIdentifier:@"login" sender:self];
            }];
        }
    };
}

- (void)viewDidAppear:(BOOL)animated {
    if ([Twitter sharedInstance].session == nil) {
        _logoVS.constant = 60;
        [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _standardLogin.alpha = 1.0;
            [_logo layoutIfNeeded];
            _logo.alpha = 1.0;
        } completion:nil];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


@end
