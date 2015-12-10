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

@interface QuestionDetailTableViewController ()

@property (strong, nonatomic) MWDetailQuestionView *questionView;

@end

@implementation QuestionDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.questionView = [[MWDetailQuestionView alloc] init];
    self.questionView.layer.zPosition++;
    [self.questionView configureViewwithObject:self.questionObject];
    self.questionView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.bounds), 100);
    [self.navigationController.view addSubview:self.questionView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.questionView.frame), 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.questionView.frame), 0, 0, 0);
    
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


- (PFQuery *)baseQuery {
    PFQuery *answerQuery = [PFQuery queryWithClassName:self.parseClassName];
    [answerQuery whereKey:@"questionAnswered" equalTo:self.questionObject];
    [answerQuery includeKey:@"answerer"];
    
    return answerQuery;
    
}


- (PFQuery *)queryForTable {
    return [self baseQuery];
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


@end
