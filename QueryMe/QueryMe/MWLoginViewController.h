//
//  MWLoginViewController.h
//  QueryMe
//
//  Created by Ryan Walker on 11/20/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@class MWLoginViewController;

@protocol MWLoginVewControllerDelegate <PFLogInViewControllerDelegate>
@optional

-(void)logInViewController:(MWLoginViewController *)logInController didLogInUserWithFacebook:(PFUser *)user;

@end

@interface MWLoginViewController : PFLogInViewController

@property (weak, nonatomic) id <MWLoginVewControllerDelegate> delegate;

@end
