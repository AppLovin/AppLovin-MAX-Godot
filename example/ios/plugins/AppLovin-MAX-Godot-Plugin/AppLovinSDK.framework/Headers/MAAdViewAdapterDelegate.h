//
//  MAAdViewAdapterDelegate.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppLovinSDK/MAAdapterDelegate.h>

@class MAAdapterError;

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol for adapters to forward ad load and display events to the MAX SDK for adview ads.
 */
@protocol MAAdViewAdapterDelegate <MAAdapterDelegate>

/**
 * This method should called when an ad has been loaded.
 *
 * @param adView Ad view that contains the loaded ad.
 */
- (void)didLoadAdForAdView:(UIView *)adView;

/**
 * This method should called when an ad has been loaded.
 *
 * @param adView Ad view that contains the loaded ad.
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didLoadAdForAdView:(UIView *)adView withExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method is should be called when an ad could not be loaded.
 *
 * @param adapterError An error object that indicates the cause of ad failure.
 */
- (void)didFailToLoadAdViewAdWithError:(MAAdapterError *)adapterError;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 */
- (void)didDisplayAdViewAd;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didDisplayAdViewAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method is should be called when an ad could not be displayed.
 *
 * @param adapterError An error object that indicates the cause of the failure.
 */
- (void)didFailToDisplayAdViewAdWithError:(MAAdapterError *)adapterError;

/**
 * This method is should be called when an ad could not be displayed.
 *
 * @param adapterError An error object that indicates the cause of the failure.
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didFailToDisplayAdViewAdWithError:(MAAdapterError *)adapterError extraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when the user has clicked adapter's ad.
 */
- (void)didClickAdViewAd;

/**
 * This method should be called when the user has clicked adapter's ad.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didClickAdViewAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when adapter's ad has been dismissed.
 */
- (void)didHideAdViewAd;

/**
 * This method should be called when adapter's ad has been dismissed.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didHideAdViewAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when the ad view has expanded full screen.
 */
- (void)didExpandAdViewAd;

/**
 * This method should be called when the ad view has expanded full screen.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didExpandAdViewAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when the ad view has collapsed from its full screen state.
 */
- (void)didCollapseAdViewAd;

/**
 * This method should be called when the ad view has collapsed from its full screen state.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didCollapseAdViewAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

@end

NS_ASSUME_NONNULL_END
