//
//  NSString+AppLovinMAXGodotPlugin.mm
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/16/23.
//

#import "NSString+AppLovinMAXGodotPlugin.h"

@implementation NSString (AppLovinMAXGodotPlugin)

+ (NSString *)alg_stringWithGodotString:(String)string
{
    return [NSString stringWithUTF8String: string.utf8().get_data()];
}

- (String)alg_godotString
{
    const char *str = self.UTF8String;
    return String::utf8(str != NULL ? str : "");
}

@end
