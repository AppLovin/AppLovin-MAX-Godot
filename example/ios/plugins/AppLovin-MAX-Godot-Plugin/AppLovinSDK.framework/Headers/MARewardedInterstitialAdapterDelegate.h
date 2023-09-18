//
//  MARewardedInterstitialAdapterDelegate.h
//  AppLovinSDK
//
//  Created by Thomas So on 6/3/20.
//

#import <AppLovinSDK/MAAdapterDelegate.h>

@class MAAdapterError;
@class MAReward;

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol for adapters to forward ad load and display events to the MAX SDK for rewarded interstitial ads.
 */
@protocol MARewardedInterstitialAdapterDelegate <MAAdapterDelegate>

/**
 * This method should called when an ad has been loaded.
 */
- (void)didLoadRewardedInterstitialAd;

/**
 * This method should called when an ad has been loaded.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didLoadRewardedInterstitialAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when an ad could not be loaded.
 *
 * @param adapterError An error that indicates the cause of the failure.
 */
- (void)didFailToLoadRewardedInterstitialAdWithError:(MAAdapterError *)adapterError;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 */
- (void)didDisplayRewardedInterstitialAd;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didDisplayRewardedInterstitialAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method is should be called when an ad could not be displayed.
 *
 * @param adapterError An error that indicates the cause of the failure.
 */
- (void)didFailToDisplayRewardedInterstitialAdWithError:(MAAdapterError *)adapterError;

/**
 * This method is should be called when an ad could not be displayed.
 *
 * @param adapterError An error that indicates the cause of the failure.
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didFailToDisplayRewardedInterstitialAdWithError:(MAAdapterError *)adapterError extraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when the user has clicked adapter's ad.
 */
- (void)didClickRewardedInterstitialAd;

/**
 * This method should be called when the user has clicked adapter's ad.
 */
- (void)didClickRewardedInterstitialAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when adapter's ad has been dismissed.
 */
- (void)didHideRewardedInterstitialAd;

/**
 * This method should be called when adapter's ad has been dismissed.
 */
- (void)didHideRewardedInterstitialAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be invoked when rewarded video has started video playback.
 */
- (void)didStartRewardedInterstitialAdVideo;

/**
 * This method should be invoked when rewarded video has completed video playback.
 */
- (void)didCompleteRewardedInterstitialAdVideo;

/**
 * This method should be invoked when a user should be granted a reward.
 *
 * @param reward The reward to be granted to the user.
 */
- (void)didRewardUserWithReward:(MAReward *)reward;

/**
 * This method should be invoked when a user should be granted a reward.
 *
 * @param reward The reward to be granted to the user.
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didRewardUserWithReward:(MAReward *)reward extraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

@end

NS_ASSUME_NONNULL_END
