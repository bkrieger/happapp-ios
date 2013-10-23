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
#import "HappAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface HappEnterPhoneViewController ()

@property (nonatomic, strong) UILabel *enterPhoneNumberLabel;
@property (nonatomic, strong) UITextField *phoneNumberField;
@property (nonatomic, strong) UIView *phoneNumberLabelBackground;
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
    self.verifyButton.enabled = NO;
    [self.phoneNumberField becomeFirstResponder];
}

- (void)onVerifyClick {
    NSString *twilioId = TWILIO_API_KEY;
    NSString *twilioSecret = TWILIO_API_SECRET;
    NSString *kFromNumber = @"+15165060910";
    NSString *kToNumber = [NSString stringWithFormat:@"+1%@", self.phoneNumberField.text];
    NSString *randomNumber = [NSString stringWithFormat:@"%d", abs(arc4random())];
    NSLog(@"Verification Code: %@",randomNumber);
    NSString *message = [NSString stringWithFormat:@"Thanks for using Happ! Click here to verify your phone number: happ://%@", randomNumber];
    
    [[NSUserDefaults standardUserDefaults] setObject:[self formatNumber:self.phoneNumberField.text] forKey:@"unverifiedPhoneNumber"];
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
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Handle the received data
    if (error) {
        NSLog(@"Error on Twilio POST: %@", error);
    }
    
    HappAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verification text sent"
                                                   message:@"Please click on the verification link in your text message."
                                                  delegate:nil
                                         cancelButtonTitle:nil
                                         otherButtonTitles:nil];
    appDelegate.alertToDismiss = alert;
    [alert show];
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
        _enterPhoneNumberLabel.textColor = HAPP_BLACK_COLOR;
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
        _phoneNumberField.textColor = HAPP_BLACK_COLOR;
        _phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _phoneNumberField;
}

- (UIView *)phoneNumberLabelBackground {
    if (!_phoneNumberLabelBackground) {
        _phoneNumberLabelBackground = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 self.view.bounds.size.width,
                                                                 200)];
        _phoneNumberLabelBackground.backgroundColor = HAPP_PURPLE_COLOR;
    }
    return _phoneNumberLabelBackground;
}

- (UIButton *)verifyButton {
    if (!_verifyButton) {
        CGRect verifyButtonRect = CGRectMake(0,
                                             0,
                                             self.view.bounds.size.width,
                                             70);
        _verifyButton = [[UIButton alloc] initWithFrame:verifyButtonRect];
        _verifyButton.backgroundColor = HAPP_WHITE_COLOR;
        [_verifyButton setTitleColor:HAPP_PURPLE_COLOR forState:UIControlStateNormal];
        [_verifyButton setTitleColor:HAPP_PURPLE_ALPHA_COLOR forState:UIControlStateHighlighted];
        [_verifyButton setTitleColor:HAPP_GRAY_COLOR forState:UIControlStateDisabled];
        [_verifyButton setTitle:@"Verify your phone number" forState:UIControlStateNormal];
        _verifyButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        [_verifyButton addTarget:self action:@selector(onVerifyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyButton;
}

#pragma mark UITextFieldDelegate methods

-(int)getLength:(NSString*)mobileNumber {
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    
    return length;
}

-(NSString*)formatNumber:(NSString*)mobileNumber {
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    int length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    int length = [self getLength:textField.text];

    if(length == 10) {
        if(range.length == 0) {
            return NO;
        }
    }
    
    if(length == 3) {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) ",num];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
    } else if(length == 6) {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) %@-",[num substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0) {
            textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
    }

    NSInteger newTextLength = length - range.length + string.length;
    if (newTextLength == 10) {
        self.verifyButton.enabled = YES;
    } else {
        self.verifyButton.enabled = NO;
    }
    
    return YES;
}

@end
