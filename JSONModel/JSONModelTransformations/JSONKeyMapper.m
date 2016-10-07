//
//  JSONKeyMapper.m
//  JSONModel
//

#import "JSONKeyMapper.h"

@implementation JSONKeyMapper

- (instancetype)initWithJSONToModelBlock:(JSONModelKeyMapBlock)toModel modelToJSONBlock:(JSONModelKeyMapBlock)toJSON
{
    return [self initWithModelToJSONBlock:toJSON];
}

- (instancetype)initWithModelToJSONBlock:(JSONModelKeyMapBlock)toJSON
{
    if (!(self = [self init]))
        return nil;

    _modelToJSONKeyBlock = toJSON;

    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)map
{
    NSDictionary *toJSON  = [JSONKeyMapper swapKeysAndValuesInDictionary:map];

    return [self initWithModelToJSONDictionary:toJSON];
}

- (instancetype)initWithModelToJSONDictionary:(NSDictionary *)toJSON
{
    if (!(self = [super init]))
        return nil;

    _modelToJSONKeyBlock = ^NSString *(NSString *keyName)
    {
        return [toJSON valueForKeyPath:keyName] ?: keyName;
    };

    return self;
}

- (JSONModelKeyMapBlock)JSONToModelKeyBlock
{
    return nil;
}

+ (NSDictionary *)swapKeysAndValuesInDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = dictionary.allKeys;
    NSArray *values = [dictionary objectsForKeys:keys notFoundMarker:[NSNull null]];

    return [NSDictionary dictionaryWithObjects:keys forKeys:values];
}

- (NSString *)convertValue:(NSString *)value isImportingToModel:(BOOL)importing
{
    return [self convertValue:value];
}

- (NSString *)convertValue:(NSString *)value
{
    return _modelToJSONKeyBlock(value);
}

+ (instancetype)mapperFromUnderscoreCaseToCamelCase
{
    return [self mapperForSnakeCase];
}

+ (instancetype)mapperForSnakeCase
{
    return [[self alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName)
    {
        NSMutableString *result = [NSMutableString stringWithString:keyName];
        NSRange range;

        // handle upper case chars
        range = [result rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
        while (range.location != NSNotFound)
        {
            NSString *lower = [result substringWithRange:range].lowercaseString;
            [result replaceCharactersInRange:range withString:[NSString stringWithFormat:@"_%@", lower]];
            range = [result rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
        }

        // handle numbers
        range = [result rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
        while (range.location != NSNotFound)
        {
            NSRange end = [result rangeOfString:@"\\D" options:NSRegularExpressionSearch range:NSMakeRange(range.location, result.length - range.location)];

            // spans to the end of the key name
            if (end.location == NSNotFound)
                end = NSMakeRange(result.length, 1);

            NSRange replaceRange = NSMakeRange(range.location, end.location - range.location);
            NSString *digits = [result substringWithRange:replaceRange];
            [result replaceCharactersInRange:replaceRange withString:[NSString stringWithFormat:@"_%@", digits]];
            range = [result rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:0 range:NSMakeRange(end.location + 1, result.length - end.location - 1)];
        }

        return result;
    }];
}

+ (instancetype)mapperForTitleCase
{
    return [[self alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName)
    {
        return [keyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[keyName substringToIndex:1].uppercaseString];
    }];
}

+ (instancetype)mapperFromUpperCaseToLowerCase
{
    return [[self alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName)
    {
        return keyName.uppercaseString;
    }];
}

+ (instancetype)mapper:(JSONKeyMapper *)baseKeyMapper withExceptions:(NSDictionary *)exceptions
{
    NSDictionary *toJSON = [JSONKeyMapper swapKeysAndValuesInDictionary:exceptions];

    return [self baseMapper:baseKeyMapper withModelToJSONExceptions:toJSON];
}

+ (instancetype)baseMapper:(JSONKeyMapper *)baseKeyMapper withModelToJSONExceptions:(NSDictionary *)toJSON
{
    return [[self alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName)
    {
        if (!keyName)
            return nil;

        if (toJSON[keyName])
            return toJSON[keyName];

        return baseKeyMapper.modelToJSONKeyBlock(keyName);
    }];
}

@end
