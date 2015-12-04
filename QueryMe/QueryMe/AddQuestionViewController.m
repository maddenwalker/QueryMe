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
@property (strong, nonatomic) MWProfileImageView *profilePictureImageView;
@property (strong, nonatomic) SZTextView *questionTextField;

@end

static int characterLimit = 200;

@implementation AddQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Initialize all of your UI elements that you have on the screen
    self.profilePictureImageView = [[MWProfileImageView alloc] init];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.characterLimitLabel = [[UILabel alloc] init];
    self.questionTextField = [SZTextView new];
    self.questionTextField.delegate = self;
    
    //Create cancel button elements in the UI
    [self.cancelButton setTitle:@"x" forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(10, 20, 44, 44);
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:34];
    self.cancelButton.tintColor = [UIColor grayColor];
    [self.cancelButton sizeThatFits:CGSizeMake(44, 44)];
    [self.cancelButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //Attempt to set the profile picture of the image view to the logged in user
    [self.profilePictureImageView setProfilePictureToUser:[MWUser currentUser]];
    
    //Setup the character limits that we will impose on the user
    self.characterCount = [NSNumber numberWithInt:0];
    self.characterLimit = [NSNumber numberWithInt:characterLimit];
    self.characterLimitLabel.text = [NSString stringWithFormat:@"%@/%@",self.characterCount, self.characterLimit];
    self.characterLimitLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    
    //Update the placeholder text and animate the fade for the text once the user starts typing.
    self.questionTextField.placeholder = @"Ask your question here and the world's knowledge will come upon you . . .";
    self.questionTextField.placeholderTextColor = [UIColor lightGrayColor];
    self.questionTextField.fadeTime = 0.5;
    self.questionTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    
    for (UIView *view in @[self.cancelButton, self.profilePictureImageView, self.questionTextField, self.characterLimitLabel]) {
        [self.view addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_cancelButton, _profilePictureImageView, _questionTextField, _characterLimitLabel);
    
    
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

//Typing in the text field up to a certain point, only going to allow twitter type question lenghts (~200char)

//MARK: UITextViewDelegateMethods
- (void)textViewDidChange:(UITextView *)textView {

    //update the character count when the text changes in the UITextView; needed to cast the length to explicit Int because in 64-bit the NSUinteger has more precision and that is not necessary when only counting 200 characters
    self.characterCount = [NSNumber numberWithInt:(int)[textView.text length]];
    self.characterLimitLabel.text = [NSString stringWithFormat:@"%@/%@",self.characterCount, self.characterLimit];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    //Turn the return button into a done button so we can finish text editing.
    if ([text  isEqual: @"\n"]) {
        [textView resignFirstResponder];
    }
    
    return YES;
    
}

//TODO: Need to update the fact that the text here may go over 200 characters
//TODO: add the ability to post the question directly with a button to the Parse servers

@end
