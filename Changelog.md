Change-log
==========

## Nota Bene!

Version 0.10 will be one of (if not) the last version for the "0" major version. 

Currently I'm wrapping up the features to get into 1.0 and the list of breaking changes it will introduce.

---

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
