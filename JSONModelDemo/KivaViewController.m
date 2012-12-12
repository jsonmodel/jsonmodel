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

@interface KivaViewController () <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView* table;
    KivaFeed* feed;
}

@end

@implementation KivaViewController

-(void)viewDidAppear:(BOOL)animated
{
    self.title = @"Kiva.org latest loans";
    [HUD showUIBlockingIndicatorWithText:@"Fetching JSON"];
    
    //1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //code executed in the background
        //2
        NSData* kivaData = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising"]
                            ];
        //3
        NSDictionary* json = nil;
        if (kivaData) {
            json = [NSJSONSerialization
                    JSONObjectWithData:kivaData
                    options:kNilOptions
                    error:nil];
        }
        
        //4
        dispatch_async(dispatch_get_main_queue(), ^{
            //code executed on the main queue
            //5
            feed = [[KivaFeed alloc] initWithDictionary: json];
            [HUD hideUIBlockingIndicator];
            
            if (feed) {
                [table reloadData];
            } else {
                //show error
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"Invalid JSON data input"
                                           delegate:nil
                                  cancelButtonTitle:@"Close"
                                  otherButtonTitles:nil] show];
            }
        });
        
    });
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ from %@",
                           loan.name, loan.location.country
                           ];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    
    LoanModel* loan = feed.loans[indexPath.row];
    
    NSString* message = [NSString stringWithFormat:@"%@ from %@ needs a loan %@",
                           loan.name, loan.location.country, loan.use
                           ];
    

    [HUD showAlertWithTitle:@"Loan details" text:message];
}

@end
