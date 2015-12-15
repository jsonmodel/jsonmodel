//
//  YouTubeViewController.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "YouTubeViewController.h"
#import "VideoModel.h"
#import "HUD.h"

@interface YouTubeViewController ()
{
    IBOutlet UITableView *table;
    NSArray* items;
}

@end

@implementation YouTubeViewController

-(void)viewDidAppear:(BOOL)animated
{
    self.title = @"Youtube video search";
    [HUD showUIBlockingIndicatorWithText:@"Fetching JSON"];
    
    //1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //code executed in the background
        //2
        NSData* ytData = [NSData dataWithContentsOfURL:
                          [NSURL URLWithString:@"http://gdata.youtube.com/feeds/api/videos?q=pomplamoose&max-results=50&alt=json"]
                          ];
        //3
        NSDictionary* json = [NSJSONSerialization
                    JSONObjectWithData:ytData
                    options:kNilOptions
                    error:nil];

        //4
        dispatch_async(dispatch_get_main_queue(), ^{
            //code executed on the main queue
            //5
            
            items = [VideoModel arrayOfModelsFromDictionaries:
                     json[@"feed"][@"entry"]
                     error:nil];
            
            [HUD hideUIBlockingIndicator];

            if (items) {
                [table reloadData];
            } else {
                [HUD showAlertWithTitle:@"Error" text:@"Sorry, invalid JSON data"];
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
    return items.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KivaCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KivaCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    VideoModel* video = items[indexPath.row];
    cell.textLabel.text = video.title.$t;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    
    VideoModel* video = items[indexPath.row];
    [[UIApplication sharedApplication] openURL: video.link.href];
}


@end
