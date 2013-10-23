//
//  HappSettingsVC.h
//  Happ
//
//  Created by Brandon Krieger on 10/22/13.
//  Copyright (c) 2013 Happ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HappABModel.h"
#import "HappModel.h"

@interface HappSettingsVC : UITableViewController<UIAlertViewDelegate>

- (id)initWithHappABModel:(HappABModel *)happABModel happModel:(HappModel *)happModel;

@end
