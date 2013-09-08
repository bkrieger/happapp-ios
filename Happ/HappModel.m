//
//  HappModel.m
//  Happ
//
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappModel.h"
#import "HappModelDelegate.h"

@interface HappModel()

@property NSString *getUrl;
@property NSString *postUrl;
@property (nonatomic, strong) NSMutableArray *moodPersons;
@property NSMutableData *temporaryData;
@property (nonatomic, weak) NSObject<HappModelDelegate> *delegate;

@end

@implementation HappModel

- (id)initWithGetUrl:(NSString *)getUrl
             postUrl:(NSString *)postUrl
            delegate:(NSObject<HappModelDelegate> *)delegate {
    self = [super init];
    if (self) {
        _getUrl = getUrl;
        _postUrl = postUrl;
        _moodPersons = [[NSMutableArray alloc] init];
        _delegate = delegate;
     }
    return self;
}

- (void)refresh {
    [self.moodPersons removeAllObjects];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.getUrl]];
    NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [serverConnection start];
}

- (NSInteger)getMoodPersonCount {
    return [self.moodPersons count];
}

- (NSDictionary *)getMoodPersonForIndex:(NSInteger)index {
    return (index < [self.moodPersons count]) ? [self.moodPersons objectAtIndex:index] : nil;
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([connection.currentRequest.HTTPMethod isEqualToString:@"POST"]) {
        NSLog(@"OH NO! %@", response);
    } else {
        self.temporaryData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([connection.currentRequest.HTTPMethod isEqualToString:@"POST"]) {
    } else {
        [self.temporaryData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                    message:@"Unable to connect with server."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([connection.currentRequest.HTTPMethod isEqualToString:@"POST"]) {
        [self.delegate modelDidPost];
    } else {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:self.temporaryData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
        
        [self.moodPersons addObjectsFromArray:[results objectForKey:@"data"]];
        
        [self.delegate modelIsReady];
    }
}

#pragma mark HappComposeVCDelegate methods

- (void)postWithMessage:(NSString *)message
                   mood:(HappModelMood)mood
               duration:(HappModelDuration)duration {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
    
    NSString *postString = [NSString
        stringWithFormat:@"id=%@&msg=%@&tag=%@&duration=%@",
                         @"3",
                         [message stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                         [self getMoodPostDataFor:mood],
                         [self getDurationPostDataFor:duration]];
    NSLog(@"%@", postString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL
        URLWithString:[NSString stringWithFormat:@"%@%@",self.postUrl, postString]]];
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"%@", [request URL]);
    NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [serverConnection start];
}

#pragma mark HappComposeVCDataSource methods

- (NSArray *)getDurations {
    NSMutableArray *durations = [[NSMutableArray alloc] init];
    
    for (NSInteger i = HappModelDurationHalfHour; i <= HappModelDurationFourHour; i++) {
        [durations addObject:[self getDurationFor:i]];
    }
    
    return durations;
}

- (HappModelDurationObject *)getDurationFor:(HappModelDuration)duration {
    NSString *title;
    
    switch (duration) {
        case HappModelDurationHalfHour:
            title = @"half hour";
            break;
            
        case HappModelDurationOneHour:
            title = @"one hour";
            break;
            
        case HappModelDurationTwoHour:
            title = @"two hours";
            break;
            
        case HappModelDurationThreeHour:
            title = @"three hours";
            break;
            
        case HappModelDurationFourHour:
            title = @"four hours";
            break;
            
        case HappModelDurationInvalid:
            title = @"chillin";
            break;
    }
    return [[HappModelDurationObject alloc] initWithTitle:title duration:duration];
}

- (NSInteger)getIndexForDuration:(HappModelDuration)duration {
    NSInteger index = 0;
    for (NSInteger i = HappModelDurationHalfHour; i < HappModelDurationInvalid; i++) {
        if (i == duration) {
            index = i;
            break;
        }
    }
    return index;
}

- (NSArray *)getMoods {
    NSMutableArray *moods = [[NSMutableArray alloc] init];
    
    for (NSInteger i = HappModelMoodChill; i <= HappModelMoodInvalid; i++) {
        [moods addObject:[self getMoodFor:i]];
    }
    
    return moods;
}

- (HappModelMoodObject *)getMoodFor:(HappModelMood)mood {
    NSString *title;
    
    switch (mood) {
        case HappModelMoodChill:
            title = @"Chill";
            break;
            
        case HappModelMoodFood:
            title = @"Food";
            break;
            
        case HappModelMoodMovie:
            title = @"Movie";
            break;
            
        case HappModelMoodParty:
            title = @"Party";
            break;
            
        case HappModelMoodSports:
            title = @"Sports";
            break;
            
        case HappModelMoodInvalid:
            title = @"chillin";
            break;
    }
    
    return [[HappModelMoodObject alloc] initWithTitle:title mood:mood];
}

- (NSInteger)getIndexForMood:(HappModelMood)mood {
    NSInteger index = 0;
    for (NSInteger i = HappModelMoodChill; i <= HappModelMoodInvalid; i++) {
        if (i == mood) {
            index = i;
            break;
        }
    }
    return index;
}

#pragma mark Enum Getters

- (NSString *)getMoodPostDataFor:(HappModelMood)mood {
    NSString *title;
    
    switch (mood) {
        case HappModelMoodChill:
            title = @"1";
            break;
            
        case HappModelMoodFood:
            title = @"2";
            break;
            
        case HappModelMoodMovie:
            title = @"4";
            break;
            
        case HappModelMoodParty:
            title = @"8";
            break;
            
        case HappModelMoodSports:
            title = @"16";
            break;
        
        case HappModelMoodInvalid:
            title = @"chillin";
            break;
        
    }
    
    return title;
}

- (NSString *)getDurationPostDataFor:(HappModelDuration)duration {
    NSString *title;
    
    switch (duration) {
        case HappModelDurationHalfHour:
            title = @"1800";
            break;
            
        case HappModelDurationOneHour:
            title = @"3600";
            break;
            
        case HappModelDurationTwoHour:
            title = @"7200";
            break;
            
        case HappModelDurationThreeHour:
            title = @"10800";
            break;
            
        case HappModelDurationFourHour:
            title = @"14400";
            break;
            
        case HappModelDurationInvalid:
            title = @"chillin";
            break;
    }
    return title;
}

@end

#pragma mark HappModelObjects implementation

@implementation HappModelMoodObject

- (id)initWithTitle:(NSString *)title
               mood:(HappModelMood)mood {
    self = [super init];
    if (self) {
        _title = [title copy];
        _mood = mood;
    }
    return self;
}

@end

@implementation HappModelDurationObject

- (id)initWithTitle:(NSString *)title
           duration:(HappModelDuration)duration {
    self = [super init];
    if (self) {
        _title = [title copy];
        _duration = duration;
    }
    return self;
}

@end

