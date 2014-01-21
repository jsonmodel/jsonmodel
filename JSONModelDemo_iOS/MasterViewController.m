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

#import <objc/runtime.h>
#import <objc/message.h>

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

/*
#define OPT(type, opt, name) type name; @property id opt name##Property__;
#define OptionalProperties(...) @property BOOL zz_____OptionalPropertiesBegin;  __VA_ARGS__ @property BOOL zz_____OptionalPropertiesEnd;

@interface Ignore_Model : JSONModel

//OptionalProperties
//(
    @property (strong, nonatomic) NSNumber<Optional>* oName;
//)

@property (assign, nonatomic) OPT(BOOL, <Optional>, name);
@property (strong, nonatomic) NSNumber<Ignore, Optional, Index>* iName;
@property (strong, nonatomic) NSDate* mydate;

@end

@implementation Ignore_Model

//@dynamic nameProperty;

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return ([propertyName isEqualToString:@"name"]);
}

@end

@interface TopModel : JSONModel
@property (strong, nonatomic) Ignore_Model* im;
@end

@implementation TopModel
@end
*/

#define modelOptional

@protocol JSONAnswer

@end

//
// JSON Connector
//

@protocol JSONAnswerJSON

@required
@property (nonatomic) NSString* name;

@optional
@property (nonatomic) NSString* age;

-(void)importAgeFromJSON:(id)value;
-(id)exportAgeToJSON;

-(void)importAgeFromCoreData:(id)value;
-(id)exportAgeToCoreData;

@end

@interface JSONAnswer : JSONModel
@property (nonatomic, modelOptional) NSString* name;
@end

@implementation JSONAnswer
@end

@interface TopModel : JSONModel
@property (strong, nonatomic) NSArray<JSONAnswer>* answers;
@end

@implementation TopModel
+(BOOL)propertyIsOptional:(NSString*)propertyName {
    if ([propertyName isEqualToString:@"answers"]) {
        return YES;
    }
    return [super propertyIsOptional:propertyName];
}
@end

@implementation MasterViewController

-(void)viewDidAppear:(BOOL)animated
{
    
    
    
    /*
    Protocol *proto = objc_getProtocol(@"JSONAnswerJSON".UTF8String);
    NSLog(@"proto: %@", proto);
    
    unsigned int propertyCount;
    objc_property_t *properties = protocol_copyPropertyList(proto, &propertyCount);
    
    NSLog(@"%i properties found", propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i++) {
        //get property name
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSString* name = [NSString stringWithUTF8String:propertyName];
        
        //JMLog(@"property: %@", p.name);
        
        //get property attributes
        const char *attrs = property_getAttributes(property);
        NSString* propertyAttributes = [NSString stringWithUTF8String:attrs];
        
        NSLog(@"%@ attr: %@", name, propertyAttributes);
    }
    
    /*
    NSString* json = @"{}";
    TopModel* mm = [[TopModel alloc] initWithString:json error:nil];
    NSLog(@"TopModel: %@", mm);
    
    
    NSString* json = @"{\"im\":{\"name\": \"1\",\"oName\":null, \"mydate\":\"2013-09-20T07:56:16+0200\"}}";
    NSError* err = nil;
    TopModel* tm = [[TopModel alloc] initWithString:json error: &err];
    
    if (err) {
        NSLog(@"Error: %@", err.localizedDescription);
    }
    
    NSLog(@"tm: %@", tm);
    NSLog(@"tm.im: %@", tm.im);
    NSLog(@"tm.im.oname: %@", tm.im.oName);
    NSLog(@"tm.mydate: %@ %@", [tm.im.mydate class], tm.im.mydate);
    */
    //[self tableView: self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
/*
    [JSONHTTPClient setTimeoutInSeconds:2];
    [JSONHTTPClient getJSONFromURLWithString:@"http://localhost/testapi/test.php"
                                  completion:^(NSDictionary *json, JSONModelError *err) {
                                      NSLog(@"success: got json %@", json);
                                      NSLog(@"error: got %@", [err localizedDescription]);
                                  }];
    
    [JSONCache sharedCache].expirationTimeInHours = kImmediatelyExpire;
    [JSONCache sharedCache].expirationTimeInHoursWhenOffline = kNeverExpire;
    [JSONCache sharedCache].revalidateCacheViaETagAfterTimeInHours = kAlwaysRevalidate;
    [JSONCache sharedCache].revalidateCacheFromServerAfterTimeInHours = kAlwaysRevalidate;
    
    [[JSONCache sharedCache] loadCacheFromDisc];

    NSLog(@"cache: %@", [JSONCache sharedCache]);
    
    [JSONHTTPClient setIsUsingJSONCache: YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(actionLoadCall:)];
 */
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
