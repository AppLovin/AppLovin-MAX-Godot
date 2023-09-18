//
//  MANativeAdDelegate.h
//  AppLovinSDK
//
//  Created by Andrew Tian on 7/14/21.
//

@class MAAd;
@class MAError;
@class MANativeAdView;

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines a listener to be notified about native ad events.
 */
@protocol MANativeAdDelegate <NSObject>

/**
 * The SDK invokes this method when a new native ad has been loaded.
 *
 * @param nativeAdView The native ad view that the SDK successfully loaded.
 *                     May be @c nil if a manual native ad is loaded without a view.
 *                     You can create and render the native ad view using @code -[MANativeAdLoader renderNativeAdView:withAd:] @endcode.
 * @param ad  The ad that was loaded.
 */
- (void)didLoadNativeAd:(nullable MANativeAdView *)nativeAdView forAd:(MAAd *)ad;

/**
 * The SDK invokes this method when a native ad could not be retrieved.
 *
 * <b>Common error codes:</b><table>
 * <tr><td>204</td><td>no ad is available</td></tr>
 * <tr><td>5xx</td><td>internal server error</td></tr>
 * <tr><td>negative number</td><td>internal errors</td></tr></table>
 *
 * @param adUnitIdentifier  The ad unit ID that the SDK failed to load an ad for.
 * @param error                          An object that encapsulates the failure info.
 */
- (void)didFailToLoadNativeAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error;

/**
 * The SDK invokes this method when the native ad is clicked.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The ad that was clicked.
 */
- (void)didClickNativeAd:(MAAd *)ad;

@optional

/**
 * The SDK invokes this method when the native ad expires.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  The ad that expired.
 */
- (void)didExpireNativeAd:(MAAd *)ad;

@end

NS_ASSUME_NONNULL_END
