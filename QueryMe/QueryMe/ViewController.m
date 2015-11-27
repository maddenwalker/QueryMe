//
//  ViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 11/20/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "ViewController.h"
#import "MWLoginViewController.h"
#import "MWSignUpViewController.h"
#import "MWUser.h"
#import <Parse/Parse.h>
#import <PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ViewController() <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *profilePictureImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self showProfilePicture];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![MWUser currentUser]) {
        
        //login view controller
        MWLoginViewController *loginViewController = [[MWLoginViewController alloc] init];
        [loginViewController setDelegate:self];
        [loginViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
        [loginViewController setFields:PFLogInFieldsDefault | PFLogInFieldsFacebook ];
        
        //sign up view controller
        MWSignUpViewController *signUpViewController = [[MWSignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        
        [loginViewController setSignUpController:signUpViewController];
        
        [self presentViewController:loginViewController animated:YES completion:NULL];
        
    }
    
}
- (IBAction)userDidPressLogout {
    [PFUser logOut];
}

//MARK: PFLoginViewControllerDelegate Methods

- (BOOL)logInViewController:(MWLoginViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    //checking to see if both fields have been completed to for login
    if (username && password && username.length != 0 && password.length != 0) {
        return YES;
    }
    
    [self showUserAlert:logInController withTitle:@"Missing Information" withMessage:@"Make sure you fill out all of the information!"];
    
    return NO;
    
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)loginViewController:(MWLoginViewController *)loginController didFailToLogInWithError:(NSError*)error {
    NSLog(@"Failed to login with error: %@", error);
}

- (void)loginViewControllerDidCancelLogin:(MWLoginViewController *)loginController {
    NSLog(@"User dismissed login view controller");
    [self.navigationController popViewControllerAnimated:YES];
}


//MARK: PFSignUpViewControllerDelegate Methods

- (BOOL)signUpViewController:(MWSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        [self showUserAlert:signUpController withTitle:@"Missing Information" withMessage:@"Make sure you fill out all of the information!"];
    }
    
    return informationComplete;
}

-(void)signUpViewController:(MWSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewController:(MWSignUpViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to sign up with error: %@", error);
}

- (void)signUpViewControllerDidCancelSignUp:(MWSignUpViewController *)signUpController {
    NSLog(@"Sign up view dismissed by user");
}

//MARK: Helper Methods

- (void)showUserAlert:(UIViewController*)viewController withTitle:(NSString*)title withMessage:(NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (void) showProfilePicture {
    [[MWUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error == nil) {
            self.profilePictureImageView.file = [[MWUser currentUser] objectForKey:@"profilePicture"];
            [self.profilePictureImageView loadInBackground];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
