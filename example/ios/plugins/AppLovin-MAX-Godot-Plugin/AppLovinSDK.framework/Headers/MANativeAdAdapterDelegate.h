//
//  MANativeAdAdapterDelegate.h
//  AppLovinSDK
//
//  Created by Thomas So on 6/15/21.
//

#import <AppLovinSDK/MAAdapterDelegate.h>

@class MAAdapterError;
@class MANativeAd;

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol for adapters to forward ad load and display events to the MAX SDK for native ads.
 */
@protocol MANativeAdAdapterDelegate <MAAdapterDelegate>

/**
 * This method should called when an ad has been loaded.
 *
 * @param nativeAd Native ad container containing the assets from the mediated network's native ad.
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didLoadAdForNativeAd:(MANativeAd *)nativeAd withExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when an ad could not be loaded.
 *
 * @param adapterError An error object that indicates the cause of ad failure.
 */
- (void)didFailToLoadNativeAdWithError:(MAAdapterError *)adapterError;

/**
 * This method should be called when the adapter has successfully displayed an ad to the user.
 * Note: Display callbacks are not forwarded to the publisher, however revenue events that are associated with the display event are.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didDisplayNativeAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

/**
 * This method should be called when the user has clicked adapter's ad.
 */
- (void)didClickNativeAd;

/**
 * This method should be called when the user has clicked adapter's ad.
 *
 * @param extraInfo Extra info passed from the adapter.
 */
- (void)didClickNativeAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;

@end

NS_ASSUME_NONNULL_END
