//
//  MWLoginViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 11/20/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWLoginViewController.h"
#import <PFFacebookUtils.h>

@interface MWLoginViewController ()

@end

@implementation MWLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor grayColor];
    label.text = @"Q/me";
    label.numberOfLines = 1;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:50];
    label.adjustsFontSizeToFitWidth = YES;
    [label sizeToFit];
    self.logInView.logo = label;
    
    
}


- (void)_loginWithFacebook {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
        } else {
            NSLog(@"User logged in through Facebook!");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
