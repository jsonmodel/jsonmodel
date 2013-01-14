JSONModel
====================================
------------------------------------
**Magical Data Modelling Framework for JSON**

JSONModel is a library, which allows rapid creation of smart data models. You can use it in your iOS or OSX apps.

**JSONModel does NOT pre-write your code** as many other libs do, instead it uses performance optimized code to introspect your model classes at run-time, thus being way more flexible when you need to do changes.

[![](http://jsonmodel.com/img/jm_ios_screen.png)](http://jsonmodel.com/img/jm_ios_screen.png)
[![](http://jsonmodel.com/img/jm_osx_screen.png)](http://jsonmodel.com/img/jm_osx_screen.png)

The core task of JSONModel is to help you reduce your Objective-C code to parse and import JSON values to Objective-C objects.

JSONModel automatically introspects your model classes and the structure of your JSON input and reduces drastically the amount of code.

The core task of JSONModel is to import, convert, store and export data - through the JSON data types bottleneck:

[![](http://www.touch-code-magazine.com/img/json.png)](http://www.touch-code-magazine.com/img/json.png)

Besides this core task JSONModel does also a whole bunch of other tasks, to help you **automate as much as possible** working with local or remote JSON data.

------------------------------------
Requirements
====================================

* iOS 5.0+ (requires NSJSONSerialization)
* OSX 10.7+ (requires NSJSONSerialization) 
* ARC only

------------------------------------
Adding JSONModel to your project
====================================

Source files
------------

1. Download the JSONModel repository as a zip file or clone it
2. Copy the JSONModel sub-folder into your Xcode project
3. Build your project and check that there are no compile time errors 
(if your project is non-arc for example, you will get a compile time error from the JSONModel library)

Cocoa pod
------------

1. Be sure to update your pods specs:

```bash
pod setup
```

2. In your **Podfile** add the JSONModel pod:

```ruby
pod 'JSONModel'
```
That's it!

If you want to read more about CocoaPods, have a look at [this great tutorial](http://www.raywenderlich.com/12139/introduction-to-cocoapods).

------------------------------------
Basic usage
====================================
1. Create a new Objective-C class for your data model and make it inherit the JSONModel class. 

2. Declare properties in your header file with the name of the JSON keys you have coming in.

If you are parsing this JSON:
```javascript
{"countryCode":"DE", "country":"Germany"}
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

-------
Detailed documentation and tutorials
=======

JSONModel includes tons of functionality: 
* json validation
* key mapping
* data transformations
* automatic data mapping
* error handling
* custom data validation
* automatic underscore_naming to camelCaseNaming mapping
* synchronious and asynchronious networking
* JSON API client
* JSON RPC 1.0 client
* one-shot or on-demand JSON to model objects conversion
* model cascading (models including models)
* model collections
* automatic compare and equality features
* export models back to NSDictionary or JSON text
* and more.

Information and examples: http://www.touch-code-magazine.com/JSONModel/

Official website: http://www.jsonmodel.com

-------
License
=======

This code is distributed under the terms and conditions of the MIT license. 

-------
Contribution guidelines
=======

* if you are fixing a bug you discovered, please add also a unit test so I know how exactly to reproduce the bug before merging

----------
Change-log
==========

**Version 0.8.2** @ 2013-01-01

- Added distribution as a Cocoa Pod

**Version 0.8.1** @ 2012-12-31

- Fixed Xcode workspace for the demo apps

**Version 0.8.0** @ 2012-12-31

- OSX support, test and demos
- automatic network indicator for iOS
- bug fixes, speed improvements
- added better README

**Version 0.7.8** @ 2012-12-25

- Initial release with semantic versioning
