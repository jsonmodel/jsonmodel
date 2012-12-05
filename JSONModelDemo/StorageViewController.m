//
//  StorageViewController.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "StorageViewController.h"
#import "MyDataModel.h"

@interface StorageViewController ()
{
    IBOutlet UITextView* txtContent;
    IBOutlet UILabel* lblTimes;
    
    NSString* filePath;
    MyDataModel* data;
}

@end

@implementation StorageViewController

-(void)viewDidAppear:(BOOL)animated
{
    NSString* libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory , NSUserDomainMask, YES)[0];
    filePath = [libraryDir stringByAppendingPathComponent:@"saved.plist"];

    [self loadFromFile];
}

-(void)loadFromFile
{
    //load from file
    NSDictionary* object = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    //initialize model with data
    data = [[MyDataModel alloc] initWithDictionary: object];

    if (!data) {
        data = [[MyDataModel alloc] init];
    }
    
    //update the UI
    lblTimes.text = [NSString stringWithFormat:@"Times saved: %i", data.timesSaved];
    txtContent.text = data.content;
}

-(IBAction)actionSave:(id)sender
{
    [txtContent resignFirstResponder];
    
    //update model
    data.timesSaved++;
    data.content = txtContent.text;
    
    //update UI
    lblTimes.text = [NSString stringWithFormat:@"Times saved: %i", data.timesSaved];
    
    //save to disc
    [[data toDictionary] writeToFile:filePath atomically:YES];
}

@end
