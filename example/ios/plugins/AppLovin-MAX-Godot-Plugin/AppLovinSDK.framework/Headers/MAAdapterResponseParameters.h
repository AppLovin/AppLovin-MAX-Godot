//
//  MAAdapterResponseParameters.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/27/18.
//

#import <AppLovinSDK/MAAdapterParameters.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol contains parameters passed to a mediation adapter to load the next ad.
 */
@protocol MAAdapterResponseParameters <MAAdapterParameters>

/**
 * Get zone ID / placement ID / ad unit ID for the adapter to use. This is different than {@link MAAd#adUnitIdentifier}, which is used by AppLovin's SDK specifically.
 */
@property (nonatomic, copy, readonly) NSString *thirdPartyAdPlacementIdentifier;

/**
 * For header bidding only: server bid response that was sent from third-party servers to the respective SDK.
 */
@property (nonatomic, copy, readonly) NSString *bidResponse;

/**
 * For header bidding only: server bid expiration time.
 *
 * @return Expiration time for the bidding server response. -1 is default meaning the bid never expires.
 */
@property (nonatomic, assign, readonly) long long /*ALTimeIntervalMillis*/ bidExpirationMillis;

@end

NS_ASSUME_NONNULL_END
