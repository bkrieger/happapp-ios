//
//  HappSettingsVC.m
//  Happ
//
//  Created by Brandon Krieger on 10/22/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappSettingsVC.h"
#import "HappFriendsVC.h"

@interface HappSettingsVC ()

@property (nonatomic, strong) HappABModel *happABModel;
@property (nonatomic, strong) HappModel *happModel;

@end

@implementation HappSettingsVC

- (id)initWithHappABModel:(HappABModel *)happABModel happModel:(HappModel *)happModel {
    self = [super init];
    if (self) {
        _happABModel = happABModel;
        _happModel = happModel;
    }
    return self;
}

- (void)dispose {
    self.happABModel = nil;
    self.happModel = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    UILabel *copyrightFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    copyrightFooter.text = [NSString stringWithFormat:@"Happ \u00A9 2013"];
    copyrightFooter.textColor = HAPP_BLACK_COLOR;
    copyrightFooter.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    copyrightFooter.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableFooterView = copyrightFooter;
}

- (void)done {
    [self dispose];
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2; // Me, Information
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        // Me
        return 2; // Friends, description of friends
    } else if (section == 1) {
        // Information
        return 3; // Terms of Use, Terms of Service, Feedback
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.textLabel.textColor = HAPP_PURPLE_COLOR;
    if (indexPath.section == 0) {
        // Me
        if (indexPath.row == 0) {
            // Friends
            cell.textLabel.text = @"Friends";
        } else if (indexPath.row == 1) {
            // Description of friends
            cell.textLabel.text = @"We've automatically added everyone in your contacts to your friends list. If there are people in your contacts you don't want to be friends with, you can change that here.";
            cell.textLabel.textColor = HAPP_BLACK_COLOR;
            cell.textLabel.numberOfLines = 4;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else if (indexPath.section == 1) {
        //Information
        if (indexPath.row == 0) {
            // Terms of Use
            cell.textLabel.text = @"Terms of Use";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Terms of Service";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Give feeback about Happ";
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Me";
    } else if (section == 1) {
        return @"Information";
    } else {
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.section == 0) {
        // Me
        if (indexPath.row == 0) {
            // Friends
            height = 50;
        } else if (indexPath.row == 1) {
            // Description of friends
            height = 80;
        }
    } else if (indexPath.section == 1) {
        //Information
        if (indexPath.row == 0) {
            // Terms of Use
            height = 50;
        } else if (indexPath.row == 1) {
            // Terms of Service
            height = 50;
        } else if (indexPath.row == 2) {
            // Give feedback
            height = 50;
        }
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        // Me
        if (indexPath.row == 0) {
            // Friends
            HappFriendsVC *happFriendsVC = [[HappFriendsVC alloc] initWithHappABModel:self.happABModel happModel:self.happModel];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:happFriendsVC];
            
            navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:navController animated:YES completion:nil];
        } else if (indexPath.row == 1) {
            // Description of friends
        }
    } else if (indexPath.section == 1) {
        //Information
        if (indexPath.row == 0) {
            // Terms of Use
            NSURL *url = [[NSURL alloc ] initWithString: @"http://www.happ.us/termsofuse"];
            [[UIApplication sharedApplication] openURL:url];
        } else if (indexPath.row == 1) {
            // Terms of Service
            NSURL *url = [[NSURL alloc ] initWithString: @"http://www.happ.us/termsofservice"];
            [[UIApplication sharedApplication] openURL:url];
        } else if (indexPath.row == 2) {
            // Give feedback
            UIAlertView *feedbackPopup = [[UIAlertView alloc] initWithTitle:@"Give feedback" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",nil];
            feedbackPopup.alertViewStyle = UIAlertViewStylePlainTextInput;
            [feedbackPopup show];
        }
    }
}

#pragma mark - ui alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // Send feedback
        NSString *input = [alertView textFieldAtIndex:0].text;
    }
}

@end
