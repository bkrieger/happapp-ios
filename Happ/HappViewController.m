//
//  HappViewController.m
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappViewController.h"
#import "HappBoardVC.h"

@interface HappViewController ()

@property HappBoardVC *happBoard;

@end

@implementation HappViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.happBoard = [[HappBoardVC alloc] initWithStyle:UITableViewStylePlain];
    self.navigationBar.tintColor = [UIColor colorWithRed:130/255.0f green:4/255.0f blue:112/255.0f alpha:1.0f];
    self.navigationBar.barStyle = UIBarStyleDefault;
    [self.happBoard setUp];
    [self pushViewController:self.happBoard animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
