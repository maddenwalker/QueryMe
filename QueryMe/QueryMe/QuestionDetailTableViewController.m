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
#import "MWInputAccessoryView.h"
#import "ProfileViewController.h"
#import "MainQuestionTableViewController.h"

@interface QuestionDetailTableViewController ()

@property (strong, nonatomic) MWDetailQuestionView *questionView;
@property (strong, nonatomic) MWInputAccessoryView *inputView;
@property (assign, nonatomic) CGFloat widthOfView;
@property (assign, nonatomic) CGFloat heightForQuestionView;
@property (assign, nonatomic) CGFloat startingYCoordinateForQuestion;
@property (assign, nonatomic) CGFloat endingYCoordinateForQuestion;

@end

@implementation QuestionDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.questionObject fetchIfNeededInBackground];
    
    // Do any additional setup after loading the view.
    self.widthOfView = CGRectGetWidth(self.view.bounds);
    self.heightForQuestionView = [MWDetailQuestionView heightForViewWith:self.questionObject andWidth:self.widthOfView];
    self.startingYCoordinateForQuestion = -CGRectGetMaxY(self.navigationController.navigationBar.frame) - 8;
    self.endingYCoordinateForQuestion = CGRectGetMaxY(self.navigationController.navigationBar.frame) - 8;
    
    //Setup the questionView above the table and sticky to the top
    self.questionView = [[MWDetailQuestionView alloc] init];
    [self.questionView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [self.questionView configureViewwithObject:self.questionObject];
    self.questionView.frame = CGRectMake(0, self.startingYCoordinateForQuestion, self.widthOfView, self.heightForQuestionView);
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

- (void)viewDidAppear:(BOOL)animated {
    
    CGRect endFrameForQuestionView = self.questionView.frame;
    endFrameForQuestionView.origin.y = self.endingYCoordinateForQuestion;
    
    [UIView beginAnimations:nil context:nil];
    
    [UIView animateWithDuration:0.7
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.questionView.frame = endFrameForQuestionView;
    }
                     completion:nil];
    
    [UIView commitAnimations];
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
    UIViewController *topVC = self.navigationController.topViewController;
    if ([MainQuestionTableViewController class] == [topVC class]) {
        [self.questionView removeFromSuperview];
    }
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
            NSMutableArray *arrayOfAnswers = [self.questionObject objectForKey:@"answersToQuestion"];
            [arrayOfAnswers addObject:newAnswer];
            [self.questionObject addObject:arrayOfAnswers forKey:@"answersToQuestion"];
            [self loadObjects];
            [self.questionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"Question updated correctly with associated answer");
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
        cell.delegate = self;
    }
    
    [cell configureCell:cell withObject:object];
    
    return cell;
}

//MARK: TableViewCell Delegate Methods
- (void)userTappedProfilePictureInCell:(MWDetailTableViewCell *)cell {
    [self performSegueWithIdentifier:@"profileViewFromDetailSegue" sender:cell];
}

//MARK: MWKeyboardBarViewDelegate

- (void)keyboardBar:(MWKeyboardBarView *)keyboardBar sendText:(NSString *)text {
    
    if (text) {
        [self submitTextToParse:text];
    } else {
        NSLog(@"No text");
    }
}

//MARK: Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"profileViewFromDetailSegue"]) {
        ProfileViewController *profileVC = [segue destinationViewController];
        MWDetailTableViewCell *cell = (MWDetailTableViewCell *)sender;
        profileVC.profileImageView = cell.profilePicture;
    }
}

@end
