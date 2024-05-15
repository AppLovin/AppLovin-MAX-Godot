//
//  NSArray+AppLovinMAXGodotPlugin.h
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/16/23.
//

#import <Foundation/Foundation.h>

#include "core/variant/array.h"

#define NSARRAY(_X) [NSArray alg_arrayWithGodotArray: _X]

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (AppLovinMAXGodotPlugin)

+ (NSArray *)alg_arrayWithGodotArray:(Array)array;

@end

NS_ASSUME_NONNULL_END
