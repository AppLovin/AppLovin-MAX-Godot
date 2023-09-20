//
//  NSArray+AppLovinMAXGodotPlugin.m
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/16/23.
//

#import "NSArray+AppLovinMAXGodotPlugin.h"
#import "NSObject+AppLovinMAXGodotPlugin.h"

@implementation NSArray (AppLovinMAXGodotPlugin)

+ (NSArray *)alg_arrayWithGodotArray:(Array)array
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for ( int i = 0; i < array.size(); i++ )
    {
        NSObject *value = NSOBJECT(array[i]);
        
        if ( !value ) continue;
        
        [result addObject: value];
    }
    return result;
}

@end
