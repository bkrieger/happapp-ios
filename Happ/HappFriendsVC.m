//
//  HappFriendsVC.m
//  Happ
//
//  Created by Brandon Krieger on 10/7/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappFriendsVC.h"

@interface HappFriendsVC ()

@property (nonatomic, strong) HappABModel *addressBook;

@end

@implementation HappFriendsVC

- (id)initWithAddressBook:(HappABModel *)addressBook {
    self = [super init];
    if (self) {
        _addressBook = addressBook;
    }
    return self;
}

- (void)dispose {
    self.addressBook = nil;
}

@end
