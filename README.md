JSONModel
====================================
------------------------------------
Magical Data Modelling Framework for JSON

JSONModel is a library, which allows rapid creation of smart data models. You can use it in your iOS or OSX apps.

[![](http://jsonmodel.com/img/jm_ios_screen.png)](http://jsonmodel.com/img/jm_ios_screen.png)
[![](http://jsonmodel.com/img/jm_osx_screen.png)](http://jsonmodel.com/img/jm_osx_screen.png)

------------------------------------
Requirements
====================================

* iOS 5.0+ (requires NSJSONSerialization)
* OSX 10.7+ (requires NSJSONSerialization) 
* ARC only

------------------------------------
Adding JSONModel to your project
====================================

Cocoa pod
------------

* coming soon ...

Source files
------------

1. Download the JSONModel repository as a zip file or clone it
2. Copy the JSONModel sub-folder into your Xcode project
3. Build your project and check that there are no compile time errors 
(if your project is non-arc for example, you will get a compile time error from the JSONModel library)

------------------------------------
Basic usage
====================================
1. Create a new Objective-C class for your data model and make it inherit the JSONModel class. 

2. Declare properties in your header file with the name of the JSON keys you have coming in.

If you are parsing this JSON:
```javascript
{countryCode:"DE", country:"Germany"}
```

Create the following properties:
```objective-c
#import "JSONModel.h"

@interface LocationModel : JSONModel

@property (strong, nonatomic) NSString* countryCode;
@property (strong, nonatomic) NSString* country;

@end
```
There's no need to do anything in the **.m** file.

3. In your app class include the JSONModel umbrella header:
```objective-c
#import "JSONModelLib.h"
```

4. Initialize your model with data:

```objective-c
NSString* json = (fetch here JSON from Internet) ... 
NSError* err = nil;
LocationModel* location = [[LocationModel alloc] initWithString:json error:&err];
NSLog(@"Country: %@", location.country);
```

or you can use the built-in async initializer to fetch JSON from the web:

```objective-c
LocationModel* location = [[LocationModel alloc] initFromURLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising" 
                          completion: ^(JSONModel *model, JSONModelError* e) {
                              NSLog("Country: %@, error: %@", location.country, [e localizedDescription]);
                          }];
```
-------------------------------------
(Beta) Documentation:
http://www.touch-code-magazine.com/JSONModel/
