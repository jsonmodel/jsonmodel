//
//  KivaViewController.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "KivaViewController.h"
#import "KivaFeed.h"
#import "HUD.h"
#import "JSONModel+networking.h"

@interface KivaViewController () <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView* table;
    KivaFeed* feed;
    
    double benchStart;
    double benchObj;
    double benchEnd;
}

@end

@implementation KivaViewController

-(void)viewDidAppear:(BOOL)animated
{
    self.title = @"Kiva.org latest loans";
    [HUD showUIBlockingIndicatorWithText:@"Fetching JSON"];
    
    [JSONCache sharedCache].isOfflineCacheEnabled = YES;
    [JSONCache sharedCache].expirationTimeInHours = 10;
    [JSONCache sharedCache].expirationTimeInHoursWhenOffline = 10;
    [JSONCache sharedCache].revalidateCacheFromServerAfterTimeInHours = 0;
    
    [JSONHTTPClient setIsUsingJSONCache: YES];
    
    [JSONHTTPClient getJSONFromURLWithString:@"http://api.kivaws.org/v1/loans/search.json"
                                      params:@{@"status":@"fundraising"}
                                  completion:^(NSDictionary *json, JSONModelError *err) {
                                                                            
                                      benchStart = CFAbsoluteTimeGetCurrent();
                                      feed = [[KivaFeed alloc] initWithDictionary: json error:nil];
                                      benchEnd = CFAbsoluteTimeGetCurrent();
                                      
                                      [HUD hideUIBlockingIndicator];
                                      
                                      if (feed) {
                                          [table reloadData];
                                          
                                          [self logBenchmark];
                                      } else {
                                          //show error
                                          [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:[err localizedDescription]
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Close"
                                                            otherButtonTitles:nil] show];
                                      }
                                  }];
}

-(void)logBenchmark
{
    NSLog(@"start: %f", benchStart);
    NSLog(@"model: %f", benchEnd);
    NSLog(@"-------------------------");
    NSLog(@"json -> model: %.4f", benchEnd - benchStart);
}

#pragma mark - table methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return feed.loans.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KivaCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KivaCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    LoanModel* loan = feed.loans[indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ from %@ (%@)",
                           loan.name, loan.location.country, loan.location.countryCode
                           ];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    
    LoanModel* loan = feed.loans[indexPath.row];
    
    NSString* message = [NSString stringWithFormat:@"%@ from %@(%@) needs a loan %@",
                           loan.name, loan.location.country, loan.location.countryCode, loan.use
                           ];
    

    [HUD showAlertWithTitle:@"Loan details" text:message];
}

@end
