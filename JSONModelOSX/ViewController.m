//
//  ViewController.m
//  JSONModelOSX
//
//  Created by Marin Todorov on 25/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "ViewController.h"
#import "KivaFeed.h"
#import "LoanModel.h"

#import "JSONModel+networking.h"

enum kServices {
    kServiceKiva = 1
    };

@interface ViewController ()
{
    NSArray* list;
    IBOutlet NSTableView* table;
    
    int currentService;
    KivaFeed* kiva;
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
            
        default:
            return 0;
            break;
    }
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


@end
