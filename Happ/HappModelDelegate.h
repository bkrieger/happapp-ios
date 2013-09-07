//
//  Header.h
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HappModelDelegate <NSObject>

- (void)modelIsReady;

- (void)modelDidPost;

@end