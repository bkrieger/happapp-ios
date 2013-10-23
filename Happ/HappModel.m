//
//  HappModel.m
//  Happ
// 
//  Created by Brandon Krieger on 9/6/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappModel.h"
#import "HappModelDelegate.h"
#import "Twilio.h"

#define HAPP_URL_PREFIX @"http://54.221.209.211:3000/api/v1/moods?"
#define HAPP_URL_UPDATE_FRIENDS @"http://54.221.209.211:3000/api/v1/friends?"
#define HAPP_URL_FEEDBACK @"http://54.221.209.211:3000/api/v1/feedback?"
#define HAPP_URL_SEPARATOR @"&n[]="

@interface HappModel()

@property (nonatomic, strong) HappABModel *happABModel;

@property (nonatomic, strong) NSString *myPhoneNumber;
@property (nonatomic, strong) NSString *contactsUrl;

@property (nonatomic, strong) NSMutableArray *moodPersons;
@property (nonatomic, strong) NSDictionary *meMoodPerson;
@property NSMutableData *temporaryData;
@property (nonatomic, weak) NSObject<HappModelDelegate> *delegate;

@end

@implementation HappModel

- (id)initWithHappABModel:(HappABModel *)happABModel
                  delegate:(NSObject<HappModelDelegate> *)delegate {
    self = [super init];
    if (self) {
        _happABModel = happABModel;
        _myPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:PHONE_NUMBER_KEY];
        _contactsUrl = [happABModel getUrlFromContactsWithSeparator:HAPP_URL_SEPARATOR];
        _moodPersons = [[NSMutableArray alloc] init];
        _delegate = delegate;
    }
    return self;
}

- (NSString *)createGetUrl {
    return [NSString stringWithFormat:@"%@%@&me=%@%@",
            HAPP_URL_PREFIX, AUTHENTICATION_KEY, self.myPhoneNumber, self.contactsUrl];
}

- (NSString *)createPostUrlWithMessage:(NSString *)message
                                  mood:(HappModelMood)mood
                              duration:(HappModelDuration)duration {
    return [NSString stringWithFormat:@"%@%@%@&id=%@&msg=%@&tag=%@&duration=%@",
            HAPP_URL_PREFIX,
            AUTHENTICATION_KEY,
            self.contactsUrl,
            self.myPhoneNumber,
            [message stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
            [self getMoodPostDataFor:mood],
            [self getDurationPostDataFor:duration]];
}

- (NSString *)createUpdateFriendsUrl {
    return [NSString stringWithFormat:@"%@%@&me=%@%@",
            HAPP_URL_UPDATE_FRIENDS, AUTHENTICATION_KEY, self.myPhoneNumber, self.contactsUrl];
}

- (void)refresh {
    [self.moodPersons removeAllObjects];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self createGetUrl]]];
    NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [serverConnection start];
}

- (NSInteger)getMoodPersonCount {
    return [self.moodPersons count];
}

- (NSDictionary *)getMoodPersonForIndex:(NSInteger)index {
    if (index >= [self.moodPersons count]) {
        return nil;
    }
    
    NSDictionary *moodPerson = [self.moodPersons objectAtIndex:index];
    if ([[NSString stringWithFormat:@"%@", [moodPerson objectForKey:@"_id"]] isEqualToString:self.myPhoneNumber]) {
        [self.moodPersons removeObject:moodPerson];
        moodPerson = nil;
    }
    return moodPerson;
}

- (NSDictionary *)getMoodPersonForMe {
    return self.meMoodPerson;
}

- (void)updateFriends {
    self.contactsUrl = [self.happABModel getUrlFromContactsWithSeparator:HAPP_URL_SEPARATOR];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self createUpdateFriendsUrl]]];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [serverConnection start];
}

- (void)sendFeedback:(NSString *)message {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *feedbackUrl = [NSString stringWithFormat:@"%@me=%@&message=%@", HAPP_URL_FEEDBACK, self.myPhoneNumber, [message stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedbackUrl]];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [serverConnection start];
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([connection.currentRequest.HTTPMethod isEqualToString:@"POST"]) {
        // We don't receive data from POST mood or update friends.
    } else {
        self.temporaryData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([connection.currentRequest.HTTPMethod isEqualToString:@"POST"]) {
        // We don't receive data from POST mood or update friends.
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
    [self.delegate modelIsReady];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([connection.currentRequest.HTTPMethod isEqualToString:@"POST"]) {
        if ([connection.currentRequest.URL.absoluteString hasPrefix:HAPP_URL_PREFIX]) {
            [self.delegate modelDidPost];
        } else if ([connection.currentRequest.URL.absoluteString hasPrefix:HAPP_URL_UPDATE_FRIENDS]) {
            [self refresh];
        }
    } else {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:self.temporaryData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
        
        [self.moodPersons addObjectsFromArray:[[results objectForKey:@"data"] objectForKey:@"contacts"]];
        self.meMoodPerson = [[results objectForKey:@"data"] objectForKey:@"me"];
        [self.delegate modelIsReady];
    }
}

#pragma mark HappComposeVCDelegate methods

- (void)postWithMessage:(NSString *)message
                   mood:(HappModelMood)mood
               duration:(HappModelDuration)duration {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL
        URLWithString:[self createPostUrlWithMessage:message
                                                mood:mood
                                            duration:duration]]];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [serverConnection start];
    
    // Increment stored count of number of posts.
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:HAPPS_POSTED_COUNT_KEY];
    [[NSUserDefaults standardUserDefaults] setInteger:count+1 forKey:HAPPS_POSTED_COUNT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark HappComposeVCDataSource methods

- (NSArray *)getDurations {
    NSMutableArray *durations = [[NSMutableArray alloc] init];
    
    for (NSInteger i = HappModelDurationHalfHour; i < HappModelDurationInvalid; i++) {
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
            
        case HappModelDurationFiveHour:
            title = @"five hours";
            break;
            
        case HappModelDurationSixHour:
            title = @"six hours";
            break;
            
        case HappModelDurationInvalid:
            title = @"unsure";
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
    
    for (NSInteger i = HappModelMoodChill; i < HappModelMoodInvalid; i++) {
        [moods addObject:[self getMoodFor:i]];
    }
    
    return moods;
}

- (HappModelMoodObject *)getMoodFor:(HappModelMood)mood {
    NSString *title;
    UIImage *image;
    UIImage *imageInverse;
    
    switch (mood) {
        case HappModelMoodChill:
            title = @"Chill";
            image = [UIImage imageNamed:@"chill_ios.png"];
            imageInverse = [UIImage imageNamed:@"chill_ios_i.png"];
            break;
            
        case HappModelMoodFood:
            title = @"Food";
            image = [UIImage imageNamed:@"food_ios.png"];
            imageInverse = [UIImage imageNamed:@"food_ios_i.png"];
            break;
            
        case HappModelMoodMovie:
            title = @"Movie";
            image = [UIImage imageNamed:@"movie_ios.png"];
            imageInverse = [UIImage imageNamed:@"movie_ios_i.png"];
            break;
            
        case HappModelMoodParty:
            title = @"Party";
            image = [UIImage imageNamed:@"party_ios.png"];
            imageInverse = [UIImage imageNamed:@"party_ios_i.png"];
            break;
            
        case HappModelMoodSports:
            title = @"Sports";
            image = [UIImage imageNamed:@"sport_ios.png"];
            imageInverse = [UIImage imageNamed:@"sport_ios_i.png"];
            break;
            
        case HappModelMoodInvalid:
            title = @"Chillin'";
            image = [UIImage imageNamed:@"chill_ios.png"];
            imageInverse = [UIImage imageNamed:@"chill_ios_i.png"];
            break;
    }
    
    return [[HappModelMoodObject alloc] initWithTitle:title
                                                 mood:mood
                                                image:image
                                         imageInverse:imageInverse];
}

- (NSInteger)getIndexForMood:(HappModelMood)mood {
    NSInteger index = 0;
    for (NSInteger i = HappModelMoodChill; i < HappModelMoodInvalid; i++) {
        if (i == mood) {
            index = i - 1;
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
            title = @"3";
            break;
            
        case HappModelMoodParty:
            title = @"4";
            break;
            
        case HappModelMoodSports:
            title = @"5";
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
            
        case HappModelDurationFiveHour:
            title = @"18000";
            break;
            
        case HappModelDurationSixHour:
            title = @"21600";
            break;
            
        case HappModelDurationInvalid:
            title = @"unsure";
            break;
    }
    return title;
}

@end

#pragma mark HappModelObjects implementation

@implementation HappModelMoodObject

- (id)initWithTitle:(NSString *)title
               mood:(HappModelMood)mood
              image:(UIImage *)image
       imageInverse:(UIImage *)imageInverse {
    self = [super init];
    if (self) {
        _title = [title copy];
        _mood = mood;
        _image = image;
        _imageInverse = imageInverse;
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

