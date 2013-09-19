//
//  SettingsViewController.h
//  CPRegistration
//
//  Created by Adrian Wobito on 2013-01-01.
//  Copyright (c) 2013 Adrian Wobito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UITextField *serverTextField;

- (IBAction)saveSettings:(id)sender;

@end
