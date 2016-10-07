//
//  JSONModelClassProperty.m
//  JSONModel
//

#import "JSONModelClassProperty.h"

@implementation JSONModelClassProperty

-(NSString*)description
{
    //build the properties string for the current class property
    NSMutableArray* properties = [NSMutableArray arrayWithCapacity:8];

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if (self.isIndex) [properties addObject:@"Index"];
#pragma GCC diagnostic pop

    if (self.isOptional) [properties addObject:@"Optional"];
    if (self.isMutable) [properties addObject:@"Mutable"];
    if (self.isStandardJSONType) [properties addObject:@"Standard JSON type"];
    if (self.customGetter) [properties addObject:[NSString stringWithFormat: @"Getter = %@", NSStringFromSelector(self.customGetter)]];

    if (self.customSetters)
    {
        NSMutableArray *setters = [NSMutableArray array];

        for (id obj in self.customSetters.allValues)
        {
            SEL selector;
            [obj getValue:&selector];
            [setters addObject:NSStringFromSelector(selector)];
        }

        [properties addObject:[NSString stringWithFormat: @"Setters = [%@]", [setters componentsJoinedByString:@", "]]];
    }

    NSString* propertiesString = @"";
    if (properties.count>0) {
        propertiesString = [NSString stringWithFormat:@"(%@)", [properties componentsJoinedByString:@", "]];
    }

    //return the name, type and additional properties
    return [NSString stringWithFormat:@"@property %@%@ %@ %@",
            self.type?[NSString stringWithFormat:@"%@*",self.type]:(self.structName?self.structName:@"primitive"),
            self.protocol?[NSString stringWithFormat:@"<%@>", self.protocol]:@"",
            self.name,
            propertiesString
            ];
}

@end
