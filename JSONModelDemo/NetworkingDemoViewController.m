//
//  NetworkingDemoViewController.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 07/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "NetworkingDemoViewController.h"
#import "KivaFeed.h"
#import "JSONModel+networking.h"

#define kKivaURL @"http://www.jsonmodel.com/samplejson/kivafeed/delayed.php"

@interface NetworkingDemoViewController ()
{
    IBOutlet UIImageView* img;
}

@end

@implementation NetworkingDemoViewController

- (void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:1.5
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat
                     animations:^{
                         img.center = CGPointMake(250,img.center.y);
                     } completion:^(BOOL finished) {
                        //
                     }];

}

-(IBAction)actionGetViaNSData:(id)sender
{
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:kKivaURL] options:NSDataReadingUncached error:nil];
    id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    KivaFeed* model = [[KivaFeed alloc] initWithDictionary:obj];

    [[[UIAlertView alloc] initWithTitle:@"Finished"
                                message:[NSString stringWithFormat: @"Done getting the JSON feed for %i Kiva.org loans from the Internet", model.loans.count]
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles: nil] show];
}

-(IBAction)actionGetViaJSONHTTPClient:(id)sender
{
    KivaFeed* model = [[KivaFeed alloc] initFromURLWithString:kKivaURL];
    [[[UIAlertView alloc] initWithTitle:@"Finished"
                                message:[NSString stringWithFormat: @"Done getting the JSON feed for %i Kiva.org loans from the Internet", model.loans.count]
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles: nil] show];
    
}

-(IBAction)actionGetAsyncViaJSONHTTPClient:(id)sender
{
    KivaFeed* model = [[KivaFeed alloc] initFromURLWithString:kKivaURL
                                                   completion:^(JSONModel *model, NSException* e) {
                                                      
                                                       KivaFeed* kivaModel = (KivaFeed*)model;
                                                       
                                                       [[[UIAlertView alloc] initWithTitle:@"Finished"
                                                                                   message:[NSString stringWithFormat: @"Done getting the JSON feed for %i Kiva.org loans from the Internet", kivaModel.loans.count]
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"Close"
                                                                         otherButtonTitles: nil] show];
                                                       
                                                   }];
    
}

@end
