# Changelog

## v1.7.0 (2016-10-07)

- added generic custom setter method - `setPropertyNameWithJSONObject`

## v1.6.0 (2016-10-05)

- added new built-in key mapper - `mapperForTitleCase`

## v1.5.1 (2016-09-12)

- when a data transformer is missing, we now return an error rather than throwing an exception

## v1.5.0 (2016-09-12)

Minor version bump due to deprecations. No breaking changes.

- lots of improvements to readme/contribution docs
- deprecated `mapperFromUpperCaseToLowerCase` (not replaced - it didn't really make sense)
- renamed `mapperFromUnderscoreCaseToCamelCase` to `mapperForSnakeCase` for clarity

## v1.4.2 (2016-09-11)

- change use of `performSelector` to [a safer implementation](https://stackoverflow.com/a/20058585/743957)

## v1.4.1 (2016-09-11)

- restructured custom getter/setter system to resolve crash reported in #436 (thanks @robinzhangx & @hfossli)

## v1.4.0 (2016-08-18)

- deprecated all JSON->Model key mapper methods for consistency's sake - replaced with equivalent Model->JSON methods with clearer naming

## v1.3.0 (2016-07-22)

Sorry for the long time since the last release. We'll be trying to maintain a
more rapid release schedule going forwards.

- precision issue fixed with deserializing numbers
- support added for deserializing into a 'root' dictionary (`dictionaryOfModelsFromDictionary:error:`, etc.)
- lazy collection-type conversion (`ConvertOnDemand`) is no longer supported
- deprecated two way key mapping deprecated - only Model->JSON has ever worked anyway
- deprecated all networking support
- deprecated the global key mapper
- deprecated `Index` protocol
- deprecated `protocolForArrayProperty:` in favor of `classForCollectionProperty:`
- modulemap file added to handle use as a framework better
- success return value added to `mergeFromDictionary:useKeyMapping:error:`
- JSONModel has now been moved out into its own GitHub organization, etc. - now maintained by multiple people

### Potential Breaking Changes

- new behavior for handling null values when serializing:
	- values of `NSNull` will now always `null` in JSON output
	- values of `nil` will now never be included in JSON output

## v1.2.0 (2015-12-30)

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

## v1.1.2 (2015-10-19)

- merging more pull requests RE: iOS 9

## v1.1.0 (2015-05-10)

- merging more pull requests

## v1.0.2 (2015-01-21)

- merged a number of pull requests that fix compatibility with iOS 8 and other issues

## v1.0.0 (2014-08-12)

- bug fix and merged pull requests

## v0.13.0 (2014-04-17)

- methods to merge data into existing model
- automatic NSCopying and NSCoding for all JSONModel subclasses
- merged number of fixes for the networking library
- XCTest unit tests, demo app runs only on iOS7+

## v0.12.0 (2014-02-17)

- fixes for BOOLs
- hacked solution for unit tests checking subclassing
- added experimental Core Data support

## v0.10.0 (2013-11-10)

- fixed handling of *null* values in JSON, which was **broken until now**, make sure to test after upgrading. Now *null* values for required properties will result in a failed init of the model class.
- a number of pull requests for *JSONHTTPClient*, slowly trying to polish it
- added propertyIsIgnored: method, for ignoring primitive properties
- fixes in globalKeyMapper import/export JSON, fixes for automatic snake_case convertions, added masking of BOOL as struct for custom convertors

## v0.9.3 (2013-09-25)

- bug fixes up to issue #90
- added "Ignore" protocol, all Optional properties, better documentation

## v0.9.2 (2013-08-23)

- bug fixes up to issue #74
- documentation instructions, ignore nils for optional properties on export, special method for optional struct and primitive properties, refactor unit tests

## v0.9.1 (2013-07-04)

- bug fixes up to issue #61
- custom name based conversions, more thread safety, new data types supported

## v0.9.0 (2013-05-01)

- bug fixes up to issue #37
- refactor of all networking code, Removing all sync request methods (breaking change)

## v0.8.3 (2013-01-24)

- bug fixes up to issue #15

## v0.8.2 (2013-01-01)

- added distribution as a Cocoa Pod

## v0.8.1 (2012-12-31)

- fixed Xcode workspace for the demo apps

## v0.8.0 (2012-12-31)

- OS X support, automatic network indicator for iOS, speed improvements, better README

## v0.7.8 (2012-12-25)

- initial release with semantic versioning
