JSONModel
====================================
------------------------------------
Magical Data Modelling Framework for JSON
------------------------------------

![JSONModel for iOS and OSX](http://jsonmodel.com/img/jsonmodel_logolike.png)

JSONModel is a library, which allows rapid creation of smart data models. You can use it in your iOS or OSX apps.

**JSONModel does NOT pre-write your code** as many other libs do, instead it uses performance optimized code to introspect your model classes at run-time, thus being way more flexible when you need to do changes.

JSONModel automatically introspects your model classes and the structure of your JSON input and reduces drastically the amount of code.

The core task of JSONModel is to import, convert, store and export data - through the JSON data types bottleneck:

[![](http://www.touch-code-magazine.com/img/json.png)](http://www.touch-code-magazine.com/img/json.png)

Besides this core task JSONModel does also a whole bunch of other tasks, to help you **automate as much as possible** working with local or remote JSON data; it also does provide for you a networking layer, so you don't need to depend on 3rd party networking library (except if you don't want to)

![JSONModel Class schema](http://jsonmodel.com/img/jsonschema.png)

------------------------------------
Requirements
====================================

* iOS 5.0+ (requires NSJSONSerialization)
* OSX 10.7+ (requires NSJSONSerialization) 
* ARC only
* SystemConfiguration.framework

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

Information and examples: http://www.touch-code-magazine.com/JSONModel/

Official website: http://www.jsonmodel.com

## JSONModel features

#### [How to fetch and parse JSON by using data models](http://www.touch-code-magazine.com/how-to-fetch-and-parse-json-by-using-data-models/) [tutorial]

* automatic data mapping
* model cascading (models including models)
* model collections

#### [Performance optimisation for working with JSON feeds via JSONModel](http://www.touch-code-magazine.com/performance-optimisation-for-working-with-json-feeds-via-jsonmodel/)  [tutorial]
* one-shot or on-demand JSON to model objects conversion

#### [How to make a YouTube app using MGBox and JSONModel](http://www.touch-code-magazine.com/how-to-make-a-youtube-app-using-mgbox-and-jsonmodel/)  [tutorial]
* key mapping - map JSON keys from deeper levels or with mismatching names easily
* JSON HTTP client - a thin HTTP client for simple async JSON requests

More tutorials to come on ...

* json validation

* data transformations
* error handling
* custom data validation
* automatic underscore_naming to camelCaseNaming mapping
* synchronious and asynchronious networking
* JSON API client
* JSON RPC 1.0 client
* automatic compare and equality features
* export models back to NSDictionary or JSON text
* and more.

-------
License
=======

This code is distributed under the terms and conditions of the MIT license. 

-------
Contribution guidelines
=======

* if you are fixing a bug you discovered, please add also a unit test so I know how exactly to reproduce the bug before merging

-------
Contributors
=======

Author: Marin Todorov

Contributors: Christian Hoffmann, Mark Joslin, Julien Vignali

----------
Change-log
==========

**Coming soon - Version 0.9** @ tbd

- Refactor of all networking code
- Removing all sync request methods
- Adding network level caching
- Bug fixes up to issue #22

**Version 0.8.3** @ 2013-01-24

- Bug fixes, optimisation and clean up. Github issues up to #15

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
