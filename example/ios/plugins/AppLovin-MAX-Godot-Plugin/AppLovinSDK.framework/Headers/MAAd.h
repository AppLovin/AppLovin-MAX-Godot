//
//  MAAd.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

@class MAAdFormat;
@class MAAdWaterfallInfo;
@class MANativeAd;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents an ad that has been served by AppLovin MAX.
 */
@interface MAAd : NSObject

/**
 * The format of this ad.
 */
@property (nonatomic, strong, readonly) MAAdFormat *format;

/**
 * The size of the AdView format ad, or @c CGSizeZero otherwise.
 */
@property (nonatomic, assign, readonly) CGSize size;

/**
 * The ad unit ID for which this ad was loaded.
 */
@property (nonatomic, copy, readonly) NSString *adUnitIdentifier;

/**
 * The ad network from which this ad was loaded.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/testing-networks/creative-debugger#network-name">MAX Integration Guide ⇒ iOS ⇒ Testing Networks ⇒ Creative Debugger ⇒ Network Name</a>
 */
@property (nonatomic, copy, readonly) NSString *networkName;

/**
 * The ad network placement for which this ad was loaded.
 */
@property (nonatomic, copy, readonly) NSString *networkPlacement;

/**
 * The creative id tied to the ad, if any. You can report creative issues to the corresponding ad network using this id.
 *
 * It may not be available until @c -[MAAdDelegate didDisplayAd:] is called.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/testing-networks/creative-debugger#creative-id">MAX Integration Guide ⇒ iOS ⇒ Testing Networks ⇒ Creative Debugger ⇒ Creative ID</a>
 *
 * @since 6.15.0
 */
@property (nonatomic, copy, readonly, nullable) NSString *creativeIdentifier;

/**
 * The Ad Review creative id tied to the ad, if any. You can report creative issues to our Ad review team using this id.
 *
 * It may not be available until @c -[MAAdDelegate didDisplayAd:] is called.
 *
 * @since 11.3.0
 */
@property (nonatomic, copy, readonly, nullable) NSString *adReviewCreativeIdentifier;

/**
 * The ad’s revenue amount. In the case where no revenue amount exists, or it is not available yet, will return a value of 0.
 */
@property (nonatomic, assign, readonly) double revenue;

/**
 * The precision of the revenue value for this ad.
 *
 * Possible values are:
 * - "publisher_defined" - If the revenue is the price assigned to the line item by the publisher.
 * - "exact" - If the revenue is the resulting price of a real-time auction.
 * - "estimated" - If the revenue is the price obtained by auto-CPM.
 * - "undefined" - If we do not have permission from the ad network to share impression-level data.
 * - "" - An empty string, if revenue and precision are not valid (for example, in test mode).
 */
@property (nonatomic, copy, readonly) NSString *revenuePrecision;

/**
 * The placement name that you assign when you integrate each ad format, for granular reporting in postbacks (e.g. "Rewarded_Store", "Rewarded_LevelEnd").
 */
@property (atomic, copy, readonly, nullable) NSString *placement;

/**
 * The underlying waterfall of ad responses.
 */
@property (nonatomic, strong, readonly) MAAdWaterfallInfo *waterfall;

/**
 * The latency of the mediation ad load request in seconds.
 */
@property (nonatomic, assign, readonly) NSTimeInterval requestLatency;

/**
 * For Native ads only. Get an instance of the @c MANativeAd containing the assets used to render the native ad view.
 */
@property (nonatomic, strong, readonly, nullable) MANativeAd *nativeAd;

/**
 * The DSP network that provided the loaded ad when the ad is served through AppLovin Exchange.
 */
@property (nonatomic, copy, readonly, nullable) NSString *DSPName;

/**
 * The DSP id network that provided the loaded ad when the ad is served through AppLovin Exchange.
 */
@property (nonatomic, copy, readonly, nullable) NSString *DSPIdentifier;

/**
 * Gets the ad value for a given key.
 *
 * @param key The key for the value you want to retrieve.
 *
 * @return The ad value corresponding to @c key, or @c nil if no value for that key exists.
 */
- (nullable NSString *)adValueForKey:(NSString *)key;

/**
 * Gets the ad value for a given key.
 *
 * @param key                     The key for the value you want to retrieve.
 * @param defaultValue The default value to return if the value for @c key does not exist or is @c nil.
 *
 * @return The ad value corresponding to @c key, or the default value if no value for that key exists.
 */
- (nullable NSString *)adValueForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
