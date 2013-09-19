//
//  StateViewController.m
//  CPRegistration
//
//  Created by Adrian Wobito on 2013-01-07.
//  Copyright (c) 2013 Adrian Wobito. All rights reserved.
//

#import "StateViewController.h"

@interface StateViewController ()

@end

@implementation StateViewController

@synthesize pickerData;
@synthesize statePicker, selectedState;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"states" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    
    NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    
    self.pickerData = array;
    selectedState = [[NSString alloc] init];
    NSLog(@"%@",selectedState);
    
}

-(void) viewDidAppear:(BOOL)animated{
    for(int i = 0; i < [pickerData count]; i++) {
        if([[[pickerData objectAtIndex:i] valueForKey:@"abbr"] isEqualToString:selectedState]) {
            [statePicker selectRow:i inComponent:0 animated:YES];
            break;
        }
    }    
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [pickerData count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[pickerData objectAtIndex:row] valueForKey:@"title"];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"%@",[[pickerData objectAtIndex:row] valueForKey:@"abbr"]);
    selectedState = [[pickerData objectAtIndex:row] valueForKey:@"abbr"];
    [[self delegate] returnFromPopup:selectedState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setStatePicker:nil];
    [super viewDidUnload];
}
@end
