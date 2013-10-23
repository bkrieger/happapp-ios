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
#import "HappSettingsVC.h"
#import "HappModel.h"
#import "HappABModel.h"
#import "HappArcView.h"


@interface HappBoardVC ()

@property (nonatomic, strong) HappComposeVC *happCompose;
@property (nonatomic, strong) HappModel *model;
@property (nonatomic, strong) HappABModel *addressBook;

@property BOOL isRefreshing;

@property (nonatomic, strong) UIImageView *stillRefreshView;
@property (nonatomic) CGFloat originalStillRefreshViewHeight;
@property (nonatomic, strong) UIImageView *animatingRefreshView;
@property (nonatomic, strong) UIImageView *nothingIsHappeningView;
@property (nonatomic, strong) UIView *verticalLine;

@property (nonatomic, strong) UIToolbar *textBarContainerContainer;
@property (nonatomic, strong) UIControl *textBarContainer;
@property (nonatomic, strong) UILabel *textBar;
@property BOOL textBarShowing;
// We store the contacts in a set and an array because:
// we need an array to keep the order to display in the bottom bar;
// but we want to have constant time lookup because that happens often.
@property (nonatomic, strong) NSMutableSet *selectedContacts;
@property (nonatomic, strong) NSMutableArray *selectedContactsInOrder;

@property (nonatomic, strong) MFMessageComposeViewController *smsVC;

@end

@implementation HappBoardVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _addressBook = [[HappABModel alloc] init];
        _textBarShowing = NO;
        _isRefreshing = NO;
    }
    return self;
}

- (void)setUp {
    // Set Up model
    self.model = [[HappModel alloc] initWithHappABModel:self.addressBook delegate:self];
    [self refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = HAPP_PURPLE_COLOR;
    self.tableView.backgroundColor = HAPP_WHITE_COLOR;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIImage *titleImage = [UIImage imageNamed:@"hippo_profile_ios.png"];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleImage.size.width * 2, titleImage.size.height * 2)];
    [self.navigationItem.titleView addSubview:titleImageView];
    titleImageView.frame = CGRectMake(27, 27, titleImage.size.width, titleImage.size.height);
    
    // Refresh control
    UIView *refreshBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -600, 320, 630)];
    refreshBackgroundView.backgroundColor = [UIColor colorWithRed:237/255.0f green:201/255.0f blue:225/255.0f alpha:1.0f];
    [self.tableView addSubview:refreshBackgroundView];
    [self.tableView addSubview:self.stillRefreshView];
    // We use the UIRefreshControl to do all the work for us, but we cover it up with our own image.
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor clearColor];
    self.refreshControl = refreshControl;

    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(launchComposeView)];
    self.navigationItem.rightBarButtonItem = composeButton;
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(launchSettings)];
    self.navigationItem.leftBarButtonItem = settingsButton;

    // Get rid of padding that iOS adds by default around tableview
    self.tableView.contentInset = UIEdgeInsetsMake(-30, 0, -40, 0);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [self.model getMoodPersonCount];
    if (count == 0) {
        [self.tableView addSubview:self.nothingIsHappeningView];
        [self.verticalLine removeFromSuperview];
    } else {
        [self.nothingIsHappeningView removeFromSuperview];
        [self.tableView addSubview:self.verticalLine];
    }
    // Add 1 for "me"
    return count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    CGRect cellRect = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height * 2);
    cell.frame = cellRect;
    
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
    selectedView.backgroundColor = [UIColor clearColor];
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [HAPP_PURPLE_ALPHA_COLOR CGColor];
    sublayer.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height * .89);
    [selectedView.layer addSublayer:sublayer];
    cell.selectedBackgroundView = selectedView;

    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.hidden = YES;
    
    if (self.isRefreshing) {
        return cell;
    }
    
    NSDictionary *moodPerson;
    CGFloat nameLabelX;
    CGRect nameLabelRect;
    NSString *name;
    
    if ([indexPath row] == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(cellRect.origin.x + 10, cellRect.origin.y + 5, cellRect.size.width - 20, cellRect.size.height - 4);
        UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.layer.cornerRadius = 10;
        [cell.contentView addSubview:backgroundView];
        moodPerson = [self.model getMoodPersonForMe];
        
        nameLabelX = 20;
        nameLabelRect = CGRectMake(nameLabelX,
                                   8,
                                   210,
                                   cellRect.size.height / 3);
        name = @"Me";
    } else {
        // subtract 1 because row 0 is me person.
        moodPerson = [self.model getMoodPersonForIndex:[indexPath row] - 1];
        NSString *phoneNumber = [NSString stringWithFormat:@"%@", [moodPerson objectForKey:@"_id"]];
        UIColor *color = [self generateColor:[phoneNumber hash]];

        UIImage *personImage = [UIImage imageNamed:@"hippo_profile_ios.png"];
        UIImageView *personView = [[UIImageView alloc] initWithImage:personImage];
        personView.frame = CGRectMake(0, 0, personImage.size.width, personImage.size.height);

        HappArcView *leftIconView = [[HappArcView alloc] initWithColor:color angle:2];
        leftIconView.frame = CGRectMake(10, 8, personImage.size.width, personImage.size.height);
        leftIconView.layer.cornerRadius = leftIconView.frame.size.width / 2;
        leftIconView.layer.masksToBounds = YES;
        leftIconView.backgroundColor = color;
        [leftIconView addSubview:personView];
        [cell.contentView addSubview:leftIconView];
                
        nameLabelX = leftIconView.frame.origin.x + personView.frame.size.width + 15;
        nameLabelRect = CGRectMake(nameLabelX,
                                          leftIconView.frame.origin.y - 7,
                                          150,
                                          cellRect.size.height / 3);

        name = [NSString stringWithFormat:@"%@", [self.addressBook getNameForPhoneNumber:phoneNumber]];
    }
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    nameLabel.numberOfLines = 0;
    nameLabel.textColor = HAPP_PURPLE_COLOR;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.shadowOffset = CGSizeZero;
    nameLabel.shadowColor = [UIColor clearColor];
    nameLabel.text = name;

    if ([moodPerson objectForKey:@"message"]) {
        // Message...
        CGRect messageLabelRect = CGRectMake(nameLabelX,
                                             nameLabelRect.origin.y + nameLabelRect.size.height - 3,
                                             cellRect.size.width - nameLabelX - 80,
                                             nameLabelRect.size.height * 1.2);
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:messageLabelRect];
        messageLabel.text = [NSString stringWithFormat:@"%@", [moodPerson objectForKey:@"message"]];
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        messageLabel.numberOfLines = 0;
        [messageLabel sizeToFit];
        messageLabel.textColor = HAPP_BLACK_COLOR;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.shadowColor = [UIColor clearColor];
        messageLabel.shadowOffset = CGSizeZero;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        // Mood Icon or checkbox
        CGRect sideIconFrame = CGRectMake(self.tableView.frame.size.width - 65, nameLabelRect.origin.y + 10, 48, 48);
        if (self.textBarShowing && [self.selectedContacts containsObject:moodPerson]) {
            UIImageView *checkmarkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_ios.png"]];
            checkmarkIcon.frame = sideIconFrame;
            [cell.contentView addSubview:checkmarkIcon];
        } else {
            HappModelMood mood = [[NSString stringWithFormat:@"%@", [moodPerson objectForKey:@"tag"]] integerValue];
            HappModelMoodObject *moodObject = [self.model getMoodFor:mood];
            UIImageView *moodIcon = [[UIImageView alloc] initWithImage:moodObject.image];
            moodIcon.frame = sideIconFrame;
            [cell.contentView addSubview:moodIcon];
        }
        
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:messageLabel];
    } else {
        UILabel *happening = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height - 15)];
        happening.textAlignment = NSTextAlignmentCenter;
        happening.backgroundColor = [UIColor clearColor];
        happening.text = @"What's Happening?";
        happening.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:23];
        happening.textColor = HAPP_PURPLE_COLOR;
        [cell.contentView addSubview:happening];
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self launchComposeView];
    } else {
        NSDictionary *moodPerson = [self.model getMoodPersonForIndex:[indexPath row] - 1];
        if ([self.selectedContacts containsObject:moodPerson]) {
            // Contact was previously selected.
            [self.selectedContacts removeObject:moodPerson];
            [self.selectedContactsInOrder removeObject:moodPerson];
            if ([self.selectedContacts count] == 0) {
                // Now no contacts are selected, so remove the text bar.
                [self setTextBarEnabled:NO];
            } else {
                // If the bar is not going away, we need to update the text.
                [self updateTextBarText];
            }
        } else {
            // The contact was not already selected.
            [self.selectedContacts addObject:moodPerson];
            [self.selectedContactsInOrder addObject:moodPerson];
            if (!self.textBarShowing) {
                // This is the first selected person
                [self setTextBarEnabled:YES];
            }
            [self updateTextBarText];
        }
    }
    // Checkmarks will have changed, so we need to reload the table.
    [self.tableView reloadData];
}

#pragma mark MFMessageComposeViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self.smsVC dismissViewControllerAnimated:YES completion:nil];
    [self setTextBarEnabled:NO];
    [self.tableView reloadData];
}

#pragma mark - Scroll view delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Stretch the still hippo as you pull to refresh.
    CGFloat height = (scrollView.contentOffset.y * -1.0f) - 42.0f;
    
    if (height <= self.originalStillRefreshViewHeight) {
        self.stillRefreshView.transform = CGAffineTransformMakeRotation(0);
        if (height < 0) {
            height = 0;
        }
        self.stillRefreshView.frame = CGRectMake(self.stillRefreshView.frame.origin.x, -height + 20, self.stillRefreshView.frame.size.width, height);
    } else {
        CGFloat difference = height - self.originalStillRefreshViewHeight;
        if (difference > 53.0f) {
            difference = 53.0f;
            if (!self.isRefreshing) {
                // If we go up high enough, start refreshing
                [self refreshControlStarted];
            }
        }
        self.stillRefreshView.transform = CGAffineTransformMakeRotation(difference * .093f);
    }
}

#pragma mark - HappModelDelegate methods

- (void)modelIsReady {
    [self.tableView reloadData];
    [self refreshControlFinished];
    [self setTextBarEnabled:NO];
    self.isRefreshing = NO;
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

#pragma mark - Getters

- (UIToolbar *)textBarContainerContainer {
    if (!_textBarContainerContainer) {
        CGRect frame = CGRectMake(0, self.tableView.frame.size.height, self.tableView.frame.size.width, 40);
        _textBarContainerContainer = [[UIToolbar alloc] initWithFrame:frame];
        _textBarContainerContainer.barTintColor = HAPP_PURPLE_COLOR;
        [_textBarContainerContainer addSubview:self.textBarContainer];
    }
    return _textBarContainerContainer;
}

- (UIControl *)textBarContainer {
    if (!_textBarContainer) {
        CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, 40);
        _textBarContainer = [[UIControl alloc] initWithFrame:frame];
//        _textBarContainer.backgroundColor = HAPP_PURPLE_COLOR;
        [_textBarContainer addSubview:self.textBar];
        [_textBarContainer addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
    }
    return _textBarContainer;
}

- (UILabel *)textBar {
    if (!_textBar) {
        CGRect frame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, 40);
        _textBar = [[UILabel alloc] initWithFrame:frame];
        _textBar.lineBreakMode = NSLineBreakByTruncatingHead;
        _textBar.textColor = HAPP_WHITE_COLOR;
    }
    return _textBar;
}

- (UIImageView *)stillRefreshView {
    if (!_stillRefreshView) {
        UIImage *image = [UIImage imageNamed:@"still_hippo.png"];
        self.originalStillRefreshViewHeight = image.size.height;
        CGRect frame = CGRectMake(
                                  (self.tableView.frame.size.width - image.size.width) / 2,
                                  -20,
                                  image.size.width,
                                  image.size.height);
        _stillRefreshView = [[UIImageView alloc] initWithImage:image];
        _stillRefreshView.frame = frame;
    }
    return _stillRefreshView;
}

- (UIImageView *)animatingRefreshView {
    if (!_animatingRefreshView) {
        UIImage *image1 = [UIImage imageNamed:@"dancing_hippo1.png"];
        UIImage *image2 = [UIImage imageNamed:@"dancing_hippo2.png"];
        UIImage *image3 = [UIImage imageNamed:@"dancing_hippo3.png"];
        UIImage *image4 = [UIImage imageNamed:@"dancing_hippo4.png"];
        UIImage *image5 = [UIImage imageNamed:@"dancing_hippo5.png"];
        UIImage *image6 = [UIImage imageNamed:@"dancing_hippo6.png"];
        UIImage *image7 = [UIImage imageNamed:@"dancing_hippo7.png"];
        CGRect frame = CGRectMake(
                                  (self.tableView.frame.size.width - image1.size.width) / 2,
                                  -25,
                                  image1.size.width,
                                  image1.size.height);
        _animatingRefreshView = [[UIImageView alloc] initWithFrame:frame];
        _animatingRefreshView.animationImages = [NSArray arrayWithObjects:image1, image2, image3, image4, image5, image6, image7, nil];
        _animatingRefreshView.animationDuration = 0.5f;
        _animatingRefreshView.animationRepeatCount = 0;
    }
    return _animatingRefreshView;
}

- (UIView *)verticalLine {
    if (!_verticalLine) {
        CGRect frame = CGRectMake(38, -self.tableView.bounds.size.height, 4,
                                             self.tableView.bounds.size.height * 3);
        _verticalLine = [[UIView alloc] initWithFrame:frame];
        _verticalLine.backgroundColor = HAPP_PURPLE_ALPHA_COLOR;
        _verticalLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _verticalLine.layer.zPosition = -1;
    }
    return _verticalLine;
}

- (UIImageView *)nothingIsHappeningView {
    if (!_nothingIsHappeningView) {
        // Nothing is happening
        UIImage *nothingIsHappeningImage = [UIImage imageNamed:@"sad_hippo_xhdpi.png"];
        _nothingIsHappeningView = [[UIImageView alloc] initWithImage:nothingIsHappeningImage];
        _nothingIsHappeningView.frame = CGRectMake(
                                                   (self.tableView.frame.size.width - nothingIsHappeningImage.size.width) / 2,
                                                   130,
                                                   nothingIsHappeningImage.size.width,
                                                   nothingIsHappeningImage.size.height);
    }
    return _nothingIsHappeningView;
}

- (NSMutableSet *)selectedContacts {
    if (!_selectedContacts) {
        _selectedContacts = [[NSMutableSet alloc] init];
    }
    return _selectedContacts;
}

- (NSMutableArray *)selectedContactsInOrder {
    if (!_selectedContactsInOrder) {
        _selectedContactsInOrder = [[NSMutableArray alloc] init];
    }
    return _selectedContactsInOrder;
}

- (HappComposeVC *)happCompose {
    if (!_happCompose) {
        _happCompose = [[HappComposeVC alloc] initWithDelegate:self dataSource:self.model];
        _happCompose.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _happCompose.modalPresentationStyle = UIModalPresentationCurrentContext;
        _happCompose.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    return _happCompose;
}

#pragma mark - selectors

- (void)launchComposeView
{
    [self setTextBarEnabled:NO];
    [[self navigationController] presentViewController:self.happCompose animated:YES completion:nil];
}

//- (void)launchFriends {
//    [self setTextBarEnabled:NO];
//    HappFriendsVC *happFriendsVC = [[HappFriendsVC alloc] initWithHappABModel:self.addressBook happModel:self.model];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:happFriendsVC];
//
//    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentViewController:navController animated:YES completion:nil];
//}

- (void)launchSettings {
    [self setTextBarEnabled:NO];
    HappSettingsVC *happSettingsVC = [[HappSettingsVC alloc] initWithHappABModel:self.addressBook happModel:self.model];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:happSettingsVC];
    
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)sendText {
    if ([MFMessageComposeViewController canSendText]) {
        self.smsVC.recipients = [self.selectedContactsInOrder valueForKey:@"_id"];
        self.smsVC.messageComposeDelegate = self;
        [self presentViewController:self.smsVC animated:YES completion:nil];
    }
}

#pragma mark - Helpers

- (void)refreshControlStarted {
    [self refresh];
    [self.stillRefreshView removeFromSuperview];
    [self.tableView addSubview:self.animatingRefreshView];
    [self.animatingRefreshView startAnimating];
}

- (void)refreshControlFinished {
    [self.animatingRefreshView stopAnimating];
    [self.animatingRefreshView removeFromSuperview];
    [self.tableView addSubview:self.stillRefreshView];
    [self.refreshControl endRefreshing];
}

- (void)refresh {
    self.isRefreshing = YES;
    [self.model refresh];
}

- (UIColor *)generateColor:(NSInteger)phoneNumber {
    NSArray *colors = @[[UIColor colorWithRed:4/255.0f green:4/255.0f blue:170/255.0f alpha:1.0f],
                        [UIColor colorWithRed:4/255.0f green:167/255.0f blue:170/255.0f alpha:1.0f],
                        [UIColor colorWithRed:4/255.0f green:170/255.0f blue:43/255.0f alpha:1.0f],
                        [UIColor colorWithRed:170/255.0f green:40/255.0f blue:4/255.0f alpha:1.0f],
                        [UIColor colorWithRed:255/255.0f green:216/255.0f blue:30/255.0f alpha:1.0f],
                        [UIColor colorWithRed:31/255.0f green:196/255.0f blue:222/255.0f alpha:1.0f],
                        [UIColor colorWithRed:250/255.0f green:117/255.0f blue:0/255.0f alpha:1.0f]];
    NSInteger index = phoneNumber % [colors count];
    return [colors objectAtIndex:index];
}

- (void)setTextBarEnabled:(BOOL)enabled {
    if (enabled && [MFMessageComposeViewController canSendText]) {
        [self.navigationController.view addSubview:self.textBarContainerContainer];
        CGRect onScreenFrame = CGRectMake(0, self.tableView.frame.size.height - 40, self.tableView.frame.size.width, 40);
        [UIView animateWithDuration:0.25 animations:^{
            self.textBarContainerContainer.frame = onScreenFrame;
            self.tableView.contentInset = UIEdgeInsetsMake(34, 0, 0, 0);
        }];
        self.textBarShowing = YES;
        self.smsVC = [[MFMessageComposeViewController alloc] init];
    } else {
        CGRect offScreenFrame = CGRectMake(0, self.tableView.frame.size.height, self.tableView.frame.size.width, 40);
        [UIView animateWithDuration:0.25 animations:^{
            self.textBarContainerContainer.frame = offScreenFrame;
            self.tableView.contentInset = UIEdgeInsetsMake(34, 0, -40, 0);
        } completion:^(BOOL finished) {
            [self.textBarContainerContainer removeFromSuperview];
        }];
        self.textBarShowing = NO;
        [self.selectedContacts removeAllObjects];
        [self.selectedContactsInOrder removeAllObjects];
    }
}

- (void)updateTextBarText {
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:[self.selectedContactsInOrder count]];
    for (NSDictionary *moodPerson in self.selectedContactsInOrder) {
        NSString *phoneNumber = [NSString stringWithFormat:@"%@", [moodPerson objectForKey:@"_id"]];
        NSString *name = [NSString stringWithFormat:@"%@", [self.addressBook getNameForPhoneNumber:phoneNumber]];
        NSString *firstName = [[name componentsSeparatedByString:@" "] objectAtIndex:0];
        [names addObject:firstName];
    }
    self.textBar.text = [NSString stringWithFormat:@"Text %@", [names componentsJoinedByString:@", "]];
}

- (void)removeHappComposeVC {
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
    
    [self.happCompose dispose];
    self.happCompose = nil;
    [self.refreshControl beginRefreshing];
    [self refresh];
}

@end
