## Magical Data Modelling Framework for JSON

![JSONModel for iOS and OSX](http://jsonmodel.com/img/jsonmodel_logolike.png)

JSONModel is a library, which allows rapid creation of smart data models. You can use it in your iOS or OSX apps.

JSONModel automatically introspects your model classes and the structure of your JSON input and reduces drastically the amount of code you have to write.

[![](http://www.touch-code-magazine.com/img/json.png)](http://www.touch-code-magazine.com/img/json.png)


------------------------------------
Adding JSONModel to your project
====================================

#### Requirements

* ARC only; iOS 5.0+ / OSX 10.7+
* **SystemConfiguration.framework**

#### Get it as: 1) source files

1. Download the JSONModel repository as a [zip file](https://github.com/icanzilb/JSONModel/archive/master.zip) or clone it
2. Copy the JSONModel sub-folder into your Xcode project
3. Link your app to SystemConfiguration.framework

#### or 2) via Cocoa pods

In your project's **Podfile** add the JSONModel pod:

```ruby
pod 'JSONModel'
```
If you want to read more about CocoaPods, have a look at [this short tutorial](http://www.raywenderlich.com/12139/introduction-to-cocoapods).

#### Source code documentation
The source code includes class docs, which you can build yourself and import into Xcode:

1. If you don't already have [appledoc](http://gentlebytes.com/appledoc/) installed, install it with [homebrew](http://brew.sh/) by typing `brew install appledoc`.
2. Install the documentation into Xcode by typing `appledoc .` in the root directory of the repository.
3. Restart Xcode if it's already running.

------------------------------------
Basic usage
====================================

Consider you have a JSON like this:
```javascript
{id:"10", "country":"Germany", "dialCode": 49, "isInEurope":true}
```

 * Create a new Objective-C class for your data model and make it inherit the JSONModel class. 
 * Declare properties in your header file with the name of the JSON keys:

```objective-c
#import "JSONModel.h"

@interface CountryModel : JSONModel

@property (assign, nonatomic) int id;
@property (strong, nonatomic) NSString* country;
@property (strong, nonatomic) NSString* dialCode;
@property (assign, nonatomic) BOOL isInEurope;

@end
```
There's no need to do anything in the **.m** file.

 * Initialize your model with data:

```objective-c
#import "CountryModel.h"
...

NSString* json = (fetch here JSON from Internet) ... 
NSError* err = nil;
CountryModel* country = [[CountryModel alloc] initWithString:json error:&err];

```

If the validation of the JSON passes you have all the corresponding properties in your model populated from the JSON. JSONModel will also try to convert as much data to the types you expect, in the example above it will:

* convert "id" from string (in the JSON) to an int for your class
* just copy country's value
* convert dialCode from number (in the JSON) to an NSString value 
* finally convert isInEurope to a BOOL for your BOOL property

And the good news is all you had to do is define the properties and their expected types.

-------
#### Online tutorials


Official website: [http://www.jsonmodel.com](http://www.jsonmodel.com)

Class docs online: [http://jsonmodel.com/docs/](http://jsonmodel.com/docs/)

Tutorial list:

 * [How to fetch and parse JSON by using data models](http://www.touch-code-magazine.com/how-to-fetch-and-parse-json-by-using-data-models/) 

 * [Performance optimisation for working with JSON feeds via JSONModel](http://www.touch-code-magazine.com/performance-optimisation-for-working-with-json-feeds-via-jsonmodel/)

 * [How to make a YouTube app using MGBox and JSONModel](http://www.touch-code-magazine.com/how-to-make-a-youtube-app-using-mgbox-and-jsonmodel/)

-------
Documentation
=======

(This section will be rearranged soon to showcase code)

<table>
<tr>
<td valign="top">
<b>Automatic name based mapping</b> <br>
Just create properties with matching names.
<pre>
{
  "id": "123",
  "name": "Product name",
  "price": 12.95
}
</pre>
</td>
<td>
<pre>
@interface ProductModel
@property (assign, nonatomic) int id;
@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) float price;
@end

@implementation ProductModel
@end
</pre>
</td>
</tr>
</table>

* 
* model cascading (models including models)
* model collections
* one-shot or on-demand JSON to model objects conversion
* key mapping - map JSON keys from deeper levels or with mismatching names easily
* JSON HTTP client - a thin HTTP client for simple async JSON requests
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

Misc
=======

Author: Marin Todorov

Contributors: Christian Hoffmann, Mark Joslin, Julien Vignali, Symvaro GmbH, BB9z.
Also everyone who did successful [pull requests](https://github.com/icanzilb/JSONModel/graphs/contributors).

Change log : [https://github.com/icanzilb/JSONModel/blob/master/Changelog.md](https://github.com/icanzilb/JSONModel/blob/master/Changelog.md)

-------
#### License
This code is distributed under the terms and conditions of the MIT license. 

-------
#### Contribution guidelines

**NB!** If you are fixing a bug you discovered, please add also a unit test so I know how exactly to reproduce the bug before merging.
