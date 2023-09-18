//
//  MAInterstitial.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/9/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppLovinSDK/MAAdDelegate.h>
#import <AppLovinSDK/MAAdExpirationDelegate.h>
#import <AppLovinSDK/MAAdRequestDelegate.h>
#import <AppLovinSDK/MAAdRevenueDelegate.h>
#import <AppLovinSDK/MAAdReviewDelegate.h>

@class ALSdk;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents a full-screen interstitial ad.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/interstitials">MAX Integration Guide ⇒ iOS ⇒ Interstitials</a>
 */
@interface MAInterstitialAd : NSObject

/**
 * Creates a new mediation interstitial.
 *
 * @param adUnitIdentifier Ad unit ID to load ads for.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier;

/**
 * Creates a new mediation interstitial.
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
@property (nonatomic, weak, nullable) id<MAAdDelegate> delegate;

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
 * Load the ad for the current interstitial. Set @code -[MAInterstitialAd delegate] @endcode to assign a delegate that should be notified about ad load state.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/interstitials#loading-an-interstitial-ad">MAX Integration Guide ⇒ iOs ⇒ Interstitials ⇒ Loading an Interstitial Ad</a>
 */
- (void)loadAd;

/**
 * Show the loaded interstitial ad.
 * <ul>
 * <li>Use @code -[MAInterstitialAd delegate] @endcode to assign a delegate that should be notified about display events.</li>
 * <li>Use @code -[MAInterstitialAd ready] @endcode to check if an ad was successfully loaded.</li>
 * </ul>
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/interstitials#showing-an-interstitial-ad">MAX Integration Guide ⇒ iOs ⇒ Interstitials ⇒ Showing an Interstitial Ad</a>
 */
- (void)showAd;

/**
 * Show the loaded interstitial ad for a given placement to tie ad events to.
 * <ul>
 * <li>Use @code -[MAInterstitialAd delegate] @endcode to assign a delegate that should be notified about display events.</li>
 * <li>Use @code -[MAInterstitialAd ready] @endcode to check if an ad was successfully loaded.</li>
 * </ul>
 *
 * @param placement The placement to tie the showing ad’s events to.
 */
- (void)showAdForPlacement:(nullable NSString *)placement;

/**
 * Show the loaded interstitial ad for a given placement and custom data to tie ad events to.
 * <ul>
 * <li>Use @code -[MAInterstitialAd delegate] @endcode to assign a delegate that should be notified about display events.</li>
 * <li>Use @code -[MAInterstitialAd ready] @endcode to check if an ad was successfully loaded.</li>
 * </ul>
 *
 * @param placement The placement to tie the showing ad’s events to.
 * @param customData The custom data to tie the showing ad’s events to. Maximum size is 8KB.
 */
- (void)showAdForPlacement:(nullable NSString *)placement customData:(nullable NSString *)customData;

/**
 * Show the loaded interstitial ad for a given placement and custom data to tie ad events to, and a view controller to present the ad from.
 * <ul>
 * <li>Use @code -[MAInterstitialAd delegate] @endcode to assign a delegate that should be notified about display events.</li>
 * <li>Use @code -[MAInterstitialAd ready] @endcode to check if an ad was successfully loaded.</li>
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
 * The ad unit identifier this @c MAInterstitialAd was initialized with and is loading ads for.
 */
@property (nonatomic, copy, readonly) NSString *adUnitIdentifier;

/**
 * Whether or not this ad is ready to be shown.
 */
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;

/**
 * Sets an extra key/value parameter for the ad.
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
