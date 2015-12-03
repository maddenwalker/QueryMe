//
//  MWProfileImageView.m
//  QueryMe
//
//  Created by Ryan Walker on 12/3/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWProfileImageView.h"

@implementation MWProfileImageView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.image = [UIImage imageNamed:@"emptyProfilePicture"];
        self.frame = CGRectMake(0, 0, 50, 50);
        self.layer.cornerRadius = 25;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (BOOL) setProfilePictureToUser:(MWUser *)user {
    
    if ([user[@"profilePictureExists"] boolValue]) {
        PFFile *profilePicture = user[@"profilePicture"];
        self.file = profilePicture;
        [self loadInBackground];
        return YES;
    }
    
    return NO;
}

@end
