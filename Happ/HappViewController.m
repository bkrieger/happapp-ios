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
#import <AddressBookUI/AddressBookUI.h>

@interface HappViewController ()

@property HappBoardVC *happBoard;

@end

@implementation HappViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAppState:) name:HAPP_RESET_NOTIFICATION object:nil];

    self.navigationBar.barTintColor = HAPP_PURPLE_COLOR;
    [UINavigationBar appearance].alpha = 0.f;
    [UINavigationBar appearance].barStyle = UIBarStyleBlackTranslucent;
    [UINavigationBar appearance].tintColor = HAPP_WHITE_COLOR;
    self.view.backgroundColor = HAPP_WHITE_COLOR;
    
    [self prepareForStartup];
}

- (void)prepareForStartup {
    NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] stringForKey:PHONE_NUMBER_KEY];
    if (!phoneNumber) {
        // The user has yet to verify their phone number
        [self pushViewController:[[HappEnterPhoneViewController alloc] init] animated:NO];
    } else {
        // Phone number is verified, now make sure we have Contacts permission.
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                // First time access has been asked for.
                if (granted) {
                    [self startApp];
                } else {
                    [self displayWarningCantAccessContacts];
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access
            [self startApp];
        }
        else {
            // The user has previously denied access
            [self displayWarningCantAccessContacts];
        }
    }
}

- (void)startApp {
    self.happBoard = [[HappBoardVC alloc] initWithStyle:UITableViewStyleGrouped];
    [self.happBoard setUp];
    [self pushViewController:self.happBoard animated:NO];
}

- (void)displayWarningCantAccessContacts {
    [[[UIAlertView alloc] initWithTitle:@"Contacts access is necessary"
                                message:@"Please go into the iOS settings and "
                                        "give Happ permission to access your "
                                        "contacts.\n\nLocated in\nSettings > Privacy > Contacts"
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:nil] show];
}

- (void)resetAppState:(NSNotification *)notification {
    self.viewControllers = @[];
    [self prepareForStartup];
}

@end
