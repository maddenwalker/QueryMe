//
//  QuestionDetailViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 12/1/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "QuestionDetailViewController.h"

@interface QuestionDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionTextLabel;

@end

@implementation QuestionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.questionTextLabel.text = self.questionText;
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
