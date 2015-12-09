//
//  AddQuestionViewController.h
//  QueryMe
//
//  Created by Ryan Walker on 12/3/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddQuestionViewControllerDelegate <NSObject>

@optional

- (void) questionSuccessfullySubmittedToParse;

@end

@interface AddQuestionViewController : UIViewController

@property (weak, nonatomic) id <AddQuestionViewControllerDelegate> delegate;

@end
