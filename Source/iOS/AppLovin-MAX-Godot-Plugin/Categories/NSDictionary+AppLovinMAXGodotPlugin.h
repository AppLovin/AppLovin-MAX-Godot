//
//  NSDictionary+AppLovinMAXGodotPlugin.h
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/16/23.
//

#import <Foundation/Foundation.h>

#include "core/variant/dictionary.h"

#define NSDICTIONARY(_X) [NSDictionary alg_dictionaryWithGodotDictionary: _X]
#define GODOT_DICTIONARY(_X) [_X alg_godotDictionary]

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (AppLovinMAXGodotPlugin)

+ (NSDictionary *)alg_dictionaryWithGodotDictionary:(Dictionary)dictionary;

- (Dictionary)alg_godotDictionary;

@end

NS_ASSUME_NONNULL_END
