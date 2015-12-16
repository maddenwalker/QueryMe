//
//  ProfileViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 12/11/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "ProfileViewController.h"
#import "MWProfileImageView.h"

@interface ProfileViewController ()
- (IBAction)closeButtonTapped:(id)sender;

//@property (strong, nonatomic) MWUser *user;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *profileDescriptionLabel;
@property (strong, nonatomic) MWProfileImageView *profileImageView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileImageView = [[MWProfileImageView alloc] init];
    self.profileImageView.layer.cornerRadius = 50;
    
    //Setup the user that is in the profile view
    [self.profileImageView setProfilePictureToUser:self.user];
    
    //Setup the profile description label
    self.profileDescriptionLabel = [[UILabel alloc] init];
    self.profileDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14];
    if (self.user.profileDescription) {
        self.profileDescriptionLabel.text = self.user.profileDescription;
    } else {
        self.profileDescriptionLabel.text = @"Better left unsaid";
    }
    
    //Setup the name label
    self.nameLabel = [[UILabel alloc] init];
    if (self.user.firstNameExists) {
        self.nameLabel.text = self.user.firstName;
    } else {
        self.nameLabel.text = @"Anonymous";
    }
    
    
    //Add and layout the views
    for (UIView *view in @[self.nameLabel, self.profileImageView, self.profileDescriptionLabel]) {
        [self.view addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_profileImageView, _nameLabel, _profileDescriptionLabel);
    
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[_profileImageView(==100)]" options:kNilOptions metrics:nil views:viewDictionary];
    
    NSArray *horizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[_profileImageView(==100)]-[_nameLabel]" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary];
    
    NSArray *labelConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel]-[_profileDescriptionLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewDictionary];

    for (NSArray *constraint in @[verticalConstraint, horizontalConstraint, labelConstraint]) {
        [self.view addConstraints:constraint];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
