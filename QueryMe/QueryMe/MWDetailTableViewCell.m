//
//  MWDetailTableViewCell.m
//  QueryMe
//
//  Created by Ryan Walker on 12/10/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWDetailTableViewCell.h"
#import "MWUser.h"
#import "MWProfileImageView.h"
#import <Parse/Parse.h>

@interface MWDetailTableViewCell()

@property (strong, nonatomic) MWProfileImageView *profileImage;
@property (strong, nonatomic) UILabel *answererName;
@property (strong, nonatomic) UILabel *answerLabel;

@end

static UIFont *lightFont;
static UIFont *boldSmallFont;

@implementation MWDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        //Create all of the details in the cell
        self.profileImage = [[MWProfileImageView alloc] init];
        self.answererName = [[UILabel alloc] init];
        self.answerLabel = [[UILabel alloc] init];
        
        //Format the answererName
        self.answererName.font = boldSmallFont;
        
        //Format the Answer Text
        self.answerLabel.font = lightFont;
        self.answerLabel.numberOfLines = 0;
        
        //Add the labels to the view
        
        NSArray *views = @[self.profileImage, self.answererName, self.answerLabel];
        for (UIView *view in views) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_profileImage,_answererName, _answerLabel);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_profileImage(==50)]-[_answererName]"
                                                                                 options:NSLayoutFormatAlignAllTop
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_answererName][_answerLabel]"
                                                                                 options:NSLayoutFormatAlignAllLeft
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_answerLabel]-10-|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_profileImage]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_profileImage
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_profileImage
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1 constant:0]];
        
        
        
    }
    
    return self;
}

+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    boldSmallFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
}

+ (CGFloat) heightForBasicCellWithObject:(PFObject *)object andWidth:(CGFloat)width {
    MWDetailTableViewCell *layoutCell = [[MWDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    [layoutCell configureCell:layoutCell withObject:object];
    [layoutCell layoutIfNeeded];
    
    return (MAX(CGRectGetMaxY(layoutCell.answerLabel.frame), CGRectGetMaxY(layoutCell.profileImage.frame)) + 8 );
    
}

- (void) configureCell:(MWDetailTableViewCell *)cell withObject:(PFObject *)object {
    //Setup the answer label
    [self.profileImage setProfilePictureToUser:object[@"answerer"]];
    self.answerLabel.text = object[@"answerText"];
    
    //Setup user and label
    MWUser *user = [object objectForKey:@"answerer"];
    
    NSString *firstNameString;
    
    if ([user[@"firstNameExists"] boolValue]) {
        firstNameString = [user objectForKey:@"firstName"];
    } else {
        firstNameString = @"Anonymous";
    }
    
    self.answererName.text = [NSString stringWithFormat:NSLocalizedString(@"%@ says", @"Declaring user saying something"), firstNameString];
}


@end
