//
//  ViewController.m
//  JSONModelOSX
//
//  Created by Marin Todorov on 25/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "ViewController.h"

//kiva models
#import "KivaFeed.h"
#import "LoanModel.h"

//youtube models
#import "VideoLink.h"
#import "VideoTitle.h"
#import "VideoModel.h"

//github
#import "GitHubUserModel.h"

#import "JSONModel+networking.h"

enum kServices {
    kServiceKiva = 1,
    kServiceYoutube,
    kServiceGithub
    };

@interface ViewController ()
{
    NSArray* list;
    IBOutlet NSTableView* table;
    
    int currentService;

    //kiva
    KivaFeed* kiva;
    
    //youtube
    NSArray* videos;
    
    //github
    GitHubUserModel* user;
    NSArray* items;

}

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        list = @[];
    }
    
    return self;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if ( [tableColumn.identifier isEqualToString:@"MyCol"] )
    {
        switch (currentService) {
            case kServiceKiva:
            {
                LoanModel* loan = kiva.loans[row];
                NSString* message = [NSString stringWithFormat:@"%@ from %@(%@) needs a loan %@",
                                     loan.name, loan.location.country, loan.location.countryCode, loan.use
                                     ];

                cellView.textField.stringValue = message;
                
            }    break;
                
            case kServiceYoutube:
            {
                VideoModel* video = videos[row];
                NSString* message = [NSString stringWithFormat:@"%@",
                                     video.title.$t
                                     ];
                cellView.textField.stringValue = message;
                
            }   break;
            
            case kServiceGithub:
            {
                cellView.textField.stringValue = items[row];
                
            }   break;
                
            default:
                cellView.textField.stringValue = @"n/a";
                break;
        }
        
        return cellView;
    }
    
    return cellView;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    switch (currentService) {
        case kServiceKiva:
            return kiva.loans.count;
            break;
        case kServiceYoutube:
            return videos.count;
            break;
        case kServiceGithub:
            return items.count;
            break;
        default:
            return 0;
            break;
    }
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    switch (currentService) {
        case kServiceYoutube:
        {
            VideoModel* video = videos[rowIndex];
            [[NSWorkspace sharedWorkspace] openURL:video.link.href];
            
        }   break;
            
        default:
            break;
    }
    return YES;
}

#pragma mark - button actions
-(IBAction)actionKiva:(id)sender
{
    currentService = kServiceKiva;
    
    kiva = [[KivaFeed alloc] initFromURLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising"
            completion:^(JSONModel *model, JSONModelError *e) {
                
                [table reloadData];
                
                if (e) {
                    [[NSAlert alertWithError:e] beginSheetModalForWindow:self.view.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
                }
                
            }];
    
}

-(IBAction)actionYoutube:(id)sender
{
    currentService = kServiceYoutube;
    
    [JSONHTTPClient getJSONFromURLWithString:@"http://gdata.youtube.com/feeds/api/videos?q=pomplamoose&max-results=15&alt=json"
                                  completion:^(NSDictionary *json, JSONModelError *e) {
                                      
                                      videos = [VideoModel arrayOfModelsFromDictionaries:
                                                json[@"feed"][@"entry"]
                                                ];
                                      [table reloadData];
                                      if (e) {
                                          [[NSAlert alertWithError:e] beginSheetModalForWindow:self.view.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
                                      }
                                      
                                  }];
}

-(IBAction)actionGithub:(id)sender
{
    currentService = kServiceGithub;
    
    user = [[GitHubUserModel alloc] initFromURLWithString:@"https://api.github.com/users/icanzilb"
                                               completion:^(JSONModel *model, JSONModelError *e) {

                                                   items = @[user.login, user.html_url, user.company, user.name, user.blog];
                                                   [table reloadData];
                                                   
                                                   if (e) {
                                                       [[NSAlert alertWithError:e] beginSheetModalForWindow:self.view.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
                                                   }
                                                   
                                               }];
    
}

@end
