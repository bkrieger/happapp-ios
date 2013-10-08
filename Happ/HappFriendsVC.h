//
//  HappFriendsVC.h
//  Happ
//
//  Created by Brandon Krieger on 10/7/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import "HappABModel.h"

@interface HappFriendsVC : UITableViewController

- (id)initWithAddressBook:(HappABModel *)addressBook;

- (void)dispose;

@end
