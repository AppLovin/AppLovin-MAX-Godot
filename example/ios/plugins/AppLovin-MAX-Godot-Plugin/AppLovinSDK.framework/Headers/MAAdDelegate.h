//
//  MAAdDelegate.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

@class MAAd;
@class MAError;

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines a listener to be notified about ad events.
 */
@protocol MAAdDelegate <NSObject>

/**
 * The SDK invokes this method when a new ad has been loaded.
 *
 * @param ad  The ad that was loaded.
 */
- (void)didLoadAd:(MAAd *)ad;

/**
 * The SDK invokes this method when an ad could not be retrieved.
 *
 * <b>Common error codes:</b><table>
 * <tr><td>204</td><td>no ad is available</td></tr>
 * <tr><td>5xx</td><td>internal server error</td></tr>
 * <tr><td>negative number</td><td>internal errors</td></tr></table>
 *
 * @param adUnitIdentifier  The ad unit ID that the SDK failed to load an ad for.
 * @param error                          An object that encapsulates the failure info.
 */
- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error;

/**
 * The SDK invokes this method when a full-screen ad is displayed.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @warning This method is deprecated for MRECs. It will only be called for full-screen ads.
 *
 * @param ad  The ad that was displayed.
 */
- (void)didDisplayAd:(MAAd *)ad;

/**
 * The SDK invokes this method when a full-screen ad is hidden.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @warning This method is deprecated for MRECs. It will only be called for full-screen ads.
 *
 * @param ad  The ad that was hidden.
 */
- (void)didHideAd:(MAAd *)ad;

/**
 * The SDK invokes this method when the ad is clicked.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The ad that was clicked.
 */
- (void)didClickAd:(MAAd *)ad;

/**
 * The SDK invokes this method when the ad failed to display.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad       The ad that the SDK failed to display for.
 * @param error An object that encapsulates the failure info.
 */
- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error;

@optional

- (void)didPayRevenueForAd:(MAAd *)ad
__deprecated_msg("This callback has been deprecated and will be removed in a future SDK version. Please use -[MAAdRevenueDelegate didPayRevenueForAd:] instead.");
- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode
__deprecated_msg("This callback has been deprecated and will be removed in a future SDK version. Please use -[MAAdDelegate didFailToLoadAdForAdUnitIdentifier:withError:] instead.");
- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode
__deprecated_msg("This callback has been deprecated and will be removed in a future SDK version. Please use -[MAAdDelegate didFailToDisplayAd:withError:] instead.");

@end

NS_ASSUME_NONNULL_END
