#import "HappModelEnums.h"

@class HappModelMoodObject;

@protocol HappComposeVCDataSource <NSObject>

- (NSArray *)getDurations;

- (NSArray *)getMoods;

- (HappModelMoodObject *)getMoodFor:(HappModelMood)mood;

@end