//
//  MWTableViewCell.h
//  QueryMe
//
//  Created by Ryan Walker on 11/30/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI.h>

@interface MWTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet PFImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *questionText;
@property (strong, nonatomic) IBOutlet UILabel *answerCountText;
@property (strong, nonatomic) IBOutlet UILabel *questionInterestIndicator;

@end
