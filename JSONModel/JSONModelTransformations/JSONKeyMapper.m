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
    return [self initWithKeyMappingBlock:^NSString *(Class cls, NSString *modelKey)
    {
        return toJSON(modelKey);
    }];
}

- (instancetype)initWithKeyMappingBlock:(JSONModelKeyMappingBlock)keyMappingBlock
{
    if (!(self = [self init]))
        return nil;

    _keyMappingBlock = keyMappingBlock;

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

    _keyMappingBlock = ^NSString *(Class cls, NSString *modelKey)
    {
        return [toJSON valueForKeyPath:modelKey] ?: modelKey;
    };

    return self;
}

- (JSONModelKeyMapBlock)JSONToModelKeyBlock
{
    return nil;
}

- (JSONModelKeyMapBlock)modelToJSONKeyBlock
{
    return ^NSString *(NSString *keyName)
    {
        return _keyMappingBlock(nil, keyName);
    };
}

+ (NSDictionary *)swapKeysAndValuesInDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = dictionary.allKeys;
    NSArray *values = [dictionary objectsForKeys:keys notFoundMarker:[NSNull null]];

    return [NSDictionary dictionaryWithObjects:keys forKeys:values];
}

- (NSString *)convertValue:(NSString *)value isImportingToModel:(BOOL)importing
{
    return [self convertValue:value forClass:nil];
}

- (NSString *)convertValue:(NSString *)value
{
    return [self convertValue:value forClass:nil];
}

- (NSString *)convertValue:(NSString *)value forClass:(Class)cls
{
    return _keyMappingBlock(cls, value);
}

+ (instancetype)mapperFromUnderscoreCaseToCamelCase
{
    return [self mapperForSnakeCase];
}

+ (instancetype)mapperForSnakeCase
{
    return [[self alloc] initWithKeyMappingBlock:^NSString *(Class cls, NSString *modelKey)
    {
        NSMutableString *result = [NSMutableString stringWithString:modelKey];
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
    return [[self alloc] initWithKeyMappingBlock:^NSString *(Class cls, NSString *modelKey)
    {
        return [modelKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[modelKey substringToIndex:1].uppercaseString];
    }];
}

+ (instancetype)mapperFromUpperCaseToLowerCase
{
    return [[self alloc] initWithKeyMappingBlock:^NSString *(Class cls, NSString *modelKey)
    {
        return modelKey.uppercaseString;
    }];
}

+ (instancetype)mapper:(JSONKeyMapper *)baseKeyMapper withExceptions:(NSDictionary *)exceptions
{
    NSDictionary *toJSON = [JSONKeyMapper swapKeysAndValuesInDictionary:exceptions];

    return [self baseMapper:baseKeyMapper withModelToJSONExceptions:toJSON];
}

+ (instancetype)baseMapper:(JSONKeyMapper *)baseKeyMapper withModelToJSONExceptions:(NSDictionary *)toJSON
{
    return [[self alloc] initWithKeyMappingBlock:^NSString *(Class cls, NSString *modelKey)
    {
        if (!modelKey)
            return nil;

        if (toJSON[modelKey])
            return toJSON[modelKey];

        return baseKeyMapper.keyMappingBlock(cls, modelKey);
    }];
}

@end
