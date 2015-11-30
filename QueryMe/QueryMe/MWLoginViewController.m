//
//  MWLoginViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 11/20/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWLoginViewController.h"
#import "MWUser.h"
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import <PFFacebookUtils.h>
#import <FBSDKCoreKit.h>
#import <AFNetworking.h>

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
            [self loadFacebookData];
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

- (void) loadFacebookData {
    
    PFUser *currentUser = [MWUser currentUser];

    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, first_name, picture.type(large)"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error == nil) {
            NSDictionary *userInfo = result;
            NSString *firstName = userInfo[@"first_name"];
            NSString *facebookID = userInfo[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithURL:pictureURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error == nil) {
                    PFFile *picture = [PFFile fileWithData:data];
                    currentUser[@"profilePicture"] = picture;
                    [currentUser saveInBackground];
                    currentUser[@"profilePictureExists"] = @(YES);
                }
            }];
            [dataTask resume];
            
            currentUser[@"firstName"] = firstName;
            currentUser[@"facebookID"] = facebookID;
            [currentUser saveInBackground];
        }
    }];
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
