//
//  MWTableViewCell.h
//  QueryMe
//
//  Created by Ryan Walker on 11/30/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWProfileImageView.h"
#import <UIKit/UIKit.h>
#import <ParseUI.h>

@class MWTableViewCell;

@protocol MWTableViewCellDelegate <NSObject>

@optional
- (void) userTappedProfilePictureInCell:(MWTableViewCell *)cell;

@end

@interface MWTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UILabel *questionText;
@property (strong, nonatomic) MWProfileImageView *profilePicture;

- (void) configureCell:(MWTableViewCell *)cell withObject:(PFObject *)object;
+ (CGFloat)heightForBasicCellWithObject:(PFObject *)object andWidth:(CGFloat)width;

@property (weak, nonatomic) id<MWTableViewCellDelegate> delegate;

@end
