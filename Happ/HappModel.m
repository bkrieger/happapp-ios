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
    NSString *postString = [NSString stringWithFormat:@"id=%@&msg=%@&tags[]=%i&duration=%i", @"3", message, mood, 10000000];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL
        URLWithString:[NSString stringWithFormat:@"%@%@",self.postUrl, postString]]];
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"%@", [request URL]);
    NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [serverConnection start];
}

#pragma mark HappComposeVCDataSource methods

- (NSArray *)getDurations {
    return nil;
}

- (NSArray *)getMoods {
    NSMutableArray *moods = [[NSMutableArray alloc] init];
    
    for (NSInteger i = HappModelMoodChill; i < HappModelMoodDefault; i++) {
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
    }
    
    return [[HappModelMoodObject alloc] initWithTitle:title];
}

@end

#pragma mark HappModelMoodObject implementation

@interface HappModelMoodObject()
@property NSString *title;
@end

@implementation HappModelMoodObject

- (id)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _title = [title copy];
    }
    return self;
}

@end


