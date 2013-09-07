//
//  HappComposeVC.m
//  Happ
//
//  Created by Brandon Krieger on 9/7/13.
//  Copyright (c) 2013 Happ. All rights reserved.


#import "HappComposeVC.h"
#import "HappModelEnums.h"

@interface HappComposeVC ()

@property (nonatomic, strong) NSObject<HappComposeVCDelegate> *happDelegate;
@property (nonatomic, strong) NSObject<HappComposeVCDataSource> *dataSource;

@property HappModelMood mood;
@property HappModelDuration duration;

@property (nonatomic, strong) UIViewController *composeVC;
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIView *accerssoryView;
@property (nonatomic, strong) UIView *moodSelector;
@property (nonatomic, strong) UIView *durationSelector;

@end

@implementation HappComposeVC

- (id)initWithDelegate:(NSObject<HappComposeVCDelegate> *)delegate
            dataSource:(NSObject<HappComposeVCDataSource> *)dataSource {
    self = [super init];
    if (self) {
        _happDelegate = delegate;
        _dataSource = dataSource;
    }
    return self;
}

- (void)dispose {
    self.happDelegate = nil;
    self.dataSource = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setUpViews];
    
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpViews {
    self.composeVC = [[UIViewController alloc] init];
    self.composeVC.view.backgroundColor =
        [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f];
    [self pushViewController:self.composeVC animated:NO];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Cancel"
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(cancelButtonWasPressed)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    [self.composeVC.view addSubview:self.textField];

    self.accerssoryView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, self.composeVC.view.bounds.size.width, 100)];
    [self.accerssoryView addSubview:self.moodSelector];
    [self.accerssoryView addSubview:self.durationSelector];
    
    self.textField.inputAccessoryView = self.accerssoryView;
}

- (void)cancelButtonWasPressed {
    
}

#pragma mark getters

// Must be called after composeVC is initialized.
- (UITextField *)textField {
    if (!_textField) {
        CGRect textFieldFrame = CGRectInset(self.composeVC.view.bounds, 10, 10);
        _textField = [[UITextField alloc] initWithFrame:textFieldFrame];
        _textField.returnKeyType = UIReturnKeySend;
        _textField.delegate = self;
    }
    return _textField;
}

- (UIView *)moodSelector {
    if (!_moodSelector) {
        CGRect moodSelectorFrame = CGRectMake(0, 0,
            self.accerssoryView.bounds.size.width,
            self.accerssoryView.bounds.size.height / 2);
        _moodSelector = [[UIView alloc] initWithFrame:moodSelectorFrame];
        _moodSelector.backgroundColor = [UIColor blueColor];
    }
    return _moodSelector;
}

- (UIView *)durationSelector {
    if (!_durationSelector) {
        CGRect durationSelectorFrame = CGRectMake(0,
           self.accerssoryView.bounds.size.height / 2,
           self.accerssoryView.bounds.size.width,
           self.accerssoryView.bounds.size.height / 2);
        _durationSelector = [[UIView alloc] initWithFrame:durationSelectorFrame];
        _durationSelector.backgroundColor = [UIColor redColor];
    }
    return _durationSelector;
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.happDelegate postWithMessage:textField.text mood:self.mood duration:self.duration];
    return YES;
}


@end
