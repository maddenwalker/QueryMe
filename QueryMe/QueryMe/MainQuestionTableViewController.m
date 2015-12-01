//
//  MainQuestionTableViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 11/30/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MainQuestionTableViewController.h"
#import "MWUser.h"
#import "MWTableViewCell.h"
#import <Parse.h>

static NSString * const simpleTableIdentifier = @"QuestionCell";

@interface MainQuestionTableViewController ()

@end

@implementation MainQuestionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshObjects];

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
- (PFQuery *)baseQuery {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:@"asker"];
    return query;
}


- (PFQuery *)queryForTable {
    return [[self baseQuery] fromLocalDatastore];
}

- (void) refreshObjects {
    [[[self baseQuery] findObjectsInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        if (task.error) {
            [self.refreshControl endRefreshing];
            return nil;
        }
        
        return [[PFObject unpinAllObjectsInBackgroundWithName:@"cacheLabel"] continueWithSuccessBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull unused) {
            NSArray *objects = task.result;
            return [[PFObject pinAllInBackground:objects withName:@"cacheLabel"] continueWithSuccessBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull unused) {
                [self.refreshControl endRefreshing];
                [self loadObjects];
                return nil;
            }];
        }];
    }];
}

//MARK: TableViewDelegate - Set TableViewHeight and Number of Sections
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static MWTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    });
    
    PFObject *objectForSizingCell = [self.objects objectAtIndex:indexPath.row];
    
    [self configureCell:sizingCell atIndexPath:indexPath withObject:objectForSizingCell];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    if (size.height < 90) {
        return 90 + 1.0f;
    }
    
    return size.height + 1.0f;
}

//MARK: TableViewDelegate - Set the Content of the Cells
- (MWTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    MWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[MWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath withObject:object];
    
    return cell;
}

- (void) configureCell:(MWTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(PFObject *)object {
    //Setup the question label

    cell.questionText.text = [object objectForKey:@"questionText"];
    
    //Setup the user label who asked the question
    cell.profilePicture.layer.cornerRadius = 25;
    cell.profilePicture.layer.masksToBounds = YES;
    
    cell.profilePicture.image = [UIImage imageNamed:@"emptyProfilePicture"];
    
    //try to fetch user profile photo in background

    MWUser *user = [object objectForKey:@"asker"];

    if ([user[@"profilePictureExists"] boolValue]) {
        PFFile *profilePicture = user[@"profilePicture"];
        cell.profilePicture.file = profilePicture;
        [cell.profilePicture loadInBackground];
    }
    q
    //Setup the array of number of answers for the question
    NSArray *arrayOfAnswers = [object objectForKey:@"answersToQuestion"];
    NSUInteger activityOfAnswers = arrayOfAnswers.count;
    NSString *predicate = @"s";
    
    if (activityOfAnswers == 1) {
        predicate = @"";
    }
    
    cell.answerCountText.text = [NSString stringWithFormat:@"%lu Answer%@", (unsigned long)activityOfAnswers, predicate];
    
    switch (activityOfAnswers) {
        case 1:
            cell.questionInterestIndicator.text = @"⚡️";
            break;
        case 2 ... 10:
            cell.questionInterestIndicator.text = @"⚡️⚡️";
            break;
        case 11 ... 1000000:
            cell.questionInterestIndicator.text = @"⚡️⚡️⚡️";
            break;
            
        default:
            cell.questionInterestIndicator.text = @"";
            break;
    }

}

@end
