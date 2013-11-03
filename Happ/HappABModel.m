//
//  HappABModel.m
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#define BLOCKED_NUMBERS_KEY @"blockedNumbers"

#import "HappABModel.h"
#import "HappModelEnums.h"

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

-(BOOL)isPersonBlocked:(ABRecordRef)person {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *blockedNumbersArray = [userDefaults arrayForKey:BLOCKED_NUMBERS_KEY];
    if (!blockedNumbersArray) {
        return NO;
    }
    NSSet *blockedNumbers = [NSSet setWithArray:blockedNumbersArray];
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSInteger phoneNumbersCount = ABMultiValueGetCount(phoneNumbers);
    for (CFIndex i = 0; i < phoneNumbersCount; i++) {
        NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        NSString *sanitizedPhoneNumber = [self sanitizePhoneNumber:phoneNumber];
        if (sanitizedPhoneNumber && [blockedNumbers containsObject:sanitizedPhoneNumber]) {
            // Person has a number that is blocked.
            return YES;
        }
    }
    // None of the phone numbers were blocked;
    return NO;
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
    NSInteger phoneNumbersCount = ABMultiValueGetCount(phoneNumbers);
    for (CFIndex i = 0; i < phoneNumbersCount; i++) {
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
}

- (void)unblockAllContacts {
    NSArray *blockedNumbers = [[NSArray alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:blockedNumbers forKey:BLOCKED_NUMBERS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)phoneNumberNameMap {
    if (!_phoneNumberNameMap) {
        NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        NSArray *allPeople = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (id person in allPeople) {
            ABRecordRef personRecord = (__bridge ABRecordRef)person;
            NSString *personName = [self fullNameForPerson:personRecord];
            if (personName) {
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(personRecord, kABPersonPhoneProperty);
                NSInteger phoneNumberCount = ABMultiValueGetCount(phoneNumbers);
                for (int j = 0; j < phoneNumberCount; j++) {
                    NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                    NSString *sanitizedPhoneNumber = [self sanitizePhoneNumber:phoneNumber];
                    if (sanitizedPhoneNumber && [sanitizedPhoneNumber length] >= 10) {
                        [map setObject:personName forKey:sanitizedPhoneNumber];
                    }
                }
            }
        }
        _phoneNumberNameMap = map;
    }
    return _phoneNumberNameMap;
}

- (NSString *) fullNameForPerson:(ABRecordRef)person {
    NSString *firstName =
    (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName =
    (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    NSString *personName;
    if (firstName && lastName) {
        personName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    } else if (firstName) {
        personName = firstName;
    } else if (lastName) {
        personName = lastName;
    }
    return personName;
}

- (NSString *) sanitizePhoneNumber:(NSString *)phoneNumber {
    NSString *sanitizedPhoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])];
    if ([sanitizedPhoneNumber length] >= 10) {
        return [sanitizedPhoneNumber substringFromIndex:[sanitizedPhoneNumber length] - 10];
    } else {
        return sanitizedPhoneNumber;
    }
}

#pragma mark - getters

- (NSArray *)contactsSeparatedByFirstLetter {
    if (!_contactsSeparatedByFirstLetter) {
        // 27 = alphabet + #
        NSMutableArray *lettersArray = [[NSMutableArray alloc] initWithCapacity:27];
        for (int i = 0; i < 27; i++) {
            [lettersArray addObject:[[NSMutableArray alloc] init]];
        }
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        NSArray *allPeople = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (id person in allPeople) {
            ABRecordRef personRecord = (__bridge ABRecordRef)person;
            NSString *name;
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(personRecord, kABPersonFirstNameProperty));
            if (firstName && [firstName length] > 0) {
                // First name exists, we should use it.
                name = [firstName lowercaseString];
            } else {
                NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(personRecord, kABPersonLastNameProperty));
                if (lastName && [lastName length] > 0) {
                    // Last name exists but first name does not.
                    name = [lastName lowercaseString];
                } else {
                    // Neither name exists, don't add this person to the array.
                    continue;
                }
            }
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(personRecord, kABPersonPhoneProperty);
            NSInteger phoneNumberCount = ABMultiValueGetCount(phoneNumbers);
            if (phoneNumberCount > 0) {
                unichar firstCharacter = [name characterAtIndex:0];
                unsigned short index = firstCharacter - 'a';
                NSMutableArray *innerArray;
                if (index >= 0 && index < 26) {
                    // The name starts with a letter.
                    innerArray = [lettersArray objectAtIndex:index];
                } else {
                    // The name does not start with a letter.
                    innerArray = [lettersArray objectAtIndex:26];
                }
                // Add the person to the proper inner array.
                [innerArray addObject:person];
            }
        }
        _contactsSeparatedByFirstLetter = lettersArray;
    }
    return _contactsSeparatedByFirstLetter;
}

@end
