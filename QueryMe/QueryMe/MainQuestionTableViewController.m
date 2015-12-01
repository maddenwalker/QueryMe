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
#import "MWLoginViewController.h"
#import "MWSignUpViewController.h"
#import "QuestionDetailViewController.h"
#import <PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse.h>

static NSString * const simpleTableIdentifier = @"QuestionCell";

@interface MainQuestionTableViewController () <MWLoginVewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (assign, nonatomic) BOOL userLoggedIn;

@end

@implementation MainQuestionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshObjects];
    
    if ([MWUser currentUser]) {
        [self toggleUserSignedIn];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        //Setup local variables
        self.userLoggedIn = NO;
        
        
        //Questions Query for Parse
        self.parseClassName = @"Question";
        self.textKey = @"questionText";
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;

    }
    return self;
}
- (IBAction)logoutButtonPressed:(UIBarButtonItem *)sender {
    
    [MWUser logOut];
    [self toggleUserSignedIn];
    NSLog(@"User successfully logged out");
}

//MARK: Compose Button and Login Controller Information

- (IBAction)composeButtonPressed:(UIBarButtonItem *)sender {
    
    if (self.userLoggedIn) {
        
        NSLog(@"User signed in and ready to post");
        
    } else {
     
        //login view controller
        MWLoginViewController *loginViewController = [[MWLoginViewController alloc] init];
        [loginViewController setDelegate:self];
        [loginViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
        [loginViewController setFields:PFLogInFieldsDefault | PFLogInFieldsFacebook ];
        
        //sign up view controller
        MWSignUpViewController *signUpViewController = [[MWSignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        
        [loginViewController setSignUpController:signUpViewController];
        
        [self presentViewController:loginViewController animated:YES completion:NULL];
        
    }
    
}

//MARK: MWLoginViewControllerDelegate Methods

- (void)logInViewController:(MWLoginViewController *)logInController didLogInUserWithFacebook:(PFUser *)user {
    [self toggleUserSignedIn];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)logInViewController:(MWLoginViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    //checking to see if both fields have been completed to for login
    if (username && password && username.length != 0 && password.length != 0) {
        return YES;
    }
    
    [self showUserAlert:logInController withTitle:@"Missing Information" withMessage:@"Make sure you fill out all of the information!"];
    
    return NO;
    
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self toggleUserSignedIn];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)loginViewController:(MWLoginViewController *)loginController didFailToLogInWithError:(NSError*)error {
    NSLog(@"Failed to login with error: %@", error);
}

- (void)loginViewControllerDidCancelLogin:(MWLoginViewController *)loginController {
    NSLog(@"User dismissed login view controller");
    [self.navigationController popViewControllerAnimated:YES];
}


//MARK: PFSignUpViewControllerDelegate Methods

- (BOOL)signUpViewController:(MWSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        [self showUserAlert:signUpController withTitle:@"Missing Information" withMessage:@"Make sure you fill out all of the information!"];
    }
    
    return informationComplete;
}

-(void)signUpViewController:(MWSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self toggleUserSignedIn];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewController:(MWSignUpViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to sign up with error: %@", error);
}

- (void)signUpViewControllerDidCancelSignUp:(MWSignUpViewController *)signUpController {
    NSLog(@"Sign up view dismissed by user");
}


//MARK: Setup Query for TableViewCell
- (PFQuery *)baseQuery {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:@"asker"];
    [query orderByDescending:@"updatedAt"];
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
    
    //Setup the array of number of answers for the question
    NSArray *arrayOfAnswers = [object objectForKey:@"answersToQuestion"];
    NSUInteger activityOfAnswers = arrayOfAnswers.count;
    NSString *plural = @"s";
    
    if (activityOfAnswers == 1) {
        plural = @"";
    }
    
    cell.answerCountText.text = [NSString stringWithFormat:@"%lu Answer%@", (unsigned long)activityOfAnswers, plural];
    
    //Format the cell with answers count
    cell.answerCountText.layer.borderColor = [UIColor colorWithRed:56.0 / 255.0 green:165.0 / 255.0 blue:219.0 / 255.0 alpha:1.0].CGColor;
    cell.answerCountText.layer.borderWidth = 2.0;
    cell.answerCountText.layer.cornerRadius = 8.0;
    
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

//MARK: Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"questionDetailSegue"]) {
        QuestionDetailViewController *detailVC = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        detailVC.questionText = ((MWTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]).questionText.text;
    }
}

//MARK: Helper Methods

- (void)showUserAlert:(UIViewController*)viewController withTitle:(NSString*)title withMessage:(NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (void) toggleUserSignedIn {
    if (self.userLoggedIn) {
        self.userLoggedIn = NO;
        self.logoutButton.enabled = NO;
    } else {
        self.userLoggedIn = YES;
        self.logoutButton.enabled = YES;
    }
}

@end
