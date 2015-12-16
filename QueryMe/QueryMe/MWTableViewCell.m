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

@property (strong, nonatomic) UILabel *answerCountText;
@property (strong, nonatomic) UILabel *questionInterestIndicator;
@property (strong, nonatomic) UILabel *freshLabelIndicator;
@property (strong, nonatomic) NSLayoutConstraint *profilePictureAspectRatioConstraint;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *answerCountColor;
static UIColor *newLabelColor;

@implementation MWTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //Instantiate all of the cell elements
        self.profilePicture = [[MWProfileImageView alloc] init];
        self.answerCountText = [[UILabel alloc] init];
        self.questionText = [[UILabel alloc] init];
        self.questionInterestIndicator = [[UILabel alloc] init];
        self.freshLabelIndicator = [[UILabel alloc] init];
        
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
        
        //Fresh label
        self.freshLabelIndicator.text = @"";
        self.freshLabelIndicator.font = lightFont;
        self.freshLabelIndicator.backgroundColor = newLabelColor;
        self.freshLabelIndicator.textColor = [UIColor whiteColor];
        
        //Add Gesture recognizer to ProfileImageView
        self.profilePicture.userInteractionEnabled = YES;
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfilePictureTapped)];
        self.tapGestureRecognizer.delegate = self;
        [self.profilePicture addGestureRecognizer:self.tapGestureRecognizer];
        
        //Add labels to view
        for (UIView *view in @[self.questionText, self.profilePicture, self.freshLabelIndicator, self.answerCountText, self.questionInterestIndicator]) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_questionText, _profilePicture, _freshLabelIndicator, _answerCountText, _questionInterestIndicator);
        
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

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_freshLabelIndicator]-[_answerCountText(==75)]-10-[_questionInterestIndicator]"
                                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_questionText]-10-[_answerCountText(==25)]"
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
    newLabelColor = [UIColor colorWithRed:41.0 / 255.0 green:187.0 / 255.0 blue:156.0 / 255.0 alpha:1.0];
}

+ (CGFloat)heightForBasicCellWithObject:(PFObject *)object andWidth:(CGFloat)width {
    MWTableViewCell *layoutCell = [[MWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    [layoutCell configureCell:layoutCell withObject:object];
    [layoutCell layoutIfNeeded];
    
    return CGRectGetMaxY(layoutCell.answerCountText.frame);
    
 }

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:NO];
}

- (void) configureCell:(MWTableViewCell *)cell withObject:(PFObject *)object {
    //Setup the question label
    
    self.questionText.text = [object objectForKey:@"questionText"];
    //compare dates to see if this is a new question within the last 2 hours
    NSDate *questionCreationDate = object.updatedAt;
    NSDate *recentDate = [NSDate dateWithTimeIntervalSinceNow:-7200];
    
    NSComparisonResult compareResults = [questionCreationDate compare:recentDate];
    
    if (compareResults == NSOrderedDescending) {
        [self addFreshLabelToQuestion];
    } else {
        self.freshLabelIndicator.text = @"";
    }
    
    //try to fetch user profile photo in background
    
    MWUser *user = [object objectForKey:@"asker"];
    
    [self.profilePicture setProfilePictureToUser:user];
    
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


//Tap Gesture Recognizer Methods
- (void) userProfilePictureTapped {
    if ([self.delegate respondsToSelector:@selector(userTappedProfilePictureInCell:)]) {
        [self.delegate userTappedProfilePictureInCell:self];
    }
}

//MARK: Helper Methods

- (void) addFreshLabelToQuestion {
    self.freshLabelIndicator.text = NSLocalizedString(@" NEW ", @"New label for questions");
}

@end
