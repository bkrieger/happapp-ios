//
//  HappABModel.h
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface HappABModel : NSObject

// This is an NSArray<NSArray<ABRecordRef>>.
// The outer array has an array for each character of the alphabet,
// the inner array contains the records that start with that character.
@property (nonatomic, strong) NSArray *contactsSeparatedByFirstLetter;

- (NSString *)getUrlFromContactsWithSeparator:(NSString *)separator;

- (NSString *)getNameForPhoneNumber:(NSString *)phoneNumber;

- (BOOL)isPersonBlocked:(ABRecordRef)person;

- (void)setPerson:(ABRecordRef)person blocked:(BOOL)blocked;

- (void)unblockAllContacts;

- (NSString *)fullNameForPerson:(ABRecordRef)person;

@end
