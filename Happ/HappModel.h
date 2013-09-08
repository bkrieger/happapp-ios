//
//  HappModel.h
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HappModelEnums.h"
#import "HappComposeVCDataSource.h"

@protocol HappModelDelegate;

@interface HappModel : NSObject<NSURLConnectionDataDelegate,
                                HappComposeVCDataSource>

- (id)initWithGetUrl:(NSString *)getUrl
             postUrl:(NSString *)postUrl
            delegate:(NSObject<HappModelDelegate> *)delegate;
    
- (void)refresh;

- (void)postWithMessage:(NSString *)message
                   mood:(HappModelMood)mood
               duration:(HappModelDuration)duration;
- (NSInteger)getMoodPersonCount;
- (NSDictionary *)getMoodPersonForIndex:(NSInteger)index;



@end


@interface HappModelMoodObject : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) UIImage *imageInverse;
@property HappModelMood mood;

- (id)initWithTitle:(NSString *)title
               mood:(HappModelMood)mood
              image:(UIImage *)image
       imageInverse:(UIImage *)imageInverse;

@end


@interface HappModelDurationObject : NSObject

@property (nonatomic, readonly) NSString *title;
@property HappModelDuration duration;

- (id)initWithTitle:(NSString *)title duration:(HappModelDuration)duration;

@end