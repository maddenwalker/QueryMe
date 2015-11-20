//
//  MWSignUpViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 11/20/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWSignUpViewController.h"

@interface MWSignUpViewController ()

@end

@implementation MWSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor grayColor];
    label.text = @"Q/me";
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:50];
    [label sizeToFit];
    self.signUpView.logo = label;
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

@end
