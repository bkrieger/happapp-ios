//
//  HappModel.h
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HappModelDelegate;

@interface HappModel : NSObject<NSURLConnectionDataDelegate>

- (id)initWithUrl:(NSString *)url
         delegate:(NSObject<HappModelDelegate> *)delegate;

- (void)refresh;

- (NSInteger)getMoodPersonCount;
- (NSDictionary *)getMoodPersonForIndex:(NSInteger)index;

@end
