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

- (NSString *)getUrlFromContacts:(NSString *)prefix
                       separator:(NSString *)separator {
    NSArray *allPhoneNumbers = [self.phoneNumberNameMap allKeys];

    return [prefix stringByAppendingString:[allPhoneNumbers componentsJoinedByString:separator]];
}

- (NSString *)getNameForPhoneNumber:(NSString *)phoneNumber {
    NSLog(@"query: [%@],\n map: %@\n\n", phoneNumber, self.phoneNumberNameMap);
    NSLog(@"%@", [NSString stringWithString:phoneNumber]);
    return [self.phoneNumberNameMap objectForKey:[NSString stringWithString:phoneNumber]];
}

- (NSDictionary *)phoneNumberNameMap {
    if (!_phoneNumberNameMap) {
        NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
        
        for ( int i = 0; i < ABAddressBookGetPersonCount(addressBook); i++ )
        {
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            NSString *firstName =
                (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName =
                (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            NSString *personName =
                [[firstName stringByAppendingString:@" "] stringByAppendingString:lastName];
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                [map setObject:personName forKey:[phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])]];
            }
        }
        _phoneNumberNameMap = map;
    }
    return _phoneNumberNameMap;
}

@end
