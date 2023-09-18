//
//  MAInterstitialAdapterDelegate.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/MAAdapterDelegate.h>

@class MAAdapterError;

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol for adapters to forward ad load and display events to the MAX SDK for interstitial ads.
 */
@protocol MAInterstitialAdapterDelegate <MAAdapterDelegate>

/**
 * This method should called when an ad has been loaded.
 */
- (void)didLoadInterstitialAd;

/**
 * This method should called when an ad has been loaded.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didLoadInterstitialAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when an ad could not be loaded.
 *
 * @param adapterError An error object that indicates the cause of ad failure.
 */
- (void)didFailToLoadInterstitialAdWithError:(MAAdapterError *)adapterError;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 */
- (void)didDisplayInterstitialAd;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didDisplayInterstitialAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when the user has clicked adapter's ad.
 */
- (void)didClickInterstitialAd;

/**
 * This method should be called when the user has clicked adapter's ad.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didClickInterstitialAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when adapter's ad has been dismissed.
 */
- (void)didHideInterstitialAd;

/**
 * This method should be called when adapter's ad has been dismissed.
 * 
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didHideInterstitialAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method is should be called when an ad could not be displayed.
 *
 * @param adapterError An error object that indicates the cause of the failure.
 */
- (void)didFailToDisplayInterstitialAdWithError:(MAAdapterError *)adapterError;

/**
 * This method is should be called when an ad could not be displayed.
 *
 * @param adapterError An error object that indicates the cause of the failure.
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didFailToDisplayInterstitialAdWithError:(MAAdapterError *)adapterError extraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

@end

NS_ASSUME_NONNULL_END
