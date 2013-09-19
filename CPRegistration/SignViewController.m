//
//  SignViewController.m
//  CPRegistration
//
//  Created by Adrian Wobito on 2012-12-31.
//  Copyright (c) 2012 Adrian Wobito. All rights reserved.
//

#import "SignViewController.h"
#import "T1Autograph.h"
#import <QuartzCore/QuartzCore.h>


@interface SignViewController ()

@end

@implementation SignViewController 

@synthesize userData, windowTitle, responseData, responseArray, firstField, lastField, cityField, stateField, activityIndicator, autograph, autographModal, outputImage, uploadImageConn, printConn, checkinConn,myPopover, passedSelectedState, imageData;

#pragma mark - Initialize Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initialize Response Data.
    responseData = [[NSMutableData alloc] init];
    responseArray = [[NSMutableDictionary alloc] init];
    imageData = [[NSData alloc] init];
    
    //Set fields from passed userdata.
    firstField.text = [userData objectForKey:@"first"];
    lastField.text = [userData objectForKey:@"last"];
    cityField.text = [userData objectForKey:@"city"];
    stateField.text = [userData objectForKey:@"state"];
    
    //Setup autograph view and embed in view.
    UIView *autographView = [[UIView alloc] initWithFrame:CGRectMake(0, 460, 770, 290)];
	autographView.layer.borderColor = [UIColor blackColor].CGColor;
	autographView.layer.borderWidth = 0;
	autographView.layer.cornerRadius = 3;
	[autographView setBackgroundColor:[UIColor whiteColor]];
	[self.view addSubview:autographView];
    
    // Initialize Autograph library
	self.autograph = [T1Autograph autographWithView:autographView delegate:self];
	
	// to remove the watermark, get a license code from Ten One, and enter it here
	[autograph setLicenseCode:@"38ba27ca4584918b896b7895f677fe8b3e0433f9"];
    [autograph setExportScale:0.8];
    [autograph setStrokeWidth:5];
    [self showActivityInd:NO];
    windowTitle.title = [userData objectForKey:@"name"];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *) textField
{
    [self performSegueWithIdentifier: @"statePopoverSegue" sender: self];
    return NO;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"statePopoverSegue"]) {
        myPopover = [(UIStoryboardPopoverSegue*)segue popoverController];
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setSelectedState:stateField.text];        
    }
}

-(void) returnFromPopup:(NSString *)popupData {
    passedSelectedState = popupData;
    stateField.text = passedSelectedState;
}

#pragma mark - Autograph Methods
-(void)autographDidCompleteWithNoData {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must sign the signature field before continuing" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = 2;
    [alert show];
        
    [self showActivityInd:NO];
}

-(void)autograph:(T1Autograph *)autograph didCompleteWithSignature:(T1Signature *)signature {
	UIImage *img = [UIImage imageWithData:signature.imageData];
    imageData = UIImagePNGRepresentation(img);
    
    if(imageData != nil){
        //Save Image to server
        UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Please confirm all the information is correct" delegate:self cancelButtonTitle:@"Yes, Check-In" otherButtonTitles:@"No, Edit Info", nil];
        confirm.tag = 1;
        [confirm show];

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 1) {
        if(buttonIndex == 0) {
            [self processSignature:imageData];
        }
    } else if(alertView.tag == 3) {
        //Dismiss Modal
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Connect Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {    
    if(connection == uploadImageConn){
        NSLog(@"Received Response from Upload Image Connection");
    }
    
    if(connection == checkinConn){
        NSLog(@"Received Response from Check-In Connection");
    }
    
    if(connection == printConn){
        NSLog(@"Received Response from Print Connection");
    }
    [responseData setLength:0];
    [responseArray removeAllObjects];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(connection == uploadImageConn){
        NSLog(@"Received Data from Upload Image Connection");
    }
    
    if(connection == checkinConn){
        NSLog(@"Received Data from Check-In Connection");
        [responseData appendData:data];
    }
    
    if(connection == printConn){
        NSLog(@"Received Data from Print Connection");
        [responseData appendData:data];
    }


}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{

    if(connection == uploadImageConn) {
        NSLog(@"Upload Image Connection Finished Loading");
        NSLog(@"Processing Check-In");
        [self processCheckin];        
    }
    
    if(connection == checkinConn) {
        NSLog(@"Check-In Connection Finished Loading");
        NSLog(@"Processing Printing Nametags");
        if([responseData length] > 0) {
            responseArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
            [self processPrintNameTags];
        }
    }
    
    if(connection == printConn) {
        NSLog(@"Print Connection Finished Loading");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You" message:@"Your nametag has been sent to the printer. Enjoy the Conference" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        alert.tag = 3;
        [alert show];
        
        NSLog(@"FINISHED PROCESSING: Hide Indicator");
        [self showActivityInd:NO];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSString *errorStr = [NSString stringWithFormat:@"The upload could not complete - %@",error];
    
    UIAlertView *errorAlert =[[UIAlertView alloc] initWithTitle:@"Error" message:errorStr delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    errorAlert.tag = 4;
    [errorAlert show];
    
    NSLog(@"CONNECTION ERROR: Hide Indicator");
    [self showActivityInd:NO];
}

#pragma mark - Process Signature Data

-(void) processSignature:(NSData*)imgData {
    
    [self showActivityInd:YES];
    
    //Set Post Strings

    NSString *imageName = [NSString stringWithFormat:@"%@-SIGNATURE.png",[userData objectForKey:@"attendance_id"]];
    NSString *aid = [NSString stringWithFormat:@"%@",[userData objectForKey:@"attendance_id"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[userData objectForKey:@"user_id"]];
    //Set URL String
        NSString *urlString = [NSString stringWithFormat:@"%@/cpreg/users/upload",[[NSUserDefaults standardUserDefaults] objectForKey:@"ServerRoot"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    //
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filenames\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[imageName dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"aid\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[aid dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[userId dataUsingEncoding:NSUTF8StringEncoding]];
    //
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media\"; filename=\"%@\"\r\n",imageName] dataUsingEncoding:NSUTF8StringEncoding]];
    //
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imgData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];

    self.uploadImageConn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void) processCheckin {
    NSString *post = [NSString stringWithFormat:@"first=%@&last=%@&city=%@&state=%@&user_id=%@&attendance_id=%@",
                      firstField.text, lastField.text, cityField.text, stateField.text, [userData objectForKey:@"user_id"],[userData objectForKey:@"attendance_id"]];
    NSString *urlCheckinString = [NSString stringWithFormat:@"%@/cpreg/users/checkin",[[NSUserDefaults standardUserDefaults] objectForKey:@"ServerRoot"]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc] init];
    [request2 setURL:[NSURL URLWithString:urlCheckinString]];
    [request2 setHTTPMethod:@"POST"];
    [request2 setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request2 setHTTPBody:postData];
    
    self.checkinConn = [[NSURLConnection alloc] initWithRequest:request2 delegate:self];
}

-(void) processPrintNameTags {
    
    NSString *post = [NSString stringWithFormat:@"pdf=%@",[responseArray valueForKey:@"pdf"]];

    NSString *urlPrinter = [NSString stringWithFormat:@"%@/cpreg/printer/execute",[[NSUserDefaults standardUserDefaults] objectForKey:@"ServerRoot"]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlPrinter]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    self.printConn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

#pragma mark - IBActions

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)backgroundTouched:(id)sender {
    [firstField resignFirstResponder];
    [lastField resignFirstResponder];
    [cityField resignFirstResponder];
    [stateField resignFirstResponder];
}

-(IBAction)textFieldReturn:(id)sender {
    [sender resignFirstResponder];
}

-(IBAction)clearButtonAction:(id)sender {
	[autograph reset:self];
}

-(IBAction)doneButtonAction:(id)sender {
    [autograph done:self];
}

#pragma mark - Require Methods
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showActivityInd:(BOOL) flag {
    if(flag == YES) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        activityIndicator.hidden = NO;
        NSLog(@"Show Activity Indicator");
    } else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        activityIndicator.hidden = YES;
        NSLog(@"Hide Activity Indicator");        
    }
}

- (void)viewDidUnload {
    [self setCloseButton:nil];
    [self setWindowTitle:nil];
    [self setFirstField:nil];
    [self setLastField:nil];
    [self setCityField:nil];
    [self setStateField:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

@end
