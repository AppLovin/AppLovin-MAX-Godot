//
//  MAAdRequestDelegate.h
//  AppLovinSDK
//
//  Created by Andrew Tian on 7/8/22.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines a delegate to be notified about ad request events.
 */
@protocol MAAdRequestDelegate <NSObject>

/**
 * The SDK invokes this callback when it sends a request for an ad, which can be for the initial ad load and upcoming ad refreshes.
 *
 * The SDK invokes this callback on the UI thread.
 *
 * @param adUnitIdentifier The ad unit identifier that the SDK requested an ad for.
 */
- (void)didStartAdRequestForAdUnitIdentifier:(NSString *)adUnitIdentifier;

@end

NS_ASSUME_NONNULL_END
