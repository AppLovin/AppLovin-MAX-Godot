//
//  NSObject+AppLovinMAXGodotPlugin.h
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/16/23.
//

#import <Foundation/Foundation.h>

#include "core/variant/variant.h"

#define NSOBJECT(_X) [NSObject alg_objectFromGodotObject: _X]
#define GODOT_OBJECT(_X) [_X alg_godotObject]

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AppLovinMAXGodotPlugin)

+ (NSObject *)alg_objectFromGodotObject:(Variant)object;

- (Variant)alg_godotObject;

@end

NS_ASSUME_NONNULL_END
