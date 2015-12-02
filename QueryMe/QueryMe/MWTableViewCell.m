//
//  MWTableViewCell.m
//  QueryMe
//
//  Created by Ryan Walker on 11/30/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWTableViewCell.h"
#import "MWUser.h"
#import <Parse/Parse.h>

@interface MWTableViewCell()

@property (strong, nonatomic) PFImageView *profilePicture;
@property (strong, nonatomic) UILabel *answerCountText;
@property (strong, nonatomic) UILabel *questionInterestIndicator;
@property (strong, nonatomic) NSLayoutConstraint *profilePictureAspectRatioConstraint;

@end

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *answerCountColor;

@implementation MWTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        //Instantiate all of the cell elements
        self.profilePicture = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@"emptyProfilePicture"]];
        self.answerCountText = [[UILabel alloc] init];
        self.questionText = [[UILabel alloc] init];
        self.questionInterestIndicator = [[UILabel alloc] init];
        
        //format cell with profile picture defaults
        self.profilePicture.frame = CGRectMake(0, 0, 50, 50);
        self.profilePicture.layer.cornerRadius = 25;
        self.profilePicture.layer.masksToBounds = YES;
        
        //Format the cell with answers count
        self.answerCountText.font = lightFont;
        self.answerCountText.textColor = [UIColor whiteColor];
        self.answerCountText.backgroundColor = answerCountColor;
        self.answerCountText.layer.borderColor = answerCountColor.CGColor;
        self.answerCountText.textAlignment = NSTextAlignmentCenter;
        self.answerCountText.layer.masksToBounds = YES;
        self.answerCountText.layer.borderWidth = 2.0;
        self.answerCountText.layer.cornerRadius = 8.0;
        
        //Format the Question Text
        self.questionText.font = boldFont;
        self.questionText.numberOfLines = 0;
        
        //Add labels to view
        for (UIView *view in @[self.questionText, self.profilePicture, self.answerCountText, self.questionInterestIndicator]) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_questionText, _profilePicture, _answerCountText, _questionInterestIndicator);
        
        //Add constraints to the different labels
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_questionText][_profilePicture(==50)]-10-|"
                                                                                options:NSLayoutFormatAlignAllTop
                                                                                metrics:nil
                                                                                  views:viewDictionary]];
        
        self.profilePictureAspectRatioConstraint = [NSLayoutConstraint constraintWithItem:_profilePicture
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1
                                                                                 constant:50];
        
        [self.contentView addConstraints:@[self.profilePictureAspectRatioConstraint]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_answerCountText(==75)]-10-[_questionInterestIndicator]|"
                                                                                 options:NSLayoutFormatAlignAllBottom
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_questionText]-10-[_answerCountText(==25)]-10-|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_questionText]-10-[_questionInterestIndicator(==25)]-10-|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
    }
    
    return self;
}

+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    boldFont =  [UIFont fontWithName:@"HelveticaNeue" size:12];
    answerCountColor = [UIColor colorWithRed:56.0 / 255.0 green:165.0 / 255.0 blue:219.0 / 255.0 alpha:1.0];
}

+ (CGFloat)heightForBasicCellWithObject:(PFObject *)object andWidth:(CGFloat)width {
    MWTableViewCell *layoutCell = [[MWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    [layoutCell configureCell:layoutCell withObject:object];
    [layoutCell layoutIfNeeded];
    
    return [layoutCell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
    
 }

- (void) configureCell:(MWTableViewCell *)cell withObject:(PFObject *)object {
    //Setup the question label
    
    self.questionText.text = [object objectForKey:@"questionText"];
    
    //try to fetch user profile photo in background
    
    MWUser *user = [object objectForKey:@"asker"];
    
    if ([user[@"profilePictureExists"] boolValue]) {
        PFFile *profilePicture = user[@"profilePicture"];
        self.profilePicture.file = profilePicture;
        [self.profilePicture loadInBackground];
    }
    
    //Setup the array of number of answers for the question
    NSArray *arrayOfAnswers = [object objectForKey:@"answersToQuestion"];
    NSUInteger activityOfAnswers = arrayOfAnswers.count;
    NSString *plural = @"s";
    
    if (activityOfAnswers == 1) {
        plural = @"";
    }
    
    self.answerCountText.text = [NSString stringWithFormat:@"%lu Answer%@", (unsigned long)activityOfAnswers, plural];
    
    switch (activityOfAnswers) {
        case 1:
            self.questionInterestIndicator.text = @"⚡️";
            break;
        case 2 ... 10:
            self.questionInterestIndicator.text = @"⚡️⚡️";
            break;
        case 11 ... 1000000:
            self.questionInterestIndicator.text = @"⚡️⚡️⚡️";
            break;
            
        default:
            self.questionInterestIndicator.text = @"";
            break;
    }
    
}

@end
