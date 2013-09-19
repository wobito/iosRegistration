//
//  AttendeeViewController.h
//  CPRegistration
//
//  Created by Adrian Wobito on 2012-12-31.
//  Copyright (c) 2012 Adrian Wobito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttendeeViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, retain) NSArray *attendeesArray;
@property (nonatomic, retain) NSMutableData *attendeesData;
@property (nonatomic, retain) NSMutableArray *searchResults;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;

@property (nonatomic, retain) UIActivityIndicatorView *activityInd;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UITableView *attendeeTableView;
- (IBAction)refreshFeed:(id)sender;

@end
