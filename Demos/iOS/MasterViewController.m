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
#import "StorageViewController.h"
#import "KivaViewControllerNetworking.h"

#import "JSONModel+networking.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

-(void)viewDidAppear:(BOOL)animated
{
    
}

-(IBAction)actionLoadCall:(id)sender
{

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Demos";
        _objects = [NSMutableArray arrayWithArray:@[@"Kiva.org demo", @"GitHub demo", @"Used for storage"]];
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
            StorageViewController* sc  = [[StorageViewController alloc] initWithNibName:@"StorageViewController" bundle:nil];
            [self.navigationController pushViewController:sc animated:YES];
        }break;

        default:
            break;
    }
}

@end
