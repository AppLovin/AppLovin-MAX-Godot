//
//  NSObject+AppLovinMAXGodotPlugin.m
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/16/23.
//

#import "NSObject+AppLovinMAXGodotPlugin.h"
#import "NSArray+AppLovinMAXGodotPlugin.h"
#import "NSDictionary+AppLovinMAXGodotPlugin.h"
#import "NSString+AppLovinMAXGodotPlugin.h"

@implementation NSObject (AppLovinMAXGodotPlugin)

+ (NSObject *)alg_objectFromGodotObject:(Variant)object
{
    if ( object.get_type() == Variant::STRING )
    {
        return [[NSString alloc] initWithUTF8String: ((String) object).utf8().get_data()];
    }
    else if ( object.get_type() == Variant::FLOAT )
    {
        return @((double) object);
    }
    else if ( object.get_type() == Variant::INT )
    {
        return @((long long) object);
    }
    else if ( object.get_type() == Variant::BOOL )
    {
        return @((bool) object);
    }
    else if ( object.get_type() == Variant::DICTIONARY )
    {
        return NSDICTIONARY(object);
    }
    else if ( object.get_type() == Variant::ARRAY )
    {
        return NSARRAY(object);
    }
    
    WARN_PRINT(String("Could not convert unsupported Variant type to NSObject: '" + Variant::get_type_name(object.get_type()) + "'").utf8().get_data());
    return NULL;
}

- (Variant)alg_godotObject
{
    if ( [self isKindOfClass: NSString.class] )
    {
        return GODOT_STRING((NSString *) self);
    }
    else if ( [self isKindOfClass: NSArray.class] )
    {
        Array result;
        for ( id value in (NSArray *) self )
        {
            result.push_back(GODOT_OBJECT(value));
        }
        
        return result;
    }
    else if ( [self isKindOfClass: NSDictionary.class] )
    {
        return GODOT_DICTIONARY((NSDictionary *) self);
    }
    else if ( [self isKindOfClass: NSNumber.class] )
    {
        //Every type except numbers can reliably identify its type.  The following is comparing to the *internal* representation, which isn't guaranteed to match the type that was used to create it, and is not advised, particularly when dealing with potential platform differences (ie, 32/64 bit)
        //To avoid errors, we'll cast as broadly as possible, and only return int or float.
        //bool, char, int, uint, longlong -> int
        //float, double -> float
        NSNumber *value = (NSNumber *) self;
        if ( strcmp([value objCType], @encode(BOOL) ) == 0 )
        {
            return Variant((int) value.boolValue);
        }
        else if ( strcmp([value objCType], @encode(char) ) == 0 )
        {
            return Variant((int) value.charValue);
        }
        else if ( strcmp([value objCType], @encode(int) ) == 0 )
        {
            return Variant(value.intValue);
        }
        else if ( strcmp([value objCType], @encode(unsigned int) ) == 0 )
        {
            return Variant((int) value.unsignedIntValue);
        }
        else if ( strcmp([value objCType], @encode(long long)) == 0 )
        {
            return Variant((int) value.longValue);
        }
        else if ( strcmp([value objCType], @encode(float) ) == 0 )
        {
            return Variant(value.floatValue);
        }
        else if ( strcmp([value objCType], @encode(double) ) == 0 )
        {
            return Variant((float) value.doubleValue);
        }
        else
        {
            return Variant();
        }
    }
    else if ( [self isKindOfClass: NSNull.class] )
    {
        return Variant();
    } else {
        WARN_PRINT("Trying to convert unknown NSObject type to Variant");
        return Variant();
    }
}

@end
