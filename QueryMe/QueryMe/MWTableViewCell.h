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

@property (strong, nonatomic) UILabel *questionText;

- (void) configureCell:(MWTableViewCell *)cell withObject:(PFObject *)object;
+ (CGFloat)heightForBasicCellWithObject:(PFObject *)object andWidth:(CGFloat)width;

@end
