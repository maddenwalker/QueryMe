//
//  QuestionDetailTableViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 12/9/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "QuestionDetailTableViewController.h"
#import "MWUser.h"
#import "MWProfileImageView.h"

@interface QuestionDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *questionTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIView *questionView;

@end

@implementation QuestionDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Setup the question text
    self.questionTextLabel.text = [self.questionObject objectForKey:@"questionText"];
    
    //Setup user and label
    MWUser *user = [self.questionObject objectForKey:@"asker"];
    
    NSString *firstNameString;
    
    if ([user[@"firstNameExists"] boolValue]) {
        firstNameString = [user objectForKey:@"firstName"];
    } else {
        firstNameString = @"Anonymous";
    }
    
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ asks . . .", firstNameString];
    
    CGFloat itemHeight = 100;
    
    //Set the UIView Custom Height for the questionView
    self.questionView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), itemHeight);
    
    
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

- (PFQuery *)baseQuery {
    PFQuery *answerQuery = [PFQuery queryWithClassName:self.parseClassName];
    [answerQuery whereKey:@"questionAnswered" equalTo:self.questionObject];
    [answerQuery includeKey:@"answerer"];
    
    return answerQuery;
    
}


- (PFQuery *)queryForTable {
    return [self baseQuery];
}


- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"answerCell"];
    
    MWProfileImageView *profileImageView = [[MWProfileImageView alloc] init];
    profileImageView = (MWProfileImageView *)[cell viewWithTag:100];
    UILabel *answerLabel = (UILabel *)[cell viewWithTag:101];
    
    [profileImageView setProfilePictureToUser:object[@"answerer"]];
    
    answerLabel.text = object[@"answerText"];
    
    return cell;
}


@end
