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

@property NSURLConnection *serverConnection;
@property NSArray *moodPersons;
@property NSMutableData *temporaryData;
@property (nonatomic, weak) NSObject<HappModelDelegate> *delegate;

@end

@implementation HappModel

- (id)initWithUrl:(NSString *)url
         delegate:(NSObject<HappModelDelegate> *)delegate {
    self = [super init];
    if (self) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        _serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        _delegate = delegate;
     }
    return self;
}

- (void)refresh {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.serverConnection start];
}

- (NSInteger)getMoodPersonCount {
    return [self.moodPersons count];
}

- (NSDictionary *)getMoodPersonForIndex:(NSInteger)index {
    return self.moodPersons[index];
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.temporaryData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.temporaryData appendData:data];
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
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:self.temporaryData
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
    
    [self.moodPersons arrayByAddingObjectsFromArray:[results objectForKey:@"data"]];
    [self.delegate modelIsReady];
}

@end
