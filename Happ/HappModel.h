//
//  HappModel.h
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HappModelEnums.h"
#import "HappComposeVCDelegate.h"
#import "HappComposeVCDataSource.h"

@protocol HappModelDelegate;

@interface HappModel : NSObject<NSURLConnectionDataDelegate,
                                HappComposeVCDelegate,
                                HappComposeVCDataSource>

- (id)initWithGetUrl:(NSString *)getUrl
             postUrl:(NSString *)postUrl
            delegate:(NSObject<HappModelDelegate> *)delegate;
    
- (void)refresh;


- (NSInteger)getMoodPersonCount;
- (NSDictionary *)getMoodPersonForIndex:(NSInteger)index;

@end

@interface HappModelMoodObject : NSObject

- (id)initWithTitle:(NSString *)title;

- (NSString *)title;

@end
