//
//  MWDetailTableViewCell.h
//  QueryMe
//
//  Created by Ryan Walker on 12/10/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWProfileImageView.h"
#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@class MWDetailTableViewCell;

@protocol MWDetailTableViewCellDelegate <NSObject>

@optional
- (void) userTappedProfilePictureInCell:(MWDetailTableViewCell *)cell;

@end

@interface MWDetailTableViewCell : UITableViewCell

@property (strong, nonatomic) MWProfileImageView *profilePicture;

- (void) configureCell:(MWDetailTableViewCell *)cell withObject:(PFObject *)object;
+ (CGFloat) heightForBasicCellWithObject:(PFObject *)object andWidth:(CGFloat)width;

@property (weak, nonatomic) id<MWDetailTableViewCellDelegate> delegate;

@end
