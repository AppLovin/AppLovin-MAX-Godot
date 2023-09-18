//
//  MAAdExpirationDelegate.h
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 8/7/23.
//

@class MAAd;

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines a delegate to be notified about ad expiration events.
 */
@protocol MAAdExpirationDelegate <NSObject>

/**
 * The SDK invokes this callback when a new ad has reloaded after expiration.
 *
 * The SDK invokes this callback on the UI thread.
 *
 * @note @c didLoadAd: is not invoked for a successfully reloaded ad.
 *
 * @param expiredAd The previously expired ad.
 * @param newAd     The newly reloaded ad.
 */
- (void)didReloadExpiredAd:(MAAd *)expiredAd withNewAd:(MAAd *)newAd;

@end

NS_ASSUME_NONNULL_END
