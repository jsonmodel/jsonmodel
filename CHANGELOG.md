Changelog
==========

**Version 1.2.0** @2015-12-30

- support added for watchOS and tvOS
- minimum iOS version bumped to 6.0
- support added for Carthage
- deprecated `+arrayOfModelsFromDictionaries:` in favor of `+arrayOfModelsFromDictionaries:error:`
- added `+arrayOfModelsFromString:error:`
- deprecated `+mergeFromDictionary:` in favor of `mergeFromDictionary:useKeyMapping:error:`
- added support for multiple custom setters
- fixed `-hash` implementation
- added `responseData` property to `JSONModelError`
- added support for creating a key mapper with exceptions (`+mapper:withExceptions:`)
- locks now used in key mapper implementation for additional safety
- fixed behavior of `NSURLFromNSString` transformer
- updated project files to latest Xcode
- updated demo apps to work with the latest JSONModel & external API code

**Version 1.1.2** @2015-10-19

Merging more requests re: iOS9

**Version 1.1** @2015-05

Merging more requests

**Version 1.0.2** @ 2015-01-21

- merged a number of pull requests that fix compatibility with iOS 8 and other issues


**Version 1.0** @ 2014-08-12

- bug fix and merged pull requests

**Version 0.13** @ 2014-04-17

- methods to merge data into existing model

- automatic NSCopying and NSCoding for all JSONModel subclasses

- merged number of fixes for the networking library

- XCTest unit tests, demo app runs only on iOS7+



**Version 0.12** @ 2014-02-17

- fixes for BOOLs

- hacked solution for unit tests checking subclassing

- added experimental Core Data support

**Version 0.10** @ 2013-11-10

- fixed handling of *null* values in JSON, which was **broken until now**, make sure to test after upgrading. Now *null* values for required properties will result in a failed init of the model class.

- a number of pull requests for *JSONHTTPClient*, slowly trying to polish it

- added propertyIsIgnored: method, for ignoring primitive properties

- fixes in globalKeyMapper import/export JSON, fixes for automatic snake_case convertions, added masking of BOOL as struct for custom convertors

**Version 0.9.3** @ 2013-09-25

- Bug fixes up to issue #90
- Added "Ignore" protocol, all Optional properties, better documentation

**Version 0.9.2** @ 2013-08-23

- Bug fixes up to issue #74
- Documentation instructions, ignore nils for optional properties on export, special method for optional struct and primitive properties, refactor unit tests

**Version 0.9.1** @ 2013-07-04

- Bug fixes up to issue #61
- Custom name based conversions, more thread safety, new data types supported

**Version 0.9** @ 2013-05-01

- Bug fixes up to issue #37
- Refactor of all networking code, Removing all sync request methods (breaking change)

**Version 0.8.3** @ 2013-01-24

- Bug fixes up to issue #15

**Version 0.8.2** @ 2013-01-01

- Added distribution as a Cocoa Pod

**Version 0.8.1** @ 2012-12-31

- Fixed Xcode workspace for the demo apps

**Version 0.8.0** @ 2012-12-31

- OSX support, automatic network indicator for iOS, speed improvements, better README

**Version 0.7.8** @ 2012-12-25

- Initial release with semantic versioning
