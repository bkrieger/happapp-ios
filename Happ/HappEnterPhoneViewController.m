//
//  HappEnterPhoneViewController.m
//  Happ
//
//  Created by Brandon Krieger on 9/12/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappEnterPhoneViewController.h"
#import "HappModelEnums.h"
#import <QuartzCore/QuartzCore.h>

@interface HappEnterPhoneViewController ()

@property (nonatomic, strong) UILabel *enterPhoneNumberLabel;
@property (nonatomic, strong) UITextField *phoneNumberField;
@property (nonatomic, strong) UIButton *verifyButton;

@end

@implementation HappEnterPhoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *titleImage = [UIImage imageNamed:@"hippo_profile_ios.png"];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleImage.size.width, titleImage.size.height)];
    [self.navigationItem.titleView addSubview:titleImageView];
    titleImageView.frame = CGRectMake(25,
                                      27,
                                      titleImage.size.width / 2,
                                      titleImage.size.height / 2);
    [self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"witewall_3_@2x.png"]]];
    [self.view addSubview:self.phoneNumberField];
    [self.view addSubview:self.enterPhoneNumberLabel];
    [self.view addSubview:self.verifyButton];
    [self.phoneNumberField becomeFirstResponder];
}

- (void)onVerifyClick {
    NSString *twilioId = @"...";
    NSString *twilioSecret = @"...";
    NSString *kFromNumber = @"+15165060910";
    NSString *kToNumber = [NSString stringWithFormat:@"+1%@", self.phoneNumberField.text];
    NSString *randomNumber = [NSString stringWithFormat:@"%d", arc4random()];
    NSLog(@"HERE: %@",randomNumber);
    NSString *message = [NSString stringWithFormat:@"Thanks for using Happ! Click here to verify your phone number: happ://%@", randomNumber];
    [[NSUserDefaults standardUserDefaults] setObject:self.phoneNumberField.text forKey:@"unverifiedPhoneNumber"];
    [[NSUserDefaults standardUserDefaults] setObject:randomNumber forKey:@"verificationCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Build request
    NSString *urlString = [NSString stringWithFormat:@"https://%@:%@@api.twilio.com/2010-04-01/Accounts/%@/SMS/Messages", twilioId, twilioSecret, twilioId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    
    // Set up the body
    NSString *bodyString = [NSString stringWithFormat:@"From=%@&To=%@&Body=%@", kFromNumber, kToNumber, message];
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSError *error;
    NSURLResponse *response;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Handle the received data
    if (error) {
        NSLog(@"Error: %@", error);
    } else {
        NSString *receivedString = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"Request sent. %@", receivedString);
    }
}

#pragma mark getters
- (UILabel *)enterPhoneNumberLabel {
    if (!_enterPhoneNumberLabel) {
        NSInteger offset = 30;
        CGRect phoneNumberLabelRect = CGRectMake(offset, 15, self.view.bounds.size.width - 2*offset, 50);
        _enterPhoneNumberLabel = [[UILabel alloc] initWithFrame:phoneNumberLabelRect];
        _enterPhoneNumberLabel.text = @"Please enter your phone number to start using Happ.";
        _enterPhoneNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        _enterPhoneNumberLabel.textColor = HAPP_PURPLE_COLOR;
        _enterPhoneNumberLabel.numberOfLines = 2;
    }
    return _enterPhoneNumberLabel;
}

- (UITextField *)phoneNumberField {
    if (!_phoneNumberField) {
        NSInteger offset = 50;
        CGRect phoneNumberRect = CGRectMake(offset, 70, self.view.bounds.size.width - 2*offset, 50);
        _phoneNumberField = [[UITextField alloc] initWithFrame:phoneNumberRect];
        _phoneNumberField.delegate = self;
        _phoneNumberField.borderStyle = UITextBorderStyleRoundedRect;
        _phoneNumberField.backgroundColor = HAPP_WHITE_COLOR;
        _phoneNumberField.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:36];
        _phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _phoneNumberField;
}

-(UIButton *)verifyButton {
    if (!_verifyButton) {
        NSInteger offset = 50;
        CGRect verifyButtonRect = CGRectMake(offset, 140, self.view.bounds.size.width - 2*offset, 50);
        _verifyButton = [[UIButton alloc] initWithFrame:verifyButtonRect];
        _verifyButton.backgroundColor = HAPP_PURPLE_COLOR;
        _verifyButton.layer.cornerRadius = 8.0f;
        [_verifyButton setTitle:@"Verify your phone number" forState:UIControlStateNormal];
        [_verifyButton addTarget:self action:@selector(onVerifyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyButton;
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return textField.text.length < 10;
}

@end
