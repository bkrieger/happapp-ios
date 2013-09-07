#import <Foundation/Foundation.h>
#import "HappModelEnums.h"

@protocol HappComposeVCDelegate <NSObject>

- (void)postWithMessage:(NSString *)message
                   mood:(HappModelMood)mood
               duration:(HappModelDuration)duration;

- (void)cancelCompose;

@end