//
//  HappABModel.m
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#define BLOCKED_NUMBERS_KEY @"blockedNumbers"

#import "HappABModel.h"

@interface HappABModel()
@property (nonatomic, strong) NSDictionary *phoneNumberNameMap;
@end

@implementation HappABModel

- (NSString *)getUrlFromContactsWithSeparator:(NSString *)separator {
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        self.phoneNumberNameMap = nil;
    }
    NSMutableArray *allPhoneNumbers = [[NSMutableArray alloc] initWithArray:[self.phoneNumberNameMap allKeys]];
    
    NSArray *blockedNumbers = [[NSUserDefaults standardUserDefaults] arrayForKey:BLOCKED_NUMBERS_KEY];
    if (blockedNumbers) {
        [allPhoneNumbers removeObjectsInArray:blockedNumbers];
    }
    return [separator stringByAppendingString:[allPhoneNumbers componentsJoinedByString:separator]];
}

- (NSString *)getNameForPhoneNumber:(NSString *)phoneNumber {
    return [self.phoneNumberNameMap objectForKey:[NSString
        stringWithFormat:@"%@",phoneNumber]];
}

-(NSSet *)getBlockedNumbers {
    NSArray *blockedNumbers = [[NSUserDefaults standardUserDefaults] arrayForKey:BLOCKED_NUMBERS_KEY];
    if (!blockedNumbers) {
        blockedNumbers = [[NSArray alloc] init];
    }
    return [NSSet setWithArray:blockedNumbers];
}

-(void)setPerson:(ABRecordRef)person blocked:(BOOL)blocked {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *previousBlockedNumbers = [userDefaults arrayForKey:BLOCKED_NUMBERS_KEY];
    NSMutableSet *newBlockedNumbers;
    if (previousBlockedNumbers) {
        newBlockedNumbers = [[NSMutableSet alloc] initWithArray:previousBlockedNumbers];
    } else {
        newBlockedNumbers = [[NSMutableSet alloc] init];
    }
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
        NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        NSString *sanitizedPhoneNumber = [self sanitizePhoneNumber:phoneNumber];
        if (sanitizedPhoneNumber) {
            if (blocked) {
                [newBlockedNumbers addObject:sanitizedPhoneNumber];
            } else {
                [newBlockedNumbers removeObject:sanitizedPhoneNumber];
            }
        }
    }
    
    [userDefaults setObject:[newBlockedNumbers allObjects] forKey:BLOCKED_NUMBERS_KEY];
    [userDefaults synchronize];
    NSLog(@"Blocked Numbers: %@", newBlockedNumbers);
}

- (NSDictionary *)phoneNumberNameMap {
    if (!_phoneNumberNameMap) {
        NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
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
                NSString *sanitizedPhoneNumber = [self sanitizePhoneNumber:phoneNumber];
                if (sanitizedPhoneNumber) {
                    [map setObject:personName forKey:[sanitizedPhoneNumber substringFromIndex:[sanitizedPhoneNumber length] - 10]];
                }
            }
        }
        _phoneNumberNameMap = map;
    }
    return _phoneNumberNameMap;
}

- (NSString *) sanitizePhoneNumber:(NSString *)phoneNumber {
    NSString *sanitizedPhoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])];
    if ([sanitizedPhoneNumber length] >= 10) {
        return [sanitizedPhoneNumber substringFromIndex:[sanitizedPhoneNumber length] - 10];
    } else {
        return nil;
    }
}

@end
