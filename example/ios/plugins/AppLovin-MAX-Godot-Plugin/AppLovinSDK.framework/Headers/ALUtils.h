//
//  ALUtils.h
//  AppLovinSDK
//
//  Created by Thomas So on 1/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Class containing utility functions for convenience of adapters development and integration.
 */
@interface ALUtils : NSObject

/**
 * @return The currently visible top view controller from the app's window(s).
 */
+ (UIViewController *)topViewControllerFromKeyWindow;

/**
 * @return The app's current @c UIInterfaceOrientationMask.
 */
+ (UIInterfaceOrientationMask)currentOrientationMask;

/**
 * @return The device display dimensions, respecting safe area.
 */
+ (CGRect)deviceSafeAreaDimensions;

/**
 * @return If the app is running in an iOS simulator.
 */
@property (class, nonatomic, readonly, getter=isSimulator) BOOL simulator;

- (instancetype)init NS_UNAVAILABLE;

@end

@interface NSString (ALSdk)
@property (nonatomic, assign, readonly, getter=al_isValidString) BOOL al_validString;
@property (nonatomic, assign, readonly, getter=al_isValidURL) BOOL al_validURL;
- (BOOL)al_isEqualToStringIgnoringCase:(NSString *)otherString;
@end

@interface NSDictionary (ALSdk)
- (BOOL)al_boolForKey:(NSString *)key;
- (BOOL)al_boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (nullable NSNumber *)al_numberForKey:(NSString *)key;
- (nullable NSNumber *)al_numberForKey:(NSString *)key defaultValue:(nullable NSNumber *)defaultValue;
- (nullable NSString *)al_stringForKey:(NSString *)key;
- (nullable NSString *)al_stringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;
- (nullable NSArray<NSNumber *> *)al_numberArrayForKey:(NSString *)key;
- (nullable NSArray<NSNumber *> *)al_numberArrayForKey:(NSString *)key defaultValue:(nullable NSArray<NSNumber *> *)defaultValue;
- (nullable NSArray *)al_arrayForKey:(NSString *)key;
- (nullable NSArray *)al_arrayForKey:(NSString *)key defaultValue:(nullable NSArray *)defaultValue;
- (nullable NSDictionary *)al_dictionaryForKey:(NSString *)key;
- (nullable NSDictionary *)al_dictionaryForKey:(NSString *)key defaultValue:(nullable NSDictionary *)defaultValue;
- (BOOL)al_containsValueForKey:(id)key;
@end

@interface NSNumber (ALSdk)
@property (nonatomic, assign, readonly) NSTimeInterval al_timeIntervalValue;
@end

@interface UIView (ALSdk)
- (void)al_pinToSuperview;
@end

@interface NSDate (ALSdk)
+ (NSTimeInterval)al_timeIntervalNow;
@end

@interface UIImageView (ALSdk)
- (void)al_setImageWithURL:(NSURL *)URL;
@end

NS_ASSUME_NONNULL_END
