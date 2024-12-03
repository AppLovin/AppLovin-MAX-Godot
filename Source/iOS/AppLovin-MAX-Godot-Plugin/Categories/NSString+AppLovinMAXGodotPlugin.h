//
//  NSString+AppLovinMAXGodotPlugin.h
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/16/23.
//

#import <Foundation/Foundation.h>

#include "core/object/class_db.h"

#define NSSTRING(_X) [NSString alg_stringWithGodotString: _X]
#define GODOT_STRING(_X) [_X alg_godotString]

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AppLovinMAXGodotPlugin)

+ (NSString *)alg_stringWithGodotString:(String)string;

- (String)alg_godotString;

@end

NS_ASSUME_NONNULL_END
