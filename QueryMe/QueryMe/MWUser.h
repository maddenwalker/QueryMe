//
//  MWUser.h
//  QueryMe
//
//  Created by Ryan Walker on 11/23/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <Parse/Parse.h>

@interface MWUser : PFUser <PFSubclassing>

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) PFFile *profilePicture;
@property (strong, nonatomic) NSString *profileDescription;

@end
