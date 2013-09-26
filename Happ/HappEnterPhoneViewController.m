//
//  HappEnterPhoneViewController.m
//  Happ
//
//  Created by Brandon Krieger on 9/12/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import "HappEnterPhoneViewController.h"
#import "HappModelEnums.h"
#import "Twilio.h"
#import <QuartzCore/QuartzCore.h>

@interface HappEnterPhoneViewController ()

@property (nonatomic, strong) UILabel *enterPhoneNumberLabel;
@property (nonatomic, strong) UITextField *phoneNumberField;
@property (nonatomic, strong) UIView *verifyRegion;
@property (nonatomic, strong) UIButton *verifyButton;

@end

@implementation HappEnterPhoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *titleImage = [UIImage imageNamed:@"hippo_profile_ios.png"];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
    colorView.opaque = NO;
    colorView.backgroundColor = HAPP_PURPLE_COLOR;
    [self.navigationController.navigationBar.layer insertSublayer:colorView.layer atIndex:1];
    
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleImage.size.width, titleImage.size.height)];
    [self.navigationItem.titleView addSubview:titleImageView];
    titleImageView.frame = CGRectMake(25,
                                      27,
                                      titleImage.size.width / 2,
                                      titleImage.size.height / 2);
    self.view.backgroundColor = HAPP_WHITE_COLOR;
    [self.view addSubview:self.phoneNumberField];
    [self.view addSubview:self.enterPhoneNumberLabel];
    self.phoneNumberField.inputAccessoryView = self.verifyButton;
    [self.phoneNumberField becomeFirstResponder];
}

- (void)onVerifyClick {
    NSLog(@"Button Pressed %@", @"yo");

    NSString *twilioId = TWILIO_API_KEY;
    NSString *twilioSecret = TWILIO_API_SECRET;
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
        CGRect phoneNumberLabelRect =
            CGRectMake(offset,
                       80 + offset,
                       self.view.bounds.size.width - 2*offset,
                       80);
        _enterPhoneNumberLabel = [[UILabel alloc] initWithFrame:phoneNumberLabelRect];
        _enterPhoneNumberLabel.text = @"Please enter your phone number to start using Happ.";
        _enterPhoneNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        _enterPhoneNumberLabel.textAlignment = NSTextAlignmentCenter;
        _enterPhoneNumberLabel.textColor = HAPP_PURPLE_COLOR;
        _enterPhoneNumberLabel.numberOfLines = 2;
    }
    return _enterPhoneNumberLabel;
}

- (UITextField *)phoneNumberField {
    if (!_phoneNumberField) {
        NSInteger offset = 30;
        NSInteger height = 50;
        CGRect phoneNumberRect = CGRectMake(offset,
                                            self.view.bounds.size.height/3,
                                            self.view.bounds.size.width - 2*offset,
                                            height);
        _phoneNumberField = [[UITextField alloc] initWithFrame:phoneNumberRect];
        _phoneNumberField.delegate = self;
        _phoneNumberField.textAlignment = NSTextAlignmentCenter;
        _phoneNumberField.borderStyle = UITextBorderStyleNone;
        _phoneNumberField.backgroundColor = HAPP_WHITE_COLOR;
        _phoneNumberField.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:36];
        _phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _phoneNumberField;
}

- (UIView *)verifyRegion {
    if (!_verifyRegion) {
        _verifyRegion = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 self.view.bounds.size.width,
                                                                 70)];
        _verifyRegion.backgroundColor = HAPP_PURPLE_COLOR;
    }
    return _verifyRegion;
}

- (UIButton *)verifyButton {
    if (!_verifyButton) {
        CGRect verifyButtonRect = self.verifyRegion.bounds;
        _verifyButton = [[UIButton alloc] initWithFrame:verifyButtonRect];
        _verifyButton.backgroundColor = HAPP_PURPLE_COLOR;
        [_verifyButton setTitle:@"Verify your phone number" forState:UIControlStateNormal];
        [_verifyButton setTitle:@"Verify your phone number" forState:UIControlStateDisabled];
        [_verifyButton addTarget:self action:@selector(onVerifyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyButton;
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    NSInteger newTextLength = textField.text.length - range.length + string.length;
    if (newTextLength == 10) {
        self.verifyButton.enabled = YES;
        self.verifyButton.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        self.verifyRegion.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    } else {
        self.verifyButton.enabled = NO;
        self.verifyButton.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    }

    return newTextLength <= 10;
}

@end
