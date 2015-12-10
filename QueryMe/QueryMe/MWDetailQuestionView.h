//
//  MWDetailQuestionView.h
//  QueryMe
//
//  Created by Ryan Walker on 12/10/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MWDetailQuestionView : UIView

- (void) configureViewwithObject:(PFObject *)object;

@end
