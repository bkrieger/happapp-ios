//
//  HappBoardVCViewController.m
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HappBoardVC.h"
#import "HappComposeVC.h"
#import "HappModel.h"
#import "HappABModel.h"

#define HAPP_URL_PREFIX @"http://158.130.107.180:3000/api/moods?"
#define HAPP_URL_SEPARATOR @"&n[]="
#define HAPP_URL_GET_PREFIX @"http://158.130.107.180:3000/api/moods?n[]="


@interface HappBoardVC ()

@property (nonatomic, strong) HappComposeVC *happCompose;
@property HappModel *model;
@property HappABModel *addressBook;

@end

@implementation HappBoardVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _addressBook = [[HappABModel alloc] init];
    }
    return self;
}

- (void)setUp {
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"witewall_3_@2x.png"]];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Vertical Line
    CGRect vertivalLineRect = CGRectMake(50, 0, 4,
                                         self.tableView.backgroundView.bounds.size.height);
    UIView *verticalLine = [[UIView alloc] initWithFrame:vertivalLineRect];
    verticalLine.backgroundColor = HAPP_DIVIDER_COLOR;
    verticalLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.tableView.backgroundView addSubview:verticalLine];
    
    // Set Up model
    self.model = [[HappModel alloc] initWithGetUrl:[self.addressBook
        getUrlFromContacts:HAPP_URL_GET_PREFIX
                 separator:HAPP_URL_SEPARATOR]
                                           postUrl:HAPP_URL_PREFIX
                                          delegate:self];
    [self.model refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithTitle:@"Compose"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(launchComposeView:)];
    [[self navigationItem] setRightBarButtonItem:composeButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)launchComposeView:(id)sender
{
    [[self navigationController] presentViewController:self.happCompose animated:YES completion:nil];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.model getMoodPersonCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    CGRect cellRect = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height * 2);
    cell.frame = cellRect;

    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.hidden = YES;
    NSDictionary *moodPerson = [self.model getMoodPersonForIndex:[indexPath row]];
    
    UIImage *personImage = [UIImage imageNamed:@"happ_2x.png"];
    UIImageView *personView = [[UIImageView alloc] initWithImage:personImage];
    personView.frame = CGRectMake(10, 8, 60, 60);
    personView.layer.cornerRadius = personView.frame.size.width / 2;
    personView.layer.masksToBounds = YES;
  
    [cell.contentView addSubview:personView];
    
//    CGRect nameRect = CGrectMake
    CGFloat nameLabelX = personView.frame.origin.x + personView.frame.size.width + 15;
    CGRect nameLabelRect = CGRectMake(nameLabelX,
                                      personView.frame.origin.y,
                                      cellRect.size.width - nameLabelX,
                                      cellRect.size.height / 3);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    nameLabel.textColor = HAPP_PURPLE_COLOR;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.shadowColor = [UIColor clearColor];
    NSString *phoneNumber = [NSString stringWithFormat:@"%@", [moodPerson objectForKey:@"_id"]];
    NSString *message = [NSString stringWithFormat:@"%@", [moodPerson objectForKey:@"message"]];
    nameLabel.text = [NSString stringWithFormat:@"%@", [self.addressBook getNameForPhoneNumber:phoneNumber]];
    
    CGRect messageLabelRect = CGRectMake(nameLabelX,
                                      personView.frame.origin.y + nameLabelRect.size.height + 2,
                                      cellRect.size.width - nameLabelX - 80,
                                      (cellRect.size.height / 3) * 2);
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:messageLabelRect];
    messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    messageLabel.textColor = HAPP_BLACK_COLOR;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.shadowColor = [UIColor clearColor];
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.numberOfLines = 2;
    messageLabel.text = message;
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:messageLabel];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (HappComposeVC *)happCompose {
    if (!_happCompose) {
        _happCompose = [[HappComposeVC alloc] initWithDelegate:self dataSource:self.model];
        _happCompose.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        _happCompose.modalPresentationStyle = UIModalPresentationCurrentContext;
        _happCompose.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    return _happCompose;
}

- (void)removeHappComposeVC {
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
    
    [self.happCompose dispose];
    self.happCompose = nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - HappModelDelegate methods

- (void)modelIsReady {
    [self.tableView reloadData];
}

- (void)modelDidPost {
    [self removeHappComposeVC];
}

#pragma mark - HappComposeVCDelegate methods

- (void)postWithMessage:(NSString *)message mood:(HappModelMood)mood duration:(HappModelDuration)duration {
    [self.model postWithMessage:message mood:mood duration:duration];
}

- (void)cancelCompose {
    [self removeHappComposeVC];
}

@end
