//
//  HappABModel.m
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappABModel.h"
#import <AddressBook/AddressBook.h>

@interface HappABModel()
@property (nonatomic, strong) NSDictionary *phoneNumberNameMap;
@end

@implementation HappABModel

- (NSString *)getUrlFromContactsWithSeparator:(NSString *)separator {
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        self.phoneNumberNameMap = nil;
    }
    NSArray *allPhoneNumbers = [self.phoneNumberNameMap allKeys];

    return [separator stringByAppendingString:[allPhoneNumbers componentsJoinedByString:separator]];
}

- (NSString *)getNameForPhoneNumber:(NSString *)phoneNumber {
    return [self.phoneNumberNameMap objectForKey:[NSString
        stringWithFormat:@"%@",phoneNumber]];
}

- (NSDictionary *)phoneNumberNameMap {
    if (!_phoneNumberNameMap) {
        NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
            for ( int i = 0; i < ABAddressBookGetPersonCount(addressBook); i++ )
            {
                ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                NSString *firstName =
                (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                NSString *lastName =
                (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                NSString *personName = @"";
                if (firstName) {
                    personName = [NSString stringWithFormat:@"%@%@", personName, firstName];
                }
                if (lastName) {
                    if (firstName) {
                        personName = [NSString stringWithFormat:@"%@%@", personName, @" "];
                    }
                    personName = [NSString stringWithFormat:@"%@%@", personName, lastName];
                }
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                
                for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                    NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                    NSString *sanitizedPhoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])];
                    if ([sanitizedPhoneNumber length] >= 10) {
                        [map setObject:personName forKey:[sanitizedPhoneNumber substringFromIndex:[sanitizedPhoneNumber length] - 10]];
                    }
                }
            }
        }
        _phoneNumberNameMap = map;
    }
    return _phoneNumberNameMap;
}

@end
