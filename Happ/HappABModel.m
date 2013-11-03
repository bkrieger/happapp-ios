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
    
    for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
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
}

- (void)unblockAllContacts {
    NSArray *blockedNumbers = [[NSArray alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:blockedNumbers forKey:BLOCKED_NUMBERS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)phoneNumberNameMap {
    if (!_phoneNumberNameMap) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *persistentDictionary = [userDefaults dictionaryForKey:PHONE_NUMBER_NAME_MAP_KEY];
        
        if (persistentDictionary) {
            _phoneNumberNameMap = persistentDictionary;
        } else {
            NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
            
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
            for ( int i = 0; i < ABAddressBookGetPersonCount(addressBook); i++ )
            {
                NSLog(@"%d",i);
                ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                NSString *personName = [self fullNameForPerson:person];
                if (personName) {
                    for (int j = 0; j < ABMultiValueGetCount(phoneNumbers); j++) {
                        NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                        NSString *sanitizedPhoneNumber = [self sanitizePhoneNumber:phoneNumber];
                        if (sanitizedPhoneNumber && [sanitizedPhoneNumber length] >= 10) {
                            [map setObject:personName forKey:sanitizedPhoneNumber];
                        }
                    }
                }
            }
            _phoneNumberNameMap = map;
            // store map persistenly
            [userDefaults setObject:_phoneNumberNameMap forKey:PHONE_NUMBER_NAME_MAP_KEY];
            [userDefaults synchronize];
        }
        
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

// This getter will also reload contacts into phoneNumberNameMap, in case address book has changed
- (NSArray *)contactsSeparatedByFirstLetter {
    if (!_contactsSeparatedByFirstLetter) {
        
        NSMutableDictionary *phoneNumberNameMap = [[NSMutableDictionary alloc] init];
        
        // 27 = alphabet + #
        NSMutableArray *lettersArray = [[NSMutableArray alloc] initWithCapacity:27];
        for (int i = 0; i < 27; i++) {
            [lettersArray addObject:[[NSMutableArray alloc] init]];
        }
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (int i = 0; i < ABAddressBookGetPersonCount(addressBook); i++) {
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            NSString *name;
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            if (firstName && [firstName length] > 0) {
                // First name exists, we should use it.
                name = [firstName lowercaseString];
            } else {
                NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                if (lastName && [lastName length] > 0) {
                    // Last name exists but first name does not.
                    name = [lastName lowercaseString];
                } else {
                    // Neither name exists, don't add this person to the array.
                    continue;
                }
            }
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            if (ABMultiValueGetCount(phoneNumbers) > 0) {
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
                [innerArray addObject:(__bridge id)(person)];
                
                // Put new phone number in phoneNumberNameMap
                for (int j = 0; j < ABMultiValueGetCount(phoneNumbers); j++) {
                    NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                    NSString *sanitizedPhoneNumber = [self sanitizePhoneNumber:phoneNumber];
                    if (sanitizedPhoneNumber && [sanitizedPhoneNumber length] >= 10) {
                        [phoneNumberNameMap setObject:name forKey:sanitizedPhoneNumber];
                    }
                }
            }
        }
        _contactsSeparatedByFirstLetter = lettersArray;
        _phoneNumberNameMap = phoneNumberNameMap;
    }
    return _contactsSeparatedByFirstLetter;
}

@end
