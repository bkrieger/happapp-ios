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

@property (nonatomic, strong) UIBarButtonItem *sendButton;

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderTextLabel;
@property (nonatomic, strong) UILabel *characterCountLabel;
@property (nonatomic, strong) UIButton *catcher;

@property (nonatomic, strong) UIView *accerssoryView;
@property (nonatomic, strong) UIButton *moodSelector;
@property (nonatomic, strong) UILabel *moodSelectorValue;
@property (nonatomic, strong) UIImageView *moodSelectorImageView;

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
    
    [self setUpViews];
    self.isDisplayingPickerView = NO;
    self.catcher.hidden = YES;
    self.mood = HappModelMoodDefault;
    self.duration = HappModelDurationDefault;
    self.view.backgroundColor = HAPP_WHITE_COLOR;
    self.navigationBar.barTintColor = HAPP_BARTINT_COLOR;
}

- (void)viewDidAppear:(BOOL)animated {
    // We do this here not in viewDidLoad to prevent lag.
    [self.textView becomeFirstResponder];
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
    cancelButton.tintColor = HAPP_WHITE_COLOR;
    
    // Send set up
    self.sendButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Send"
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(sendButtonWasPressed)];
    [self.sendButton setEnabled:NO];
    [[self.composeVC navigationItem] setRightBarButtonItem:self.sendButton];
    
    self.catcher = [[UIButton alloc] initWithFrame:self.composeVC.view.bounds];
    [self.catcher addTarget:self action:@selector(didTapOnTextField) forControlEvents:UIControlEventTouchDown];
    [self.composeVC.view addSubview:self.textView];
    [self.composeVC.view addSubview:self.placeholderTextLabel];
    [self.composeVC.view addSubview:self.characterCountLabel];

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
    self.moodSelectorImageView.image = [self.dataSource getMoodFor:HappModelMoodDefault].image;
    
    
    self.textView.inputAccessoryView = self.accerssoryView;
    [self.composeVC.view addSubview:self.catcher];
}

#pragma mark SomethingHappened - methods

- (void)cancelButtonWasPressed {
    [self.happDelegate cancelCompose];
}

- (void)sendButtonWasPressed {
    if (self.textView.text.length > 0) {
        [self.happDelegate postWithMessage:self.textView.text
                                      mood:self.mood
                                  duration:self.duration];
    }
}

- (void)didTapOnDurationSelector {
    if (self.isDisplayingPickerView &&
        self.textView.inputView == self.durationPickerView) {
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
        self.textView.inputView == self.moodPickerView) {
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
        [self.textView endEditing:YES];
        self.textView.inputView = nil;
        
        self.isDisplayingPickerView = NO;
        self.catcher.hidden = YES;
        [self resetSelectorState];
        [self.textView becomeFirstResponder];
    }
}

#pragma mark SelectorState - methods

- (void)resetSelectorState {
    self.durationSelector.backgroundColor = HAPP_WHITE_COLOR;
    self.moodSelector.backgroundColor = HAPP_WHITE_COLOR;
    self.durationSelectorLabel.textColor = HAPP_BLACK_COLOR;
    self.durationSelectorValue.textColor = HAPP_BLACK_COLOR;
    self.durationSelectorVerticalDivider.backgroundColor = HAPP_DIVIDER_COLOR;
    self.moodSelectorValue.textColor = HAPP_BLACK_COLOR;
    self.moodSelectorImageView.image = [self.dataSource getMoodFor:self.mood].image;
}

- (void)setSelectorSelected:(UIButton *)selector {
    if (selector == self.durationSelector) {
        self.durationSelectorLabel.textColor = HAPP_WHITE_COLOR;
        self.durationSelectorValue.textColor = HAPP_WHITE_COLOR;
        self.durationSelectorVerticalDivider.backgroundColor = HAPP_WHITE_COLOR;
    } else {
        self.moodSelectorValue.textColor = HAPP_WHITE_COLOR;
        self.moodSelectorImageView.image = [self.dataSource getMoodFor:self.mood].imageInverse;
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
    pickerView.backgroundColor = HAPP_WHITE_COLOR;
    [self.textView endEditing:YES];
    self.textView.inputView = pickerView;
    
    self.isDisplayingPickerView = YES;
    self.catcher.hidden = NO;
    [self.textView becomeFirstResponder];
}

- (void)setCharacterCount:(NSInteger) count {
    self.characterCountLabel.text = [NSString stringWithFormat:@"%d/50", count];
}

#pragma mark getters

// Must be called after composeVC is initialized.
- (UITextView *)textView {
    if (!_textView) {
        CGRect textFieldFrame = CGRectInset(self.composeVC.view.bounds, 10, 10);
        _textView = [[UITextView alloc] initWithFrame:textFieldFrame];
        _textView.returnKeyType = UIReturnKeySend;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:([[UIScreen mainScreen] bounds].size.height > 500 ? 22 : 18)];
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.delegate = self;
    }
    return _textView;
}

- (UILabel *)placeholderTextLabel {
    if (!_placeholderTextLabel) {
        _placeholderTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 43, 300, 100)];
        _placeholderTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:([[UIScreen mainScreen] bounds].size.height > 500 ? 22 : 18)];
        _placeholderTextLabel.textColor = HAPP_GRAY_COLOR;
        _placeholderTextLabel.text = @"What's happening?";
    }
    return _placeholderTextLabel;
}

- (UILabel *)characterCountLabel {
    if (!_characterCountLabel) {
        // We have to make the frame in terms of the size of the view so that it works
        // with a 3.5 inch or 4 inch screen.
        _characterCountLabel = [[UILabel alloc] initWithFrame:
                                CGRectMake(self.composeVC.view.frame.size.width * .8,
                                           self.composeVC.view.frame.size.height * .27,
                                           self.composeVC.view.frame.size.width * .15,
                                           self.composeVC.view.frame.size.height * .1)];
        _characterCountLabel.textAlignment = NSTextAlignmentRight;
        _characterCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        _characterCountLabel.textColor = HAPP_GRAY_COLOR;
        _characterCountLabel.text = @"0/50";
    }
    return _characterCountLabel;
}

- (UIButton *)moodSelector {
    if (!_moodSelector) {
        CGRect moodSelectorFrame = CGRectMake(0, 0,
            self.accerssoryView.bounds.size.width,
            self.accerssoryView.bounds.size.height / 2);
        _moodSelector = [[UIButton alloc] initWithFrame:moodSelectorFrame];
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
        
        CGRect imageValueFrame = CGRectMake(
           HAPP_HORIZONTAL_PADDING * 6.5, 5, 35, 35);
        self.moodSelectorImageView = [[UIImageView alloc] initWithFrame:imageValueFrame];
        
        [_moodSelector addSubview:self.moodSelectorValue];
        [_moodSelector addSubview:self.moodSelectorImageView];
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
        self.durationSelectorLabel.text = @"for the next";
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

#pragma mark UITextViewDelegate methods

-(BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (textView.text.length > 0) {
            [self.happDelegate postWithMessage:textView.text mood:self.mood duration:self.duration];
        }
        return NO;
    }
    // Don't allow input if length is already 50 and this is not a backspace
    if ([textView.text length] >= 50 && ![text isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    BOOL textViewHasText = textView.text.length > 0;
    self.placeholderTextLabel.hidden = textViewHasText;
    [self.sendButton setEnabled:textViewHasText];
    [self setCharacterCount:[textView.text length]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.textView.text = textField.text;
    return YES;
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
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[mood image]];
        imageView.frame = CGRectMake(-75, 0, 30, 30);
        [cellView addSubview:imageView];
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
        self.moodSelectorImageView.image = moodObject.imageInverse;
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
