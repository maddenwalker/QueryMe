//
//  MainQuestionTableViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 11/30/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MainQuestionTableViewController.h"
#import "MWUser.h"
#import <Parse.h>

@interface MainQuestionTableViewController ()

@end

@implementation MainQuestionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        //Questions Query for Parse
        self.parseClassName = @"Question";
        self.textKey = @"questionText";
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;

    }
    return self;
}

//Setup Query for TableViewCell
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:@"asker"];
    return query;
}

//MARK: TableView Delegate Methods
- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *simpleTableIdentifier = @"QuestionCell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    //Setup the question label
    UILabel *questionLabel = (UILabel *)[cell viewWithTag:100];
    questionLabel.text = [object objectForKey:@"questionText"];
    
    //Setup the user label who asked the question
    PFImageView *askerImageView = (PFImageView *)[cell viewWithTag:101];
    askerImageView.layer.cornerRadius = 25;
    askerImageView.layer.masksToBounds = YES;
    
    askerImageView.image = [UIImage imageNamed:@"emptyProfilePicture"];
    
    //try to fetch user profile photo in background
    MWUser *user = [object objectForKey:@"asker"];
    
    if ([user[@"profilePictureExists"] boolValue]) {
        PFFile *profilePicture = user[@"profilePicture"];
        askerImageView.file = profilePicture;
        [askerImageView loadInBackground];
    }
    
    
    //Setup the array of number of answers for the question
    UILabel *answersCountLabel = (UILabel *)[cell viewWithTag:102];
    NSArray *arrayOfAnswers = [object objectForKey:@"answers"];
    answersCountLabel.text = [NSString stringWithFormat:@"%lu Answers", (unsigned long)arrayOfAnswers];
    
    return cell;
}


@end
