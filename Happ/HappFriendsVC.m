//
//  HappFriendsVC.m
//  Happ
//
//  Created by Brandon Krieger on 10/7/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappFriendsVC.h"

@interface HappFriendsVC ()

@property (nonatomic, strong) HappABModel *happABModel;
@property (nonatomic, strong) HappModel *happModel;

@end

@implementation HappFriendsVC

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

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Friends";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(saveFriends)];
}

-(void)saveFriends {
    [self.happModel updateFriends];
    [self dispose];
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *contactsForSection = [self.happABModel.contactsSeparatedByFirstLetter objectAtIndex:indexPath.section];
    ABRecordRef person = (__bridge ABRecordRef)([contactsForSection objectAtIndex:indexPath.row]);
    NSString *name = [self.happABModel fullNameForPerson:person];
    if (!name) {
        name = @"";
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = name;

    if ([self.happABModel isPersonBlocked:person]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.happABModel.contactsSeparatedByFirstLetter count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *contactsForSection = [self.happABModel.contactsSeparatedByFirstLetter objectAtIndex:section];
    return [contactsForSection count];
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
    NSArray *contactsForSection = [self.happABModel.contactsSeparatedByFirstLetter objectAtIndex:section];
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
    NSArray *contactsForSection = [self.happABModel.contactsSeparatedByFirstLetter objectAtIndex:indexPath.section];
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
