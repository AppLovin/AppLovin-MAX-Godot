//
//  ALIncentivizedInterstitialAd.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/ALAdDisplayDelegate.h>
#import <AppLovinSDK/ALAdLoadDelegate.h>
#import <AppLovinSDK/ALAdRewardDelegate.h>
#import <AppLovinSDK/ALAdVideoPlaybackDelegate.h>

@class ALAd;
@class ALSdk;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class shows rewarded videos to the user. These differ from regular interstitials in that they allow you to provide your user virtual currency in
 * exchange for watching a video.
 */
@interface ALIncentivizedInterstitialAd : NSObject
    
#pragma mark - Ad Delegates
    
/**
 * An object that conforms to the @c ALAdDisplayDelegate protocol. If you provide a value for @c adDisplayDelegate in your instance, the SDK will
 * notify this delegate of ad show/hide events.
 */
@property (nonatomic, strong, nullable) id<ALAdDisplayDelegate> adDisplayDelegate;

/**
 * An object that conforms to the @c ALAdVideoPlaybackDelegate protocol. If you provide a value for @c adVideoPlaybackDelegate in your instance,
 * the SDK will notify this delegate of video start/stop events.
 */
@property (nonatomic, strong, nullable) id<ALAdVideoPlaybackDelegate> adVideoPlaybackDelegate;

#pragma mark - Integration, Class Methods

/**
 * Gets a reference to the shared instance of @c [ALIncentivizedInterstitialAd].
 *
 * This wraps the @code +[ALSdk shared] @endcode call, and will only work if you have set your SDK key in @code Info.plist @endcode.
 */
+ (ALIncentivizedInterstitialAd *)shared;

/**
 * Pre-loads an incentivized interstitial, and notifies your provided Ad Load Delegate.
 *
 * Invoke this once to pre-load, then do not invoke it again until the ad has has been closed (e.g., in the
 * @code -[ALAdDisplayDelegate ad:wasHiddenIn:] @endcode callback).
 *
 * @warning You may pass a @c nil argument to @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode if you intend to use the synchronous
 *          (@code +[ALIncentivizedIntrstitialAd isReadyForDisplay] @endcode) flow. This is <em>not</em> recommended; AppLovin <em>highly recommends</em> that
 *          you use an ad load delegate.
 *
 * This method uses the shared instance, and will only work if you have set your SDK key in @code Info.plist @endcode.
 *
 * Note that AppLovin tries to pull down the next ad’s resources before you need it. Therefore, this method may complete immediately in many circumstances.
 *
 * @param adLoadDelegate The delegate to notify that preloading was completed. May be @c nil (see warning).
 */
+ (void)preloadAndNotify:(nullable id<ALAdLoadDelegate>)adLoadDelegate;

/**
 * Whether or not an ad is currently ready on this object. You must first have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode in order
 * for this value to be meaningful.
 *
 * @warning It is highly recommended that you implement an asynchronous flow (using an @c ALAdLoadDelegate with
 *          @code -[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode) rather than checking this property. This class does not contain a queue and can
 *          hold only one preloaded ad at a time. Therefore, you should <em>not</em> simply call
 *          @code -[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode) any time this method returns @c NO; it is important to invoke only one ad load —
 *          then not invoke any further loads until the ad has been closed (e.g., in the @code -[ALAdDisplayDelegate ad:wasHiddenIn:] @endcode callback).
 *
 * @return @c YES if an ad has been loaded into this incentivized interstitial and is ready to display. @c NO otherwise.
 */
+ (BOOL)isReadyForDisplay;

/**
 * Shows an incentivized interstitial over the current key window, by using the most recently pre-loaded ad.
 *
 * You must have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode before you call @code +[ALIncentivizedInterstitialAd show] @endcode.
 */
+ (void)show;

/**
 * Shows an incentivized interstitial over the current key window, by using the most recently pre-loaded ad.
 *
 * You must have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode before you call @c showAndNotify.
 *
 * By using the @c ALAdRewardDelegate, you can verify with AppLovin servers that the video view is legitimate, as AppLovin will confirm whether
 * the specific ad was actually served. Then AppLovin will ping your server with a URL at which you can update the user’s balance. The Reward Validation
 * Delegate will tell you whether this service was able to reach AppLovin servers or not. If you receive a successful response, you should refresh the user’s
 * balance from your server. For more info, see the documentation.
 *
 * @param adRewardDelegate The reward delegate to notify upon validating reward authenticity with AppLovin.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api">MAX Integration Guide ⇒ MAX S2S Rewarded Callback API</a>
 */
+ (void)showAndNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate;

#pragma mark - Integration, Instance Methods

/**
 * Initializes an incentivized interstitial with a specific custom SDK.
 *
 * This is necessary if you use @code +[ALSdk sharedWithKey:] @endcode.
 *
 * @param sdk An SDK instance to use.
 */
- (instancetype)initWithSdk:(ALSdk *)sdk;

#pragma mark - Integration, zones

/**
 * Initializes an incentivized interstitial with a zone.
 *
 * @param zoneIdentifier The identifier of the zone for which to load ads.
 */
- (instancetype)initWithZoneIdentifier:(NSString *)zoneIdentifier;

/**
 * Initializes an incentivized interstitial with a zone and a specific custom SDK.
 *
 * This is necessary if you use @code +[ALSdk sharedWithKey:] @endcode.
 *
 * @param zoneIdentifier The identifier of the zone for which to load ads.
 * @param sdk            An SDK instance to use.
 */
- (instancetype)initWithZoneIdentifier:(NSString *)zoneIdentifier sdk:(ALSdk *)sdk;

/**
 *  The zone identifier this incentivized ad was initialized with and is loading ads for, if any.
 */
@property (nonatomic, copy, readonly, nullable) NSString *zoneIdentifier;

/**
 * Pre-loads an incentivized interstitial, and notifies your provided Ad Load Delegate.
 *
 * Invoke this once to pre-load, then do not invoke it again until the ad has has been closed (e.g., in the
 * @code -[ALAdDisplayDelegate ad:wasHiddenIn:] @endcode callback).
 *
 * @warning You may pass a @c nil argument to @c preloadAndNotify if you intend to use the synchronous
 *          (@code +[ALIncentivizedIntrstitialAd isReadyForDisplay] @endcode) flow. This is <em>not</em> recommended; AppLovin <em>highly recommends</em> that
 *          you use an ad load delegate.
 *
 * Note that AppLovin tries to pull down the next ad’s resources before you need it. Therefore, this method may complete immediately in many circumstances.
 *
 * @param adLoadDelegate The delegate to notify that preloading was completed. May be @c nil (see warning).
 */
- (void)preloadAndNotify:(nullable id<ALAdLoadDelegate>)adLoadDelegate;

/**
 * Whether or not an ad is currently ready on this object. You must first have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode in order
 * for this value to be meaningful.
 *
 * @warning It is highly recommended that you implement an asynchronous flow (using an @c ALAdLoadDelegate with
 *          @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode rather than checking this property. This class does not contain a queue and can
 *          hold only one preloaded ad at a time. Therefore, you should <em>not</em> simply call
 *          @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode any time this method returns @c NO; it is important to invoke only one ad load —
 *          then not invoke any further loads until the ad has been closed (e.g., in the @code -[ALAdDisplayDelegate ad:wasHiddenIn:] @endcode callback).
 *
 * @return @c YES if an ad has been loaded into this incentivized interstitial and is ready to display. @c NO otherwise.
 */
@property (atomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;

/**
 * Shows an incentivized interstitial over the current key window, by using the most recently pre-loaded ad.
 *
 * You must have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode before you call @c show.
 */
- (void)show;

/**
 * Shows an incentivized interstitial over the current key window, by using the most recently pre-loaded ad.
 *
 * You must have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode before you call @c showAndNotify.
 *
 * By using the @c ALAdRewardDelegate, you can verify with AppLovin servers that the video view is legitimate, as AppLovin will confirm whether
 * the specific ad was actually served. Then AppLovin will ping your server with a URL at which you can update the user’s balance. The Reward Validation
 * Delegate will tell you whether this service was able to reach AppLovin servers or not. If you receive a successful response, you should refresh the user’s
 * balance from your server. For more info, see the documentation.
 *
 * @param adRewardDelegate The reward delegate to notify upon validating reward authenticity with AppLovin.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api">MAX Integration Guide ⇒ MAX S2S Rewarded Callback API</a>
 */
- (void)showAndNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate;

/**
 * Shows an incentivized interstitial, by using the most recently pre-loaded ad.
 *
 * You must have called @code +[ALIncentivizedInterstitialAd preloadAndNotify:] @endcode before you call @c showAd.
 *
 * By using the @c ALAdRewardDelegate, you can verify with AppLovin servers that the video view is legitimate, as AppLovin will confirm whether
 * the specific ad was actually served. Then AppLovin will ping your server with a URL at which you can update the user’s balance. The Reward Validation
 * Delegate will tell you whether this service was able to reach AppLovin servers or not. If you receive a successful response, you should refresh the user’s
 * balance from your server. For more info, see the documentation.
 *
 * @param ad               The ad to render into this incentivized ad.
 * @param adRewardDelegate The reward delegate to notify upon validating reward authenticity with AppLovin.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/s2s-rewarded-callback-api">MAX Integration Guide ⇒ MAX S2S Rewarded Callback API</a>
 */
- (void)showAd:(ALAd *)ad andNotify:(nullable id<ALAdRewardDelegate>)adRewardDelegate;

/**
 * Sets extra info to pass to the SDK.
 *
 * @param key   Parameter key.
 * @param value Parameter value.
 */
- (void)setExtraInfoForKey:(NSString *)key value:(nullable id)value;

- (instancetype)init __attribute__((unavailable("Use initWithSdk:, initWithZoneIdentifier:, or [ALIncentivizedInterstitialAd shared] instead.")));
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
