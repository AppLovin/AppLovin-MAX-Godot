//
//  MAAppOpenAdapterDelegate.h
//  AppLovinSDK
//
//  Created by Andrew Tian on 7/26/22.
//

#import <AppLovinSDK/MAAdapterDelegate.h>

@class MAAdapterError;

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol for adapters to forward ad load and display events to the MAX SDK for app open ads.
 */
@protocol MAAppOpenAdapterDelegate <MAAdapterDelegate>

/**
 * This method should called when an ad has been loaded.
 */
- (void)didLoadAppOpenAd;

/**
 * This method should called when an ad has been loaded.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didLoadAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when an ad could not be loaded.
 *
 * @param adapterError An error object that indicates the cause of ad failure.
 */
- (void)didFailToLoadAppOpenAdWithError:(MAAdapterError *)adapterError;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 */
- (void)didDisplayAppOpenAd;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didDisplayAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when the user has clicked adapter's ad.
 */
- (void)didClickAppOpenAd;

/**
 * This method should be called when the user has clicked adapter's ad.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didClickAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when adapter's ad has been dismissed.
 */
- (void)didHideAppOpenAd;

/**
 * This method should be called when adapter's ad has been dismissed.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didHideAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when an ad could not be displayed.
 *
 * @param adapterError An error object that indicates the cause of the failure.
 */
- (void)didFailToDisplayAppOpenAdWithError:(MAAdapterError *)adapterError;

/**
 * This method should be called when an ad could not be displayed.
 *
 * @param adapterError An error object that indicates the cause of the failure.
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didFailToDisplayAppOpenAdWithError:(MAAdapterError *)adapterError extraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

@end

NS_ASSUME_NONNULL_END
