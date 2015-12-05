//
//  AddQuestionViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 12/3/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "AddQuestionViewController.h"
#import "MWUser.h"
#import "MWProfileImageView.h"
#import <SZTextView/SZTextView.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface AddQuestionViewController () <UITextViewDelegate>

@property (strong, nonatomic) UILabel *characterLimitLabel;
@property (strong, nonatomic) NSNumber *characterCount;
@property (strong, nonatomic) NSNumber *characterLimit;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) MWProfileImageView *profilePictureImageView;
@property (strong, nonatomic) SZTextView *questionTextField;

@property (strong, nonatomic) MWUser *currentUser;

@end

static int characterLimit = 200;

@implementation AddQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentUser = [MWUser currentUser];
    
    //Initialize all of your UI elements that you have on the screen
    self.profilePictureImageView = [[MWProfileImageView alloc] init];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.characterLimitLabel = [[UILabel alloc] init];
    self.questionTextField = [SZTextView new];
    self.questionTextField.delegate = self;
    self.submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //Create cancel button elements in the UI
    [self.cancelButton setTitle:@"x" forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(10, 20, 44, 44);
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:34];
    self.cancelButton.tintColor = [UIColor grayColor];
    [self.cancelButton sizeThatFits:CGSizeMake(44, 44)];
    [self.cancelButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //Attempt to set the profile picture of the image view to the logged in user
    [self.profilePictureImageView setProfilePictureToUser:self.currentUser];
    
    //Setup the character limits that we will impose on the user
    self.characterCount = [NSNumber numberWithInt:0];
    self.characterLimit = [NSNumber numberWithInt:characterLimit];
    self.characterLimitLabel.text = [NSString stringWithFormat:@"%@/%@",self.characterCount, self.characterLimit];
    self.characterLimitLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    
    //Update the placeholder text and animate the fade for the text once the user starts typing.
    self.questionTextField.placeholder = NSLocalizedString(@"Ask your question here and the world's knowledge will come upon you . . .", @"Placeholder text for add question VC");
    self.questionTextField.placeholderTextColor = [UIColor lightGrayColor];
    self.questionTextField.fadeTime = 0.5;
    self.questionTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    
    //Setup the submit button
    //TODO: Your button is extremely ugly, and would be way cooler to be a view on the bottom of the screen and then slides up with keyboard
    [self.submitButton setTitle:NSLocalizedString(@"Submit your Question", @"submission button for add question screen") forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(submitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //TODO: Refactor code because of DRY wrt colors
    self.submitButton.backgroundColor = [UIColor colorWithRed:56.0 / 255.0 green:165.0 / 255.0 blue:219.0 / 255.0 alpha:1.0];
    self.submitButton.tintColor = [UIColor whiteColor];
    
    for (UIView *view in @[self.cancelButton, self.profilePictureImageView, self.questionTextField, self.characterLimitLabel, self.submitButton]) {
        [self.view addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_cancelButton, _profilePictureImageView, _questionTextField, _characterLimitLabel, _submitButton);
    
    
    //horizontal and vertical alignment for cancel button, profile picture, and the question text field
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_cancelButton]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_cancelButton]-[_profilePictureImageView(==50)]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_profilePictureImageView]-[_characterLimitLabel]"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                        views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_submitButton]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_submitButton]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_profilePictureImageView(==50)]-[_questionTextField]-|"
                                                                      options:NSLayoutFormatAlignAllTop
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    
    NSLayoutConstraint *questionTextFieldHeightConstraint = [NSLayoutConstraint constraintWithItem:_questionTextField
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:200];
    
    [self.view addConstraints:@[questionTextFieldHeightConstraint]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: Handle Button Taps
- (void)dismissButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"User dismissed the add question screen");
    }];
    
}

- (void)submitButtonPressed:(UIButton *)sender {
    
    if (self.questionTextField.text.length > 0) {
        if ([self submitCurrentQuestionToParse]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            //TODO: need to have this method tell a delegate, the table view controller that there is new data and that it should refresh
            //TODO: Ideally add some user feedback that the question is actually submitted?
        };
    } else {
        //TODO: Add uialertview that the user has entered no text and we cannot submit a blank question
    }
}

//Typing in the text field up to a certain point, only going to allow twitter type question lenghts (~200char)

//MARK: UITextViewDelegateMethods
- (void)textViewDidChange:(UITextView *)textView {

    //update the character count when the text changes in the UITextView; needed to cast the length to explicit Int because in 64-bit the NSUinteger has more precision and that is not necessary when only counting 200 characters
    self.characterCount = [NSNumber numberWithInt:(int)[textView.text length]];
    self.characterLimitLabel.text = [NSString stringWithFormat:@"%@/%@",self.characterCount, self.characterLimit];
    
    //user feedback to show that they've gone over the limit of characters
    if (self.characterCount > self.characterLimit) {
        self.characterLimitLabel.textColor = [UIColor redColor];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    //Turn the return button into a done button so we can finish text editing.
    if ([text  isEqual: @"\n"]) {
        [textView resignFirstResponder];
    }
    
    return YES;
    
}

//TODO: Need to update the fact that the text here may go over 200 characters

//MARK: Helper Methods
- (BOOL) submitCurrentQuestionToParse {
   
    NSError *error;
    
    PFObject *newQuestion = [[PFObject alloc] initWithClassName:@"Question"];
    newQuestion[@"questionText"] = self.questionTextField.text;
    newQuestion[@"asker"] = [PFObject objectWithoutDataWithClassName:@"_User" objectId:self.currentUser.objectId];
    //saving the object directly and blocking main thread on purpose here because I want the user to see their question when they go to the main view controller, obviously an issue when network connectivity lost.
    [newQuestion save:&error];
    
    if (!error) {
        NSLog(@"Data saved successfully to parse");
        return YES;
    }
    //TODO: need a way to gracefully fail here because if there are network issues, then this could be an issue, perhaps better to add saveInBackground
    return NO;
    
}

@end
