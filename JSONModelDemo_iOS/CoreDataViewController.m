//
//  CoreDataViewController.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 22/1/14.
//  Copyright (c) 2014 Underplot ltd. All rights reserved.
//

#import "CoreDataViewController.h"
#import "JSONModelLib.h"
#import "ReposModel.h"
#import "GitHubRepoModel.h"
#import <CoreData/CoreData.h>
#import "GitHubRepoEntity.h"

@interface CoreDataViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) NSMutableArray* entities;
@property (strong, nonatomic) ReposModel* repos;

@property (strong, nonatomic) IBOutlet UITableView* tableView;

@end

@implementation CoreDataViewController

#pragma mark - Core Data

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] & ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"github" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"github.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - view controller life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.entities = [@[] mutableCopy];
    
    //setup core data
    [self managedObjectContext];
    
    //delete all entities
    NSFetchRequest* entitiesRequest = [[NSFetchRequest alloc] init];
    [entitiesRequest setEntity:[NSEntityDescription entityForName: [[GitHubRepoEntity class] description]
                                   inManagedObjectContext: self.managedObjectContext]];
    [entitiesRequest setIncludesPropertyValues:NO];
    
    for (GitHubRepoEntity* repo in [self.managedObjectContext executeFetchRequest:entitiesRequest error:nil]) {
        [self.managedObjectContext deleteObject:repo];
    }
    [self saveContext];

    //import the json
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"github-iphone.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSError* err;
    self.repos = [[ReposModel alloc] initWithString: jsonContents error:&err];
    
    //setup UI
    self.title = @"CoreData Demo";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Import next repo" style:UIBarButtonItemStylePlain target:self action:@selector(importJSON)];
}

-(void)importJSON
{
    //get next repo to import
    GitHubRepoModel* model = self.repos.repositories.firstObject;
    [self.repos.repositories removeObjectAtIndex:0];
    
    //create an entity for next repo
    NSError* error = nil;
    GitHubRepoEntity* entity = [GitHubRepoEntity entityWithModel:model
                                                       inContext:self.managedObjectContext
                                                           error:&error];
    if (entity) {
        [self.entities addObject: entity];
        [self saveContext];
        [self.tableView reloadData];
    } else {
        NSLog(@"Error importing JSON: %@", error);
    }
    
}

#pragma mark - table stuff
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.entities.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%lu entities", (unsigned long)self.entities.count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    GitHubRepoEntity* entity = self.entities[indexPath.row];
    cell.textLabel.text = entity.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@) forks:%@", entity.owner, entity.language, entity.forks];
    return cell;
}

@end
