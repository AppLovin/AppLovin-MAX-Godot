//
//  ALVariableService.h
//  AppLovinSDK
//
//  Created by Thomas So on 10/7/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

@class ALVariableService;

NS_ASSUME_NONNULL_BEGIN

/**
 * Use this service to retrieve values of variables that were pre-defined on AppLovin’s dashboard.
 */
@interface ALVariableService : NSObject

/**
 * Returns the boolean value of the variable named by the given key.
 * Returns @c false if you did not define a boolean mapping for the given key.
 *
 * @param key The name of the variable for which you want to retrieve the value.
 *
 * @return The boolean value of the variable named by the value of @c key, @c false if that value is non-boolean, or @c nil if no such value was found.
 */
- (BOOL)boolForKey:(NSString *)key;

/**
 * Returns the boolean value of the variable named by the given key, or a specified default value.
 * Returns the specified default value if you did not define a boolean mapping for the given key.
 *
 * @param key          The name of the variable for which you want to retrieve the value.
 * @param defaultValue The value to return if the variable named @c key does not exist.
 *
 * @return The value of the variable named by the value of @c key, or the value of @c defaultValue if no such variable was found.
 */
- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;

/**
 * Returns the string value of the variable named by the given key.
 * Returns @c nil if no mapping of the desired type exists for the given key.
 *
 * @param key The name of the variable for which you want to retrieve the value.
 *
 * @return The value of the variable named by the value of @c key, or @c nil if no value was found.
 */
- (nullable NSString *)stringForKey:(NSString *)key;

/**
 * Returns the string value of the variable named by the given key, or a specified default value.
 * Returns the specified default value if no mapping of the desired type exists for the given key.
 *
 * @param key          The name of the variable for which you want to retrieve the value.
 * @param defaultValue The value to return if the variable named @c key does not exist.
 *
 * @return The value of the variable named by the value of @c key, or the value of @c defaultValue if no such variable was found.
 */
- (nullable NSString *)stringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

__attribute__ ((deprecated))
@protocol ALVariableServiceDelegate<NSObject>
- (void)variableService:(ALVariableService *)variableService didUpdateVariables:(NSDictionary<NSString *, id> *)variables __deprecated_msg("This API has been deprecated. Please use our SDK's initialization callback to retrieve variables instead.");
@end

@interface ALVariableService (ALDeprecated)
@property (nonatomic, weak, nullable) id<ALVariableServiceDelegate> delegate __deprecated_msg("This API has been deprecated. Please use our SDK's initialization callback to retrieve variables instead.");
- (void)loadVariables __deprecated_msg("This API has been deprecated. Please use our SDK's initialization callback to retrieve variables instead.");
@end

NS_ASSUME_NONNULL_END
