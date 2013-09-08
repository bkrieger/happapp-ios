#import "HappModelEnums.h"

@class HappModelMoodObject;
@class HappModelDurationObject;


@protocol HappComposeVCDataSource <NSObject>

- (NSArray *)getDurations;

- (HappModelDurationObject *)getDurationFor:(HappModelDuration)duration;

- (NSInteger)getIndexForDuration:(HappModelDuration)duration;

- (NSInteger)getIndexForMood:(HappModelMood)mood;

- (NSArray *)getMoods;

- (HappModelMoodObject *)getMoodFor:(HappModelMood)mood;

@end