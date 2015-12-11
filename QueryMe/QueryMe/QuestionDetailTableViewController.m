//
//  QuestionDetailTableViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 12/9/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "QuestionDetailTableViewController.h"
#import "MWUser.h"
#import "MWDetailQuestionView.h"
#import "MWDetailTableViewCell.h"
#import "MWInputAccessoryView.h"

@interface QuestionDetailTableViewController ()

@property (strong, nonatomic) MWDetailQuestionView *questionView;
@property (strong, nonatomic) MWInputAccessoryView *inputView;
@property (assign, nonatomic) CGFloat widthOfView;
@property (assign, nonatomic) CGFloat heightForQuestionView;

@end

@implementation QuestionDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.widthOfView = CGRectGetWidth(self.view.bounds);
    self.heightForQuestionView = [MWDetailQuestionView heightForViewWith:self.questionObject andWidth:self.widthOfView];
    
    //Setup the questionView above the table and sticky to the top
    self.questionView = [[MWDetailQuestionView alloc] init];
    [self.questionView configureViewwithObject:self.questionObject];
    NSLog(@"%f", self.heightForQuestionView);
    self.questionView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame) - 8, self.widthOfView, self.heightForQuestionView);
    [self.navigationController.view insertSubview:self.questionView belowSubview:self.navigationController.navigationBar];
    
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.questionView.frame), 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.questionView.frame), 0, 0, 0);
    
    //Add the inputAccessoryView docked to the bottom so people can answer
    self.inputView = [[MWInputAccessoryView alloc] init];
    self.inputView.backgroundColor = [UIColor whiteColor];
    self.inputView.keyboardDelegate = self;
    [self.inputView becomeFirstResponder];
    [self.view addSubview:self.inputView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        //Answers Query for Parse
        self.parseClassName = @"Answers";
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        
        
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.questionView removeFromSuperview];
}

- (UIView *)inputAccessoryView {
    return self.inputView;
}

- (PFQuery *)baseQuery {
    PFQuery *answerQuery = [PFQuery queryWithClassName:self.parseClassName];
    [answerQuery whereKey:@"questionAnswered" equalTo:self.questionObject];
    [answerQuery includeKey:@"answerer"];
    
    return answerQuery;
    
}


- (PFQuery *)queryForTable {
    return [self baseQuery];
}

- (void) submitTextToParse:(NSString *)text {
    
    PFObject *newAnswer = [[PFObject alloc] initWithClassName:@"Answers"];
    newAnswer[@"answerText"] = text;
    newAnswer[@"answerer"] = [MWUser currentUser];
    newAnswer[@"questionAnswered"] = self.questionObject;
    [newAnswer saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Answer saved successfully");
            NSMutableArray *arrayOfAnswers = [self.questionObject[@"answersToQuestion"] mutableCopy];
            [arrayOfAnswers addObject:newAnswer];
            [self.questionObject addObject:arrayOfAnswers forKey:@"answersToQuestion"];
            [self.questionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"Question updated correctly with associated answer");
                    [self loadObjects];
                }
            }];
         }
    }];
    
}


//MARK: TableViewDelegate - Set TableViewHeight and Number of Sections
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MWDetailTableViewCell heightForBasicCellWithObject:[self.objects objectAtIndex:indexPath.row] andWidth:CGRectGetWidth(self.view.bounds)];
}



- (MWDetailTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    NSString *customIdentifier = @"answerCell";
    
    MWDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customIdentifier];
    
    if (cell == nil) {
        cell = [[MWDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customIdentifier];
    }
    
    [cell configureCell:cell withObject:object];
    
    return cell;
}

//MARK: MWKeyboardBarViewDelegate

- (void)keyboardBar:(MWKeyboardBarView *)keyboardBar sendText:(NSString *)text {
    
    if (text) {
        [self submitTextToParse:text];
    } else {
        NSLog(@"No text");
    }
}

@end
