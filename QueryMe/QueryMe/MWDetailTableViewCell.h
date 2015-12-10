//
//  MWDetailTableViewCell.h
//  QueryMe
//
//  Created by Ryan Walker on 12/10/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface MWDetailTableViewCell : UITableViewCell

- (void) configureCell:(MWDetailTableViewCell *)cell withObject:(PFObject *)object;
+ (CGFloat) heightForBasicCellWithObject:(PFObject *)object andWidth:(CGFloat)width;

@end
