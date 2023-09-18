//
//  MARewardedAdapterDelegate.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/MAAdapterDelegate.h>

@class MAAdapterError;
@class MAReward;

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol for adapters to forward ad load and display events to the MAX SDK for rewarded ads.
 */
@protocol MARewardedAdapterDelegate <MAAdapterDelegate>

/**
 * This method should called when an ad has been loaded.
 */
- (void)didLoadRewardedAd;

/**
 * This method should called when an ad has been loaded.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didLoadRewardedAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when an ad could not be loaded.
 *
 * @param adapterError An error that indicates the cause of the failure.
 */
- (void)didFailToLoadRewardedAdWithError:(MAAdapterError *)adapterError;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 */
- (void)didDisplayRewardedAd;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didDisplayRewardedAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method is should be called when an ad could not be displayed.
 *
 * @param adapterError An error that indicates the cause of the failure
 */
- (void)didFailToDisplayRewardedAdWithError:(MAAdapterError *)adapterError;

/**
 * This method is should be called when an ad could not be displayed.
 *
 * @param adapterError An error that indicates the cause of the failure
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didFailToDisplayRewardedAdWithError:(MAAdapterError *)adapterError extraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when the user has clicked adapter's ad.
 */
- (void)didClickRewardedAd;

/**
 * This method should be called when the user has clicked adapter's ad.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didClickRewardedAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when adapter's ad has been dismissed.
 */
- (void)didHideRewardedAd;

/**
 * This method should be called when adapter's ad has been dismissed.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didHideRewardedAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be invoked when rewarded video has started video playback.
 */
- (void)didStartRewardedAdVideo;

/**
 * This method should be invoked when rewarded video has completed video playback.
 */
- (void)didCompleteRewardedAdVideo;

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
