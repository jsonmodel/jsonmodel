//
//  JSONModel.h
//
//  @version 0.75
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#import <Foundation/Foundation.h>
#import "JSONModelError.h"
#import "JSONValueTransformer.h"

/////////////////////////////////////////////////////////////////////////////////////////////
#if TARGET_IPHONE_SIMULATOR
#define JMLog( s, ... ) NSLog( @"[%@:%d] %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define JMLog( s, ... )
#endif

/////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Optional property protocol
/** 
 * Protocol for defining optional properties in a JSON Model class. Use like below to define 
 * model properties that are not required to have values in the JSON input:
 * 
 * @property (strong, nonatomic) NSString&lt;Optional&gt;* propertyName;
 *
 */
@protocol Optional
@end

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - JSONModelClassProperty interface
/** 
 * Class to contain the information, representing a class property
 * It features the property's name, type, whether it's a required property, and (optionally) the class protocol
 */
@interface JSONModelClassProperty : NSObject

  /** The name of the declared property (not the ivar name) */
  @property (strong, nonatomic) NSString* name;

  /** A primitive type name ("float", "short", etc) or a class name  */
  @property (strong, nonatomic) NSString* type;

  /** The name of the protocol the property conforms to (or nil) */
  @property (strong, nonatomic) NSString* protocol;

  /** If true, it can be missing in the input data, and the input would be still valid */
  @property (assign, nonatomic) BOOL isOptional;

@end

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - JSONModel protocol
/**
 * A protocol describing an abstract JSONModel class
 * JSONModel conforms to this protocol, so it can use itself abstractly
 */
@protocol AbstractJSONModelProtocol <NSObject>

@required
  /**
   * All JSONModel classes should implement initWithDictionary:
   *
   * For most classes the default initWithDictionary: inherited from JSONModel itself
   * should suffice, but developers have the option ot also overwrite it if needed.
   *
   * @param d a dictionary holding JSON objects, to be imported in the model.
   * @param err an error or NULL
   */
  -(instancetype)initWithDictionary:(NSDictionary*)d error:(NSError**)err;

  /**
   * All JSONModel classes should be able to export themselves as a dictioanry of
   * JSON compliant objects. 
   *
   * For most classes the inherited from JSONModel default toDictionary implementation
   * should suffice.
   *
   * @return NSDictionary dictionary of JSON compliant objects
   * @exception JSONModelTypeNotAllowedException thrown when one of your model's custom class properties does not have matching transformer method in an JSONValueTransformer.
   * @see JSONValueTransformer JSONObjectFromNSURL: for an example how to export custom class property to a JSON compliant object
   */
  -(NSDictionary*)toDictionary;
@end

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - JSONModel interface
/**
 * The JSONModel is an abstract model class, you should ot instantiate it directly,
 * as it does not have any properties, and therefore cannot serve as a data model.
 * Instead you should subclass it, and define the properties you want your data model
 * to have as properties of your own class.
 */
@interface JSONModel : NSObject <AbstractJSONModelProtocol>

/** @name Creating and initializing models */

  /**
   * Create a new model instance and initialize it with the JSON from a text parameter. The method assumes UTF8 encoded input text.
   * @param s JSON text data
   * @param err an initialization error or nil
   * @exception JSONModelTypeNotAllowedException thrown when unsported type is found in the incoming JSON, or a property type in your model is not supported by JSONValueTransformer and its categories
   * @see initWithString:usingEncoding:error: for use of custom text encodings
   */
  -(instancetype)initWithString:(NSString*)s error:(JSONModelError**)err;

  /**
   * Create a new model instance and initialize it with the JSON from a text parameter using the given encoding.
   * @param s JSON text data
   * @param encoding the text encoding to use when parsing the string (see NSStringEncoding)
   * @param err an initialization error or nil
   * @exception JSONModelTypeNotAllowedException thrown when unsported type is found in the incoming JSON, or a property type in your model is not supported by JSONValueTransformer and its categories
   */
  -(instancetype)initWithString:(NSString *)s usingEncoding:(NSStringEncoding)encoding error:(JSONModelError**)err;

  -(instancetype)initWithDictionary:(NSDictionary*)d error:(NSError **)err;

/** @name Exporting model contents */

  -(NSDictionary*)toDictionary;

  /**
   * Export the whole object to a JSON data text string
   * @return JSON text describing the data model
   */
  -(NSString*)toJSONString;

/** @name Batch model creationg */

  /**
   * If you have a list of dictionaries in a JSON feed, you can use this method to create an NSArray
   * of model objects. Handy when importing JSON data lists.
   * This method will loop over the input list and initialize a data model for every dictionary in the list.
   *
   * @param a list of dictionaries to be imported as models
   * @return list of initialized data model objects
   * @exception JSONModelTypeNotAllowedException thrown when unsported type is found in the incoming JSON, or a property type in your model is not supported by JSONValueTransformer and its categories
   * @exception JSONModelInvalidDataException thrown when the input data does not include all required keys
   * @see arrayOfDictionariesFromObjects:
   */
  +(NSMutableArray*)arrayOfObjectsFromDictionaries:(NSArray*)a;

  /**
   * If you have an NSArray of data model objects, this method takes it in and outputs a list of the 
   * matching dictionaries. This method does the opposite of arrayOfObjectsFromDictionaries:
   * @param a list of JSONModel objects
   * @return a list of NSDictionary objects
   * @exception JSONModelTypeNotAllowedException thrown when unsported type is found in the incoming JSON, or a property type in your model is not supported by JSONValueTransformer and its categories
   * @see arrayOfObjectsFromDictionaries:
   */
  +(NSMutableArray*)arrayOfDictionariesFromObjects:(NSArray*)a;

@end