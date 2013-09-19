//
//  StateViewController.h
//  CPRegistration
//
//  Created by Adrian Wobito on 2013-01-07.
//  Copyright (c) 2013 Adrian Wobito. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopupPassData <NSObject>

@required

-(void) returnFromPopup:(NSString*) popupData;

@end

@interface StateViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
    NSMutableArray *pickerData;
}

@property (copy, nonatomic) NSString* selectedState;
@property (strong, nonatomic) id delegate;

@property (strong, nonatomic) IBOutlet UIPickerView *statePicker;
@property(nonatomic , retain) NSMutableArray *pickerData;

@end
