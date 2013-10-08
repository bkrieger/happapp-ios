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

- (NSString *)getUrlFromContactsWithSeparator:(NSString *)separator;

- (NSString *)getNameForPhoneNumber:(NSString *)phoneNumber;

- (NSSet *)getBlockedNumbers;

- (void)setPerson:(ABRecordRef)person blocked:(BOOL)blocked;
@end
