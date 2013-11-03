//
//  HappFriendsVC.m
//  Happ
//
//  Created by Brandon Krieger on 10/7/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappFriendsVC.h"
#import "MBProgressHUD.h"

@interface HappFriendsVC ()

@property (nonatomic, strong) HappABModel *happABModel;
@property (nonatomic, strong) HappModel *happModel;
@property (nonatomic, strong) NSArray *contacts;

@end

@implementation HappFriendsVC

- (id)initWithHappABModel:(HappABModel *)happABModel happModel:(HappModel *)happModel {
    self = [super init];
    if (self) {
        _happABModel = happABModel;
        _happModel = happModel;
        _contacts = nil;
    }
    return self;
}

- (void)dispose {
    self.happABModel = nil;
    self.happModel = nil;
    self.contacts = nil;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = HAPP_BARTINT_COLOR;
    self.navigationItem.title = @"Contacts";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(saveFriends)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetFriends)];
    self.tableView.sectionIndexColor = HAPP_PURPLE_COLOR;
    [[UITableViewCell appearance] setTintColor:HAPP_PURPLE_COLOR];
    
    // This can take a while, so put a loading screen
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = @"Loading contacts...";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        self.contacts = self.happABModel.contactsSeparatedByFirstLetter;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [self.tableView reloadData];
        });
    });
}

-(void)saveFriends {
    [self.happModel updateFriends];
    [self dispose];
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)resetFriends {
    UIAlertView *confirmResetView = [[UIAlertView alloc] initWithTitle:@"Reset friends" message:@"Are you sure you want to reset your friends to all contacts?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [confirmResetView show];
}

#pragma mark - UI alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // YES
        [self.happABModel unblockAllContacts];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];

    if (self.contacts) {
        NSArray *contactsForSection = [self.contacts objectAtIndex:indexPath.section];
        ABRecordRef person = (__bridge ABRecordRef)([contactsForSection objectAtIndex:indexPath.row]);
        NSString *name = [self.happABModel fullNameForPerson:person];
        if (!name) {
            name = @"";
        }
        
        cell.textLabel.text = name;
        cell.textLabel.textColor = HAPP_BLACK_COLOR;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        
        if ([self.happABModel isPersonBlocked:person]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.contacts) {
        return [self.contacts count];
    } else {
        return 0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.contacts) {
        return [[self.contacts objectAtIndex:section] count];
    } else {
        return 0;
    }
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:27];
    for (unichar letter = 'A'; letter <= 'Z'; letter++) {
        NSString *title = [NSString stringWithCharacters:&letter length:1];
        [titles addObject:title];
    }
    // Add one more title for non letters.
    [titles addObject:@"#"];
    
    return titles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.contacts) {
        NSArray *contactsForSection = [self.contacts objectAtIndex:section];
        if ([contactsForSection count] == 0) {
            // Don't display a section header if the section has no rows.
            return nil;
        }
        NSString *title;
        if (section >= 0 && section < 26) {
            unichar letter = 'A';
            letter += section;
            title = [NSString stringWithCharacters:&letter length:1];
        } else {
            title = @"#";
        }
        return title;
    } else {
        return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - table view delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSArray *contactsForSection = [self.contacts objectAtIndex:indexPath.section];
    ABRecordRef person = (__bridge ABRecordRef)([contactsForSection objectAtIndex:indexPath.row]);
    
    BOOL blocked;
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        blocked = NO;
    } else {
        blocked = YES;
    }
    
    [self.happABModel setPerson:person blocked:blocked];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
}

@end
