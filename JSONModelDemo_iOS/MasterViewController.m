//
//  MasterViewController.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "MasterViewController.h"

#import "KivaViewController.h"
#import "GitHubViewController.h"
#import "YouTubeViewController.h"
#import "StorageViewController.h"
#import "KivaViewControllerNetworking.h"

#import "JSONModel+networking.h"
#import "VideoModel.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

-(void)viewDidAppear:(BOOL)animated
{
    //[self tableView: self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [JSONCache sharedCache].expirationTimeInHours = kImmediatelyExpire;
    [JSONCache sharedCache].expirationTimeInHoursWhenOffline = kNeverExpire;
    [JSONCache sharedCache].revalidateCacheViaETagAfterTimeInHours = kAlwaysRevalidate;
    [JSONCache sharedCache].revalidateCacheFromServerAfterTimeInHours = kAlwaysRevalidate;
    
    [[JSONCache sharedCache] loadCacheFromDisc];

    NSLog(@"cache: %@", [JSONCache sharedCache]);
    
    [JSONHTTPClient setIsUsingJSONCache: YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(actionLoadCall:)];
}

-(IBAction)actionLoadCall:(id)sender
{
    [JSONHTTPClient getJSONFromURLWithString:@"http://localhost/testapi/test.php"
                                  completion:^(NSDictionary *json, JSONModelError *err) {
                                      
                                      NSLog(@"GOT: %@", [json allKeys]);
                                      
                                  }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Demos";
        _objects = [NSMutableArray arrayWithArray:@[@"Kiva.org demo", @"GitHub demo", @"Youtube demo", @"Used for storage", @"Kiva.org + own networking"]];
    }
    return self;
}
							
#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{
            KivaViewController* kiva  = [[KivaViewController alloc] initWithNibName:@"KivaViewController" bundle:nil];
            [self.navigationController pushViewController:kiva animated:YES];
        }break;
            
        case 1:{
            GitHubViewController* gh  = [[GitHubViewController alloc] initWithNibName:@"GitHubViewController" bundle:nil];
            [self.navigationController pushViewController:gh animated:YES];
        }break;
            
        case 2:{
            YouTubeViewController* yt  = [[YouTubeViewController alloc] initWithNibName:@"YouTubeViewController" bundle:nil];
            [self.navigationController pushViewController:yt animated:YES];
        }break;
            
        case 3:{
            StorageViewController* sc  = [[StorageViewController alloc] initWithNibName:@"StorageViewController" bundle:nil];
            [self.navigationController pushViewController:sc animated:YES];
        }break;

        case 4:{
            KivaViewControllerNetworking* sc  = [[KivaViewControllerNetworking alloc] initWithNibName:@"KivaViewControllerNetworking" bundle:nil];
            [self.navigationController pushViewController:sc animated:YES];
        }break;

            
        default:
            break;
    }
}

@end
