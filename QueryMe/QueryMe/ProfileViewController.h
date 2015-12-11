//
//  ProfileViewController.h
//  QueryMe
//
//  Created by Ryan Walker on 12/11/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWUser.h"
#import "MWProfileImageView.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) MWProfileImageView *profileImageView;

@end
