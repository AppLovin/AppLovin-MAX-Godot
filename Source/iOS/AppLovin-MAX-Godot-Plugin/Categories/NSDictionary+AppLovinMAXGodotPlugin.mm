//
//  NSDictionary+AppLovinMAXGodotPlugin.m
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/16/23.
//

#import "NSDictionary+AppLovinMAXGodotPlugin.h"
#import "NSObject+AppLovinMAXGodotPlugin.h"
#import "NSString+AppLovinMAXGodotPlugin.h"

@implementation NSDictionary (AppLovinMAXGodotPlugin)

+ (NSDictionary *)alg_dictionaryWithGodotDictionary:(Dictionary)dictionary
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    Array keys = dictionary.keys();
    for ( int i = 0; i < keys.size(); i++ )
    {
        NSString *key = NSSTRING(keys[i]);
        NSObject *value = NSOBJECT(dictionary[keys[i]]);

        if ( !key ) continue;

        result[key] = value;
    }
    
    return result;
}

- (Dictionary)alg_godotDictionary
{
    Dictionary result = Dictionary();
    
    for ( id key in self )
    {
        id value = self[key];
        result[GODOT_OBJECT(key)] = GODOT_OBJECT(value);
    }
    
    return result;
}

@end
