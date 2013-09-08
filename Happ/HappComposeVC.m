//
//  HappComposeVC.m
//  Happ
//
//  Created by Brandon Krieger on 9/7/13.
//  Copyright (c) 2013 Happ. All rights reserved.

#import <UIKit/UIKit.h>
#import "HappComposeVC.h"
#import "HappModel.h"
#import "HappModelEnums.h"

#define HAPP_HORIZONTAL_PADDING 7
#define HAPP_VERTICAL_PADDING 10

@interface HappComposeVC ()

@property (nonatomic, strong) NSObject<HappComposeVCDelegate> *happDelegate;
@property (nonatomic, strong) NSObject<HappComposeVCDataSource> *dataSource;

@property HappModelMood mood;
@property HappModelDuration duration;

@property (nonatomic, strong) UIViewController *composeVC;
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIView *accerssoryView;
@property (nonatomic, strong) UIButton *moodSelector;
@property (nonatomic, strong) UILabel *moodSelectorValue;

@property (nonatomic, strong) UIButton *durationSelector;
@property (nonatomic, strong) UIView *durationSelectorVerticalDivider;
@property (nonatomic, strong) UILabel *durationSelectorLabel;
@property (nonatomic, strong) UILabel *durationSelectorValue;

@property (nonatomic, strong) UIPickerView *moodPickerView;
@property (nonatomic, strong) UIPickerView *durationPickerView;

@property BOOL isDisplayingPickerView;

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

#pragma mark Class - methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setUpViews];
    self.isDisplayingPickerView = NO;
    self.mood = HappModelMoodDefault;
    self.duration = HappModelDurationDefault;
    
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpViews {
    self.composeVC = [[UIViewController alloc] init];
    self.composeVC.view.backgroundColor = HAPP_WHITE_COLOR;
    [self pushViewController:self.composeVC animated:NO];
    
    // Cancel set up
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Cancel"
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(cancelButtonWasPressed)];
    [[self.composeVC navigationItem] setLeftBarButtonItem:cancelButton];
    
    // Send set up
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Send"
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(sendButtonWasPressed)];
    [[self.composeVC navigationItem] setRightBarButtonItem:sendButton];
    

    [self.composeVC.view addSubview:self.textField];

    self.accerssoryView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, self.composeVC.view.bounds.size.width, 100)];
    
    UIView *dividerView= [[UIView alloc]
        initWithFrame:CGRectMake(0,
                                 self.accerssoryView.bounds.size.height / 2,
                                 self.accerssoryView.bounds.size.width,
                                 1 / [[UIScreen mainScreen] scale])];
    dividerView.backgroundColor = HAPP_DIVIDER_COLOR;

    [self.accerssoryView addSubview:self.moodSelector];
    [self.accerssoryView addSubview:dividerView];
    [self.accerssoryView addSubview:self.durationSelector];
    
    self.durationSelectorValue.text = [self.dataSource getDurationFor:HappModelDurationDefault].title;
    self.moodSelectorValue.text = [self.dataSource getMoodFor:HappModelMoodDefault].title;
    
    self.textField.inputAccessoryView = self.accerssoryView;
}

#pragma mark SomethingHappened - methods

- (void)cancelButtonWasPressed {
    [self.happDelegate cancelCompose];
}

- (void)sendButtonWasPressed {
    [self.happDelegate postWithMessage:self.textField.text
                                  mood:self.mood
                              duration:self.duration];
}

- (void)didTapOnDurationSelector {
    if (self.isDisplayingPickerView &&
        self.textField.inputView == self.durationPickerView) {
        return;
    }
    
    [self setUpPicker:self.durationPickerView];
    [self.durationPickerView selectRow:[self.dataSource getIndexForDuration:self.duration]
                           inComponent:0
                              animated:NO];
    [self resetSelectorState];
    [self setSelectorSelected:self.durationSelector];
}

- (void)didTapOnMoodSelector {
    if (self.isDisplayingPickerView &&
        self.textField.inputView == self.moodPickerView) {
        return;
    }
    
    [self setUpPicker:self.moodPickerView];
    [self.moodPickerView selectRow:[self.dataSource getIndexForMood:self.mood]
                       inComponent:0
                          animated:NO];
    [self resetSelectorState];
    [self setSelectorSelected:self.moodSelector];
}

- (void)didTapOnTextField {
    if (self.isDisplayingPickerView) {
        [self.textField endEditing:YES];
        self.textField.inputView = nil;
        
        self.isDisplayingPickerView = NO;
        [self resetSelectorState];
        [self.textField becomeFirstResponder];
    }
}

#pragma mark SelectorState - methods

- (void)resetSelectorState {
    self.durationSelector.backgroundColor = [UIColor clearColor];
    self.moodSelector.backgroundColor = [UIColor clearColor];
    self.durationSelectorLabel.textColor = HAPP_BLACK_COLOR;
    self.durationSelectorValue.textColor = HAPP_BLACK_COLOR;
    self.durationSelectorVerticalDivider.backgroundColor = HAPP_DIVIDER_COLOR;
    self.moodSelectorValue.textColor = HAPP_BLACK_COLOR;
}

- (void)setSelectorSelected:(UIButton *)selector {
    if (selector == self.durationSelector) {
        self.durationSelectorLabel.textColor = HAPP_WHITE_COLOR;
        self.durationSelectorValue.textColor = HAPP_WHITE_COLOR;
        self.durationSelectorVerticalDivider.backgroundColor = HAPP_WHITE_COLOR;
    } else {
        self.moodSelectorValue.textColor = HAPP_WHITE_COLOR;
    }
    selector.backgroundColor = HAPP_PURPLE_COLOR;
}

- (void)setUpPicker:(UIPickerView *)pickerView {
    pickerView.frame = CGRectMake(0,
        self.composeVC.view.bounds.size.height - pickerView.frame.size.height,
        self.composeVC.view.bounds.size.width,
        pickerView.frame.size.height);
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    [self.textField endEditing:YES];
    self.textField.inputView = pickerView;
    
    self.isDisplayingPickerView = YES;
    [self.textField becomeFirstResponder];
}

#pragma mark getters

// Must be called after composeVC is initialized.
- (UITextField *)textField {
    if (!_textField) {
        CGRect textFieldFrame = CGRectInset(self.composeVC.view.bounds, 10, 10);
        _textField = [[UITextField alloc] initWithFrame:textFieldFrame];
        _textField.returnKeyType = UIReturnKeySend;
        _textField.delegate = self;
        [_textField addTarget:self
                       action:@selector(didTapOnTextField)
             forControlEvents:UIControlEventTouchDown];
    }
    return _textField;
}

- (UIButton *)moodSelector {
    if (!_moodSelector) {
        CGRect moodSelectorFrame = CGRectMake(0, 0,
            self.accerssoryView.bounds.size.width,
            self.accerssoryView.bounds.size.height / 2);
        _moodSelector = [[UIButton alloc] initWithFrame:moodSelectorFrame];
//        _moodSelector.backgroundColor = [UIColor blueColor];
        [_moodSelector addTarget:self
                          action:@selector(didTapOnMoodSelector)
                forControlEvents:UIControlEventTouchUpInside];
        
        CGRect textValueFrame = CGRectMake(
           0,
           HAPP_VERTICAL_PADDING,
           moodSelectorFrame.size.width,
           moodSelectorFrame.size.height - (HAPP_VERTICAL_PADDING * 2));
        self.moodSelectorValue = [[UILabel alloc] initWithFrame:textValueFrame];
        self.moodSelectorValue.backgroundColor = [UIColor clearColor];
        self.moodSelectorValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22];
        self.moodSelectorValue.textAlignment = NSTextAlignmentCenter;
        
        [_moodSelector addSubview:self.moodSelectorValue];
    }
    return _moodSelector;
}

- (UIButton *)durationSelector {
    if (!_durationSelector) {
        CGRect durationSelectorFrame = CGRectMake(0,
           self.accerssoryView.bounds.size.height / 2,
           self.accerssoryView.bounds.size.width,
           self.accerssoryView.bounds.size.height / 2);
        _durationSelector = [[UIButton alloc] initWithFrame:durationSelectorFrame];
//        _durationSelector.backgroundColor = [UIColor redColor];
        [_durationSelector addTarget:self
                              action:@selector(didTapOnDurationSelector)
                    forControlEvents:UIControlEventTouchUpInside];
        
        CGRect verticalDividerFrame = CGRectMake(
           self.accerssoryView.bounds.size.width / 3,
           0,
            1 / [[UIScreen mainScreen] scale],
           _durationSelector.frame.size.height);
        self.durationSelectorVerticalDivider = [[UIView alloc] initWithFrame:verticalDividerFrame];
        self.durationSelectorVerticalDivider.backgroundColor = HAPP_DIVIDER_COLOR;
        
        CGRect textLabelFrame = CGRectMake(
           HAPP_HORIZONTAL_PADDING,
           HAPP_VERTICAL_PADDING,
           verticalDividerFrame.origin.x - (HAPP_HORIZONTAL_PADDING * 2),
           verticalDividerFrame.size.height - (HAPP_VERTICAL_PADDING * 2));
        self.durationSelectorLabel = [[UILabel alloc] initWithFrame:textLabelFrame];
        self.durationSelectorLabel.backgroundColor = [UIColor clearColor];
        self.durationSelectorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        self.durationSelectorLabel.text = @"in the next";
        self.durationSelectorLabel.textAlignment = NSTextAlignmentRight;
        
        CGRect textValueFrame = CGRectMake(
           verticalDividerFrame.origin.x + HAPP_HORIZONTAL_PADDING * 1.5,
           HAPP_VERTICAL_PADDING,
           (verticalDividerFrame.origin.x * 2) - (HAPP_HORIZONTAL_PADDING * 2),
           verticalDividerFrame.size.height - (HAPP_VERTICAL_PADDING * 2));
        self.durationSelectorValue = [[UILabel alloc] initWithFrame:textValueFrame];
        self.durationSelectorValue.backgroundColor = [UIColor clearColor];
        self.durationSelectorValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22];

        [_durationSelector addSubview:self.durationSelectorLabel];
        [_durationSelector addSubview:self.durationSelectorVerticalDivider];
        [_durationSelector addSubview:self.durationSelectorValue];
    }
    return _durationSelector;
}

- (UIPickerView *)durationPickerView {
    if (!_durationPickerView) {
        _durationPickerView = [[UIPickerView alloc] init];
    }
    return _durationPickerView;
}

- (UIPickerView *)moodPickerView {
    if (!_moodPickerView) {
        _moodPickerView = [[UIPickerView alloc] init];
    }
    return _moodPickerView;
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.happDelegate postWithMessage:textField.text mood:self.mood duration:self.duration];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 40) ? NO : YES;
}

#pragma mark UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    NSString *title = @"Chillin at yo Place";
    if (pickerView == self.durationPickerView) {
        HappModelDurationObject *durationObject = [[self.dataSource getDurations] objectAtIndex:row];
        title = durationObject.title;
    } else if (pickerView == self.moodPickerView) {
        HappModelMoodObject *moodObject = [[self.dataSource getMoods] objectAtIndex:row];
        title = [moodObject title];
    }
    return title;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    UIView *cellView = [[UIView alloc] init];
    cellView.frame = CGRectMake(0, 0, 80, 32);

    UILabel *cellTitle = [[UILabel alloc] init];
    cellTitle.backgroundColor = [UIColor clearColor];
    cellTitle.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
    
    [cellView addSubview:cellTitle];
    
    if (pickerView == self.durationPickerView) {
        cellTitle.frame = CGRectMake(
            0,
            (cellView.frame.size.height / 2) - 10,
            120,
            cellView.frame.size.height - 10);
        HappModelDurationObject *durationObject =
            [[self.dataSource getDurations] objectAtIndex:row];
        cellTitle.text = durationObject.title;
    } else if (pickerView == self.moodPickerView) {
        cellView.bounds = cellView.frame;
        cellTitle.frame = CGRectMake(
            0,
            0,
            cellView.frame.size.width,
            cellView.frame.size.height);
        HappModelMoodObject *mood = [[self.dataSource getMoods] objectAtIndex:row];
        cellTitle.text = [mood title];
        cellTitle.textAlignment = NSTextAlignmentCenter;
    }
    return cellView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.durationPickerView) {
        HappModelDurationObject *durationObject =
            [[self.dataSource getDurations] objectAtIndex:row];
        self.duration = durationObject.duration;
        self.durationSelectorValue.text = durationObject.title;
    } else if (pickerView == self.moodPickerView) {
        HappModelMoodObject *moodObject = [[self.dataSource getMoods] objectAtIndex:row];
        self.mood = moodObject.mood;
        self.moodSelectorValue.text = moodObject.title;
    }
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numRows= 0;
    if (pickerView == self.durationPickerView) {
        numRows = [[self.dataSource getDurations] count];
    } else if (pickerView == self.moodPickerView) {
        numRows = [[self.dataSource getMoods] count];
    }
    return numRows;
}


@end
