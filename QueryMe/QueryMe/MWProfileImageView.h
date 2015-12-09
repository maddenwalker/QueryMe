//
//  MWProfileImageView.h
//  QueryMe
//
//  Created by Ryan Walker on 12/3/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWUser.h"
#import <ParseUI/ParseUI.h>

@interface MWProfileImageView : PFImageView

- (BOOL) setProfilePictureToUser:(MWUser *)user;

@end
