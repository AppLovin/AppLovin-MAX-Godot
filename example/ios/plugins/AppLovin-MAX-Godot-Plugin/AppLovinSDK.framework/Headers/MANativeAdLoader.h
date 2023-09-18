//
//  MANativeAdLoader.h
//  AppLovinSDK
//
//  Created by Andrew Tian on 7/14/21.
//

#import <AppLovinSDK/MAAdRevenueDelegate.h>
#import <AppLovinSDK/MAAdReviewDelegate.h>
#import <AppLovinSDK/MANativeAdDelegate.h>

@class ALSdk;
@class MAAd;
@class MANativeAdView;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents a loader for native ads.
 */
@interface MANativeAdLoader : NSObject

/**
 * Creates a new MAX native ad loader.
 *
 * @param adUnitIdentifier Ad unit ID to load ads for.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier;

/**
 * Creates a new MAX native ad loader.
 *
 * @param adUnitIdentifier Ad unit ID to load ads for.
 * @param sdk              SDK to use. You can obtain an instance of the SDK by calling @code +[ALSdk shared] @endcode.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier sdk:(ALSdk *)sdk;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * A delegate that will be notified about native ad events.
 */
@property (nonatomic, weak, nullable) id<MANativeAdDelegate> nativeAdDelegate;

/**
 * A delegate that will be notified about ad revenue events.
 */
@property (nonatomic, weak, nullable) id<MAAdRevenueDelegate> revenueDelegate;

/**
 * A delegate that will be notified about Ad Review events.
 */
@property (nonatomic, weak, nullable) id<MAAdReviewDelegate> adReviewDelegate;

/**
 * Load a new MAX native ad. Set @code -[MANativeAdLoader nativeAdDelegate] @endcode to assign a delegate that should be notified about ad load state.
 */
- (void)loadAd;

/**
 * Load a new MAX native ad into the given native ad view. Set @code -[MANativeAdLoader nativeAdDelegate] @endcode to assign a delegate that should be notified about ad load state.
 *
 * @param adView a @c MANativeAdView into which the loaded native ad will be rendered.
 */
- (void)loadAdIntoAdView:(nullable MANativeAdView *)adView;

/**
 * Renders the given ad into the given ad view.
 *
 * Note: Make sure to only render the ad separately if the native ad view returned in our @code -[MANativeAdDelegate didLoadNativeAd:forAd:] @endcode is @c nil.
 *
 * @param adView The ad view into which to render the native ad.
 * @param ad     The ad to be rendered.
 *
 * @return @c YES if the ad view was rendered successfully.
 */
- (BOOL)renderNativeAdView:(MANativeAdView *)adView withAd:(MAAd *)ad;

/**
 * The placement name that you assign when you integrate each ad format, for granular reporting in ad events (e.g. "Rewarded_Store", "Rewarded_LevelEnd").
 */
@property (nonatomic, copy, nullable) NSString *placement;

/**
 * The ad unit identifier this @c MANativeAdLoader was initialized with and is loading ads for.
 */
@property (nonatomic, copy, readonly) NSString *adUnitIdentifier;

/**
 * Destroy the native ad and fully remove it from memory.
 */
- (void)destroyAd:(MAAd *)nativeAd;

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

/**
 * The custom data to tie the showing ad to, for ILRD and rewarded postbacks via the @c {CUSTOM_DATA}  macro. Maximum size is 8KB.
 */
@property (nonatomic, copy, nullable) NSString *customData;

@end

NS_ASSUME_NONNULL_END
