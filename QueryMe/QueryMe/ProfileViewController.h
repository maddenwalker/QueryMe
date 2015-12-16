//
//  ProfileViewController.h
//  QueryMe
//
//  Created by Ryan Walker on 12/11/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWUser.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) MWUser *user;

@end
