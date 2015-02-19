//
//  TwitterBar.h
//  Spade
//
//  Created by Matthew Canoy on 2/18/15.
//  Copyright (c) 2015 Luckybutter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>

@interface TwitterBar : UIView {

    void (^loginCompletion)(TWTRSession *session, NSError *error);
    
}

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet TWTRLogInButton *loginButton;

@end
