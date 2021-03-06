//
//  QuestionDetailTableViewController.h
//  QueryMe
//
//  Created by Ryan Walker on 12/9/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "MWKeyboardBarView.h"
#import "MWDetailTableViewCell.h"

@interface QuestionDetailTableViewController : PFQueryTableViewController <MWKeyboardBarViewDelegate, MWDetailTableViewCellDelegate>

@property (strong, nonatomic) PFObject *questionObject;

@end
