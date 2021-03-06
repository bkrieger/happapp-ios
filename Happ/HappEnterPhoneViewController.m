//
//  HappEnterPhoneViewController.m
//  Happ
//
//  Created by Brandon Krieger on 9/12/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#define LOGIN_TEXT @"or login if you have an account"
#define VERIFY_TEXT @"Verify phone number"
#define SENDING_TEXT @"Sending..."

#define BOTTOM_BUTTON_POSITION CGRectMake(0, self.view.bounds.size.height - 220, self.view.bounds.size.width, 40)
#define MIDDLE_BUTTON_POSITION CGRectMake(0, self.view.bounds.size.height - 270, self.view.bounds.size.width, 40)

#import "HappEnterPhoneViewController.h"
#import "HappModelEnums.h"
#import "Twilio.h"
#import "HappAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface PhoneNumberTextField : UITextField
@end
@implementation PhoneNumberTextField

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
// Don't allow any taps to the text field.
}

@end

@interface HappEnterPhoneViewController ()

@property (nonatomic, strong) UILabel *enterPhoneNumberLabel;
@property (nonatomic, strong) UITextField *phoneNumberField;
@property (nonatomic, strong) UIView *phoneNumberLabelBackground;
@property (nonatomic, strong) UIBarButtonItem *verifyBarButton;
@property (nonatomic, strong) UIButton *verifyButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic) BOOL displayingLoginButton;
@property (nonatomic, strong) UIAlertView *loginPopup;
@property (nonatomic) BOOL usernamePasswordValid;

@end

@implementation HappEnterPhoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *titleImage = [UIImage imageNamed:@"hippo_profile_ios.png"];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleImage.size.width * 2, titleImage.size.height * 2)];
    [self.navigationItem.titleView addSubview:titleImageView];
    titleImageView.frame = CGRectMake(27, 27, titleImage.size.width, titleImage.size.height);
    
    self.verifyBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Verify" style:UIBarButtonItemStyleDone target:self action:@selector(onVerifyClick)];
    self.navigationItem.rightBarButtonItem = self.verifyBarButton;
    
    self.view.backgroundColor = HAPP_WHITE_COLOR;
    [self.view addSubview:self.phoneNumberField];
    [self.view addSubview:self.enterPhoneNumberLabel];
    [self.view addSubview:self.loginButton];
    self.displayingLoginButton = YES;
    self.verifyBarButton.enabled = NO;

    [self.phoneNumberField becomeFirstResponder];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your phone number."
                                                    message:@"We will confirm your number with a one-time SMS. We will not share your number with anyone; it simply helps your friends to share with you on Happ."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

- (void)onVerifyClick {
    NSString *twilioId = TWILIO_API_KEY;
    NSString *twilioSecret = TWILIO_API_SECRET;
    NSString *kFromNumber = @"+15165060910";
    NSString *kToNumber = [NSString stringWithFormat:@"+1%@", self.phoneNumberField.text];
    NSString *randomNumber = [NSString stringWithFormat:@"%d", abs(arc4random())];
    NSLog(@"Verification Code: %@",randomNumber);
    NSString *message = [NSString stringWithFormat:@"Thanks for using Happ! Click here to verify your phone number: http://www.happ.us/verify?code=%@", randomNumber];
    
    [[NSUserDefaults standardUserDefaults] setObject:[self formatNumber:self.phoneNumberField.text] forKey:UNVERIFIED_PHONE_NUMBER_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:randomNumber forKey:VERIFICATION_CODE_KEY];
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
    
    NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [serverConnection start];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.verifyBarButton setTitle:SENDING_TEXT];
    [self.verifyButton setTitle:SENDING_TEXT forState:UIControlStateNormal];
    self.verifyBarButton.enabled = NO;
    self.verifyButton.enabled = NO;
}

- (void)onLoginButtonClick {
    [self openLoginPopupWithInvalidPassword:NO];
}

- (void)openLoginPopupWithInvalidPassword:(BOOL)invalidPassword {
    if (invalidPassword) {
        self.loginPopup.message = @"Invalid password";
    } else {
        self.loginPopup.message = @" ";
    }
    [self.loginPopup show];
}

#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // Check that the user tried to log in
    if (alertView == self.loginPopup && buttonIndex == 1) {
        NSString *username = [alertView textFieldAtIndex:0].text;
        NSString *password = [alertView textFieldAtIndex:1].text;
        if ([username isEqualToString:@"sample"] && [password isEqualToString:@"sample"]) {
            self.usernamePasswordValid = YES;
        } else {
            self.usernamePasswordValid = NO;
        }
        NSString *urlString = [NSString stringWithFormat:@"http://www.happ.us/login"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [serverConnection start];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        self.loginButton.enabled = NO;
        [self.loginButton setTitle:SENDING_TEXT forState:UIControlStateNormal];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if (alertView == self.loginPopup) {
        NSString *username = [alertView textFieldAtIndex:0].text;
        NSString *password = [alertView textFieldAtIndex:1].text;
        return [username length] > 4 && [password length] > 4;
    }
    return YES;
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    HappAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error"
                                                    message:@"Unable to connect. Check your internet connection and try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    appDelegate.alertToDismiss = alert;
    [alert show];
    [self.verifyBarButton setTitle:@"Verify"];
    [self.verifyButton setTitle:VERIFY_TEXT forState:UIControlStateNormal];
    self.verifyBarButton.enabled = YES;
    self.verifyButton.enabled = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    if([connection.currentRequest.HTTPMethod isEqualToString:@"GET"]) {
        // This was a return from a login
        if (self.usernamePasswordValid) {
            [[NSUserDefaults standardUserDefaults] setObject:@"5555555555" forKey:PHONE_NUMBER_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:HAPP_RESET_NOTIFICATION object:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            self.loginButton.enabled = YES;
            [self.loginButton setTitle:LOGIN_TEXT forState:UIControlStateNormal];
            [self openLoginPopupWithInvalidPassword:YES];
        }
    } else {
        // This was a return from trying to verify phone number.
        HappAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verification text sent"
                                                        message:@"Please click on the verification link in your text message."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        appDelegate.alertToDismiss = alert;
        [alert show];
        [self.verifyBarButton setTitle:@"Verify"];
        [self.verifyButton setTitle:VERIFY_TEXT forState:UIControlStateNormal];
        self.verifyBarButton.enabled = NO;
        self.verifyButton.enabled = NO;
    }
}

#pragma mark getters
- (UILabel *)enterPhoneNumberLabel {
    if (!_enterPhoneNumberLabel) {
        NSInteger offset = 30;
        CGRect phoneNumberLabelRect =
            CGRectMake(offset,
                       50 + offset,
                       self.view.bounds.size.width - 2*offset,
                       80);
        _enterPhoneNumberLabel = [[UILabel alloc] initWithFrame:phoneNumberLabelRect];
        _enterPhoneNumberLabel.text = @"Please enter and verify your phone number.";
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
        NSInteger height = 40;
        CGRect phoneNumberRect = CGRectMake(offset,
                                            self.view.bounds.size.height/3,
                                            self.view.bounds.size.width - 2*offset,
                                            height);
        _phoneNumberField = [[PhoneNumberTextField alloc] initWithFrame:phoneNumberRect];
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
        _verifyButton = [[UIButton alloc] initWithFrame:MIDDLE_BUTTON_POSITION];
        _verifyButton.backgroundColor = HAPP_WHITE_COLOR;
        [_verifyButton setTitleColor:HAPP_PURPLE_COLOR forState:UIControlStateNormal];
        [_verifyButton setTitleColor:HAPP_PURPLE_ALPHA_COLOR forState:UIControlStateHighlighted];
        [_verifyButton setTitleColor:HAPP_GRAY_COLOR forState:UIControlStateDisabled];
        [_verifyButton setTitle:VERIFY_TEXT forState:UIControlStateNormal];
        _verifyButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
        _verifyButton.enabled = NO;
        [_verifyButton addTarget:self action:@selector(onVerifyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyButton;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [[UIButton alloc] initWithFrame:MIDDLE_BUTTON_POSITION];
        _loginButton.backgroundColor = HAPP_WHITE_COLOR;
        [_loginButton setTitleColor:HAPP_PURPLE_COLOR forState:UIControlStateNormal];
        [_loginButton setTitleColor:HAPP_PURPLE_ALPHA_COLOR forState:UIControlStateHighlighted];
        [_loginButton setTitleColor:HAPP_GRAY_COLOR forState:UIControlStateDisabled];
        [_loginButton setTitle:LOGIN_TEXT forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
        _loginButton.enabled = YES;
        [_loginButton addTarget:self action:@selector(onLoginButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UIAlertView *)loginPopup {
    if (!_loginPopup) {
        _loginPopup = [[UIAlertView alloc] initWithTitle:@"Enter your username and password to login" message:@" " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        _loginPopup.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    }
    return _loginPopup;
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
        self.verifyBarButton.enabled = YES;
        self.verifyButton.enabled = YES;
    } else {
        self.verifyBarButton.enabled = NO;
        self.verifyButton.enabled = NO;
    }
    
    if (newTextLength > 0 && self.displayingLoginButton) {
        [self.loginButton removeFromSuperview];
        self.displayingLoginButton = NO;
        [self addAndSlideUpButton:self.verifyButton];
    } else if (newTextLength == 0 && !self.displayingLoginButton) {
        [self.verifyButton removeFromSuperview];
        self.displayingLoginButton = YES;
        [self.view addSubview:self.loginButton];
    }
    
    return YES;
}

#pragma mark helpers

- (void)addAndSlideUpButton:(UIButton *)button {
    button.frame = BOTTOM_BUTTON_POSITION;
    [self.view addSubview:button];
    [UIView animateWithDuration:.4 animations:^{
        button.frame = MIDDLE_BUTTON_POSITION;
    }];
}

@end

