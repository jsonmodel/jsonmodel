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
    IBOutlet NSTableView* table;
    IBOutlet NSProgressIndicator* spinner;
    
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

-(void)awakeFromNib
{
    [spinner setHidden:YES];
}

-(void)setLoaderVisible:(BOOL)isVis
{
    [spinner setHidden:!isVis];
    if (isVis) [spinner startAnimation:nil];
    else [spinner stopAnimation:nil];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
        switch (currentService) {
            case kServiceKiva:
            {
                if (row>=kiva.loans.count) return nil;
                
                LoanModel* loan = kiva.loans[row];
                NSString* message = [NSString stringWithFormat:@"%@ from %@(%@) needs a loan %@",
                                     loan.name, loan.location.country, loan.location.countryCode, loan.use
                                     ];

                cellView.textField.stringValue = message;
                
            }    break;
                
            case kServiceGithub:
            {
                if (row>=items.count) return nil;
                cellView.textField.stringValue = [items[row] description];
                
            }   break;
                
            default:
                cellView.textField.stringValue = @"n/a";
                break;
        }
        
    return cellView;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    switch (currentService) {
        case kServiceKiva:
            return kiva.loans.count;
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
        case kServiceGithub:
        {
            id item = items[rowIndex];
            if ([item isKindOfClass:[NSURL class]]) {
                [[NSWorkspace sharedWorkspace] openURL:item];
            }
            
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
    [self setLoaderVisible:YES];
    
    kiva = [[KivaFeed alloc] initFromURLWithString:@"https://api.kivaws.org/v1/loans/search.json?status=fundraising"
            completion:^(JSONModel *model, JSONModelError *e) {
                
                [table reloadData];
                
                if (e) {
                    [[NSAlert alertWithError:e] beginSheetModalForWindow:self.view.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
                }
                
                [self setLoaderVisible:NO];
            }];
    
}

-(IBAction)actionGithub:(id)sender
{
    currentService = kServiceGithub;
    [self setLoaderVisible:YES];
    
    user = [[GitHubUserModel alloc] initFromURLWithString:@"https://api.github.com/users/icanzilb"
                                               completion:^(JSONModel *model, JSONModelError *e) {

                                                   items = @[user.login, user.html_url, user.company, user.name, user.blog];
                                                   [table performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
                                                   
                                                   if (e) {
                                                       [[NSAlert alertWithError:e] beginSheetModalForWindow:self.view.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
                                                   }
                                                   
                                                   [self setLoaderVisible:NO];
                                               }];
    
}

@end
