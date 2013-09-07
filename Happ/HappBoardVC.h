//
//  HappBoardVCViewController.h
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HappModelDelegate.h"

@interface HappBoardVC : UITableViewController<HappModelDelegate>

// Must be called after initialization.
- (void)setUp;

@end
