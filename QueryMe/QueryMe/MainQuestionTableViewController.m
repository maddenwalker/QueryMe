//
//  MainQuestionTableViewController.m
//  QueryMe
//
//  Created by Ryan Walker on 11/30/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MainQuestionTableViewController.h"
#import "MWUser.h"
#import "MWLoginViewController.h"
#import "MWSignUpViewController.h"
#import "AddQuestionViewController.h"
#import "QuestionDetailTableViewController.h"
#import "ProfileViewController.h"
#import <PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse.h>

static NSString * const simpleTableIdentifier = @"QuestionCell";
static NSString * const customCellIdentifier = @"CustomQuestionCell";

@interface MainQuestionTableViewController () <MWLoginVewControllerDelegate, PFSignUpViewControllerDelegate, AddQuestionViewControllerDelegate>
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

- (void)viewWillAppear:(BOOL)animated {
    [self refreshObjects];
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



//MARK: Logout Button
- (IBAction)logoutButtonPressed:(UIBarButtonItem *)sender {
    
    [MWUser logOut];
    [self toggleUserSignedIn];
    NSLog(@"User successfully logged out");
}

//MARK: Compose Button and Login Controller Information

- (IBAction)composeButtonPressed:(UIBarButtonItem *)sender {
    
    if (self.userLoggedIn) {
        [self performSegueWithIdentifier:@"addQuestionSegue" sender:nil];
    } else {
        [self performLoginOptions];
    }
    
}

- (void) performLoginOptions {

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

//MARK: MWLoginViewControllerDelegate Methods

- (void)logInViewController:(MWLoginViewController *)logInController didLogInUserWithFacebook:(PFUser *)user {
    [self toggleUserSignedIn];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    
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

-(void)signUpViewController:(MWSignUpViewController *)signUpController didSignUpUser:(MWUser *)user {
    user.profilePictureExists = NO;
    user.firstNameExists = NO;
    [user saveInBackground];
    NSLog(@"User signed up successfully");
    [self toggleUserSignedIn];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewController:(MWSignUpViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to sign up with error: %@", error);
}

- (void)signUpViewControllerDidCancelSignUp:(MWSignUpViewController *)signUpController {
    NSLog(@"Sign up view dismissed by user");
}

//MARK: AddQuestionViewControllerDelegate Methods

- (void)questionSuccessfullySubmittedToParse {
    [self refreshObjects];
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MWTableViewCell heightForBasicCellWithObject:[self.objects objectAtIndex:indexPath.row] andWidth:CGRectGetWidth(self.view.bounds)];
}

//MARK: TableViewDelegate - Set the Content of the Cells
- (MWTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    MWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
    
    if (cell == nil) {
        cell = [[MWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIdentifier];
        cell.delegate = self;
    }
    
    [cell configureCell:cell withObject:object];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.userLoggedIn) {
        [self performSegueWithIdentifier:@"questionDetailSegue" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    } else {
        [self performLoginOptions];
    }
    
}

//MARK: TableViewCell Delegate Methods
- (void)userTappedProfilePictureInCell:(MWTableViewCell *)cell {
    [self performSegueWithIdentifier:@"profileViewSegue" sender:cell];
}

//MARK: Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"questionDetailSegue"]) {
        QuestionDetailTableViewController *detailVC = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        detailVC.questionObject = [self.objects objectAtIndex:indexPath.row];
    } else if ([[segue identifier] isEqualToString:@"addQuestionSegue"]) {
        AddQuestionViewController *addVC = [segue destinationViewController];
        addVC.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"profileViewSegue"]) {
        ProfileViewController *profileVC = [segue destinationViewController];
        MWTableViewCell *cell = (MWTableViewCell *)sender;
        profileVC.profileImageView = cell.profilePicture;
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
