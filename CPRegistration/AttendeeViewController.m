//
//  AttendeeViewController.m
//  CPRegistration
//
//  Created by Adrian Wobito on 2012-12-31.
//  Copyright (c) 2012 Adrian Wobito. All rights reserved.
//

#import "AttendeeViewController.h"
#import "SignViewController.h"

@interface AttendeeViewController ()

@end

@implementation AttendeeViewController

@synthesize attendeesArray;
@synthesize attendeesData;
@synthesize searchResults;
@synthesize searchBar;
@synthesize attendeeTableView;
@synthesize activityInd;
@synthesize refreshBtn;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    searchResults = [[NSMutableArray alloc]init];
    
    activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityInd startAnimating];

    [self loadAttendees];
}

-(void) viewDidAppear:(BOOL)animated {
    //[searchBar becomeFirstResponder];
    searchBar.text = @"";
}
-(void) loadAttendees {
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityInd];
    [self navigationItem].rightBarButtonItem = barButton;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/ipad/attendees/all",[[NSUserDefaults standardUserDefaults] objectForKey:@"ServerRoot"]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    (void) [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (IBAction)refreshFeed:(id)sender {
    [self loadAttendees];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    attendeesData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [attendeesData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    attendeesArray = [NSJSONSerialization JSONObjectWithData:attendeesData options:NSJSONReadingMutableContainers error:nil];
    [attendeeTableView reloadData];
    
    [self navigationItem].rightBarButtonItem = refreshBtn;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSString *errorStr = [NSString stringWithFormat:@"The download could not complete - %@",error];
    
    UIAlertView *errorAlert =[[UIAlertView alloc] initWithTitle:@"Error" message:errorStr delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [errorAlert show];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [attendeesArray count];        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userRow";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        //AND IF YOU PUT AN NSLOG IN HERE, YOU'LL SEE THIS IS CALLED ABOUT THE
        //NUMBER OF TIMES FOR THE INITIALLY VISIBLE CELLS ON THE SCREEN, PLUS 1 OR 2
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row]objectForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",[[searchResults objectAtIndex:indexPath.row]objectForKey:@"city"],[[searchResults objectAtIndex:indexPath.row]objectForKey:@"state"]];
    } else {
        cell.textLabel.text = [[attendeesArray objectAtIndex:indexPath.row]objectForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",[[attendeesArray objectAtIndex:indexPath.row]objectForKey:@"city"],[[attendeesArray objectAtIndex:indexPath.row]objectForKey:@"state"]];
    }    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier: @"signSegue" sender: self];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"signSegue"]) {
        if ([self.searchDisplayController isActive]) {
           
            NSDictionary *row = [searchResults objectAtIndex:[[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow] row]];
            SignViewController *svc = (SignViewController *) [segue destinationViewController];
            svc.userData = row;
            svc.title = [row objectForKey:@"name"];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow] animated:YES];

        } else {
            NSDictionary *row = [attendeesArray objectAtIndex:[[attendeeTableView indexPathForSelectedRow] row]];
            SignViewController *svc = (SignViewController *) [segue destinationViewController];
            svc.userData = row;
            svc.title = [row objectForKey:@"name"];
            [attendeeTableView deselectRowAtIndexPath:[attendeeTableView indexPathForSelectedRow] animated:YES];
        }
    }
}

-(void) filterContentForSearchText:(NSString *) searchText scope:(NSString *) scope {
    [searchResults removeAllObjects];
    for(NSArray *attendee in attendeesArray) {
        NSRange attendeeRange = [[attendee valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if(attendeeRange.location != NSNotFound) {
            [searchResults addObject:attendee];
        }
    }
    
    [self.attendeeTableView reloadData];
}


#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)viewDidUnload {
    [self setAttendeeTableView:nil];
    [self setSearchBar:nil];
    [self setRefreshBtn:nil];
    [super viewDidUnload];
}

@end
