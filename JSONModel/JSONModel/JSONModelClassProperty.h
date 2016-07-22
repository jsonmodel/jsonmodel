//
//  JSONModelClassProperty.h
//
//  @version 1.3
//  @author Marin Todorov (http://www.underplot.com) and contributors
//

// Copyright (c) 2012-2015 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import <Foundation/Foundation.h>

enum kCustomizationTypes {
    kNotInspected = 0,
    kCustom,
    kNo
};

typedef enum kCustomizationTypes PropertyGetterType;

/**
 * **You do not need to instantiate this class yourself.** This class is used internally by JSONModel
 * to inspect the declared properties of your model class.
 *
 * Class to contain the information, representing a class property
 * It features the property's name, type, whether it's a required property,
 * and (optionally) the class protocol
 */
@interface JSONModelClassProperty : NSObject

// deprecated
@property (assign, nonatomic) BOOL isIndex DEPRECATED_ATTRIBUTE;

/** The name of the declared property (not the ivar name) */
@property (copy, nonatomic) NSString *name;

/** A property class type  */
@property (assign, nonatomic) Class type;

/** Struct name if a struct */
@property (strong, nonatomic) NSString *structName;

/** The name of the protocol the property conforms to (or nil) */
@property (copy, nonatomic) NSString *protocol;

/** If YES, it can be missing in the input data, and the input would be still valid */
@property (assign, nonatomic) BOOL isOptional;

/** If YES - don't call any transformers on this property's value */
@property (assign, nonatomic) BOOL isStandardJSONType;

/** If YES - create a mutable object for the value of the property */
@property (assign, nonatomic) BOOL isMutable;

/** The status of property getter introspection in a model */
@property (assign, nonatomic) PropertyGetterType getterType;

/** a custom getter for this property, found in the owning model */
@property (assign, nonatomic) SEL customGetter;

/** custom setters for this property, found in the owning model */
@property (strong, nonatomic) NSMutableDictionary *customSetters;

@end
