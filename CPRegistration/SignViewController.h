//
//  SignViewController.h
//  CPRegistration
//
//  Created by Adrian Wobito on 2012-12-31.
//  Copyright (c) 2012 Adrian Wobito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "T1Autograph.h"
#import "StateViewController.h"
@interface SignViewController : UIViewController <UIAlertViewDelegate, T1AutographDelegate, UITextFieldDelegate, UIPopoverControllerDelegate, PopupPassData> {
    T1Autograph *autograph;
	T1Autograph *autographModal;
	UIImageView *outputImage;
}

@property (nonatomic, weak) UIPopoverController *myPopover;
@property (copy,nonatomic) NSString* passedSelectedState;

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableDictionary *responseArray;

@property (nonatomic, retain) NSURLConnection *uploadImageConn;
@property (nonatomic, retain) NSURLConnection *checkinConn;
@property (nonatomic, retain) NSURLConnection *printConn;

@property (retain) T1Autograph *autograph;
@property (retain) T1Autograph *autographModal;
@property (retain) UIImageView *outputImage;

@property (strong, nonatomic) IBOutlet UITextField *firstField;
@property (strong, nonatomic) IBOutlet UITextField *lastField;
@property (strong, nonatomic) IBOutlet UITextField *cityField;
@property (strong, nonatomic) IBOutlet UITextField *stateField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) NSData *imageData;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic,copy) NSDictionary *userData;
@property (strong, nonatomic) IBOutlet UINavigationItem *windowTitle;

- (IBAction)closeModal:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (IBAction)textFieldReturn:(id)sender;


@end
