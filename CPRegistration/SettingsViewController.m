//
//  SettingsViewController.m
//  CPRegistration
//
//  Created by Adrian Wobito on 2013-01-01.
//  Copyright (c) 2013 Adrian Wobito. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize serverTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    serverTextField.text = [defaults objectForKey:@"ServerRoot"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)viewDidUnload {
    [self setSaveBtn:nil];
    [self setServerTextField:nil];
    [super viewDidUnload];
}

- (IBAction)saveSettings:(id)sender {
    NSString *serverRoot = [[NSString alloc] init];    
    NSRange range = [serverTextField.text rangeOfString:@"http://" options:NSCaseInsensitiveSearch];

    if (range.location == NSNotFound) {
        serverRoot = [NSString stringWithFormat:@"http://%@",serverTextField.text];
    } else {
        serverRoot = [NSString stringWithFormat:@"%@",serverTextField.text];
    }
        
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serverRoot forKey:@"ServerRoot"];
    [defaults synchronize];
      
    [serverTextField resignFirstResponder];
}

@end
