//
//  MWDetailQuestionView.m
//  QueryMe
//
//  Created by Ryan Walker on 12/10/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWDetailQuestionView.h"
#import "MWUser.h"

@interface MWDetailQuestionView()

@property (strong, nonatomic) UILabel *questionText;
@property (strong, nonatomic) UILabel *askerLabel;

@end

static UIFont *lightFontWithItalics;
static UIFont *mediumFont;

@implementation MWDetailQuestionView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:56.0 / 255.0 green:165.0 / 255.0 blue:219.0 / 255.0 alpha:1.0];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8;
        
        //Setup the labels
        self.questionText = [[UILabel alloc] init];
        self.askerLabel = [[UILabel alloc] init];
        
        //Setup questionText
        self.questionText.font = mediumFont;
        self.questionText.textColor = [UIColor whiteColor];
        self.questionText.numberOfLines = 0;
        
        //Setup askerLabel
        self.askerLabel.font = lightFontWithItalics;
        self.askerLabel.textColor = [UIColor whiteColor];
        
        for (UIView *view in @[self.askerLabel, self.questionText]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_askerLabel, _questionText);
        

        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_askerLabel]-[_questionText]"
                                                                                          options:NSLayoutFormatAlignAllLeft
                                                                                          metrics:nil
                                                                                            views:viewDictionary];
        
        NSArray *widthConstraintForQuestion = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_questionText]-20-|"
                                                                                                 options:kNilOptions
                                                                                                 metrics:nil
                                                                                                   views:viewDictionary];
        
        for (NSArray *constraints in @[verticalConstraints, widthConstraintForQuestion]) {
            [self addConstraints:constraints];
        }
        
    }
    
    return self;
}

+ (void)load {
    lightFontWithItalics = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11];
    mediumFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
}

+ (CGFloat) heightForViewWith:(PFObject *)object andWidth:(CGFloat)width {
    MWDetailQuestionView *layoutView = [[MWDetailQuestionView alloc] init];
    [layoutView configureViewwithObject:object];
    layoutView.frame = CGRectMake(0, 0, width, 50);
    [layoutView layoutIfNeeded];
    
    return CGRectGetMaxY(layoutView.questionText.frame) + 20;
}

- (void) configureViewwithObject:(PFObject *)object {
    //Setup user and label
    MWUser *user = [object objectForKey:@"asker"];
    
    NSString *firstNameString;
    
    if ([user[@"firstNameExists"] boolValue]) {
        firstNameString = [user objectForKey:@"firstName"];
    } else {
        firstNameString = @"Anonymous";
    }
    
    self.askerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ asks . . .", @"Asker label in detail view"), firstNameString];
    
    self.questionText.text = object[@"questionText"];
}


@end
