//
//  MARewardedInterstitialAd.h
//  AppLovinSDK
//
//  Created by Thomas So on 6/3/20.
//

#import <UIKit/UIKit.h>
#import <AppLovinSDK/MAAdExpirationDelegate.h>
#import <AppLovinSDK/MAAdRevenueDelegate.h>
#import <AppLovinSDK/MAAdRequestDelegate.h>
#import <AppLovinSDK/MAAdReviewDelegate.h>
#import <AppLovinSDK/MARewardedAdDelegate.h>

@class ALSdk;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents a fullscreen ad that the user can skip or be granted a reward upon successful completion of the ad.
 */
@interface MARewardedInterstitialAd : NSObject

/**
 * Create a new MAX rewarded interstitial.
 *
 * @param adUnitIdentifier Ad unit ID to load ads for.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier;

/**
 * Create a new MAX rewarded interstitial.
 *
 * @param adUnitIdentifier Ad unit ID to load ads for.
 * @param sdk              SDK to use. You can obtain an instance of the SDK by calling @code +[ALSdk shared] @endcode.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier sdk:(ALSdk *)sdk;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * A delegate that will be notified about ad events.
 */
@property (nonatomic, weak, nullable) id<MARewardedAdDelegate> delegate;

/**
 * A delegate that will be notified about ad revenue events.
 */
@property (nonatomic, weak, nullable) id<MAAdRevenueDelegate> revenueDelegate;

/**
 * A delegate that will be notified about ad request events.
 */
@property (nonatomic, weak, nullable) id<MAAdRequestDelegate> requestDelegate;

/**
 * A delegate that will be notified about ad expiration events.
 */
@property (nonatomic, weak, nullable) id<MAAdExpirationDelegate> expirationDelegate;

/**
 * A delegate that will be notified about Ad Review events.
 */
@property (nonatomic, weak, nullable) id<MAAdReviewDelegate> adReviewDelegate;

/**
 * Load the current rewarded interstitial. Set @code -[MARewardedInterstitialAd delegate] @endcode to assign a delegate that should be notified about ad load
 * state.
 */
- (void)loadAd;

/**
 * Show the loaded rewarded interstitial ad.
 * <ul>
 * <li>Use @code -[MARewardedInterstitialAd delegate] @endcode to assign a delegate that should be notified about display events.</li>
 * <li>Use @code -[MARewardedInterstitialAd ready] @endcode to check if an ad was successfully loaded.</li>
 * </ul>
 */
- (void)showAd;

/**
 * Show the loaded rewarded interstitial ad for a given placement to tie ad events to.
 * <ul>
 * <li>Use @code -[MARewardedInterstitialAd delegate] @endcode to assign a delegate that should be notified about display events.</li>
 * <li>Use @code -[MARewardedInterstitialAd ready] @endcode to check if an ad was successfully loaded.</li>
 * </ul>
 *
 * @param placement The placement to tie the showing ad’s events to.
 */
- (void)showAdForPlacement:(nullable NSString *)placement;

/**
 * Show the loaded rewarded interstitial ad for a given placement and custom data to tie ad events to.
 * <ul>
 * <li>Use @code -[MARewardedInterstitialAd delegate] @endcode to assign a delegate that should be notified about display events.</li>
 * <li>Use @code -[MARewardedInterstitialAd ready] @endcode to check if an ad was successfully loaded.</li>
 * </ul>
 *
 * @param placement The placement to tie the showing ad’s events to.
 * @param customData The custom data to tie the showing ad’s events to. Maximum size is 8KB.
 */
- (void)showAdForPlacement:(nullable NSString *)placement customData:(nullable NSString *)customData;

/**
 * Show the loaded rewarded interstitial ad for a given placement and custom data to tie ad events to, and a view controller to present the ad from..
 * <ul>
 * <li>Use @code -[MARewardedInterstitialAd delegate] @endcode to assign a delegate that should be notified about display events.</li>
 * <li>Use @code -[MARewardedInterstitialAd ready] @endcode to check if an ad was successfully loaded.</li>
 * </ul>
 *
 * @param placement The placement to tie the showing ad’s events to.
 * @param customData The custom data to tie the showing ad’s events to. Maximum size is 8KB.
 * @param viewController The view controller to display the ad from. If @c nil, will be inferred from the key window's root view controller.
 */
- (void)showAdForPlacement:(nullable NSString *)placement
                customData:(nullable NSString *)customData
            viewController:(nullable UIViewController *)viewController;

/**
 * Whether or not this ad is ready to be shown.
 */
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;

/**
 * Set an extra key/value parameter for the ad.
 *
 * @param key   Parameter key.
 * @param value Parameter value.
 */
- (void)setExtraParameterForKey:(NSString *)key value:(nullable NSString *)value;

/**
 * Set a local extra parameter to pass to the adapter instances. Will not be available in the @code -[MAAdapter initializeWithParameters:withCompletionHandler:] @endcode method.
 *
 * @param key   Parameter key. Must not be null.
 * @param value Parameter value. May be null.
 */
- (void)setLocalExtraParameterForKey:(NSString *)key value:(nullable id)value;

@end

NS_ASSUME_NONNULL_END
