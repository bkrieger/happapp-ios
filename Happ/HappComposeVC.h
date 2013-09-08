//
//  HappComposeVC.h
//  Happ
//
//  Created by Brandon Krieger on 9/7/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HappComposeVCDelegate.h"
#import "HappComposeVCDataSource.h"

@interface HappComposeVC : UINavigationController<UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

- (id)initWithDelegate:(NSObject<HappComposeVCDelegate> *)delegate
            dataSource:(NSObject<HappComposeVCDataSource> *)dataSource;

- (void)dispose;

@end
