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
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface AddQuestionViewController ()
@property (strong, nonatomic) IBOutlet MWProfileImageView *profilePictureImageView;

@end

@implementation AddQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profilePictureImageView = [[MWProfileImageView alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: Handle Button Taps
- (IBAction)dismissButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"User dismissed the add question screen");
    }];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
