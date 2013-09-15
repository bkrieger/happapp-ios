//
//  HappViewController.m
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappViewController.h"
#import "HappEnterPhoneViewController.h"
#import "HappBoardVC.h"
#import "HappModelEnums.h"
#import <MessageUI/MessageUI.h>

@interface HappViewController ()

@property HappBoardVC *happBoard;

@end

@implementation HappViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationBar.tintColor = HAPP_PURPLE_COLOR;
    self.navigationBar.barStyle = UIBarStyleDefault;
    NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"phoneNumber"];
    if (phoneNumber) {
        self.happBoard = [[HappBoardVC alloc] initWithStyle:UITableViewStyleGrouped];
        [self.happBoard setUp];
        [self pushViewController:self.happBoard animated:NO];
    } else {
        [self pushViewController:[[HappEnterPhoneViewController alloc] init] animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
