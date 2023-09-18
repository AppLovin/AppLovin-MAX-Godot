//
//  MARewardedInterstitialAdapter.h
//  AppLovinSDK
//
//  Created by Thomas So on 6/3/20.
//

#import <AppLovinSDK/MAAdapter.h>
#import <AppLovinSDK/MAAdapterResponseParameters.h>
#import <AppLovinSDK/MARewardedInterstitialAdapterDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This interface defines methods for rewarded interstitial adapters.
 */
@protocol MARewardedInterstitialAdapter <MAAdapter>

/**
 * Load a rewarded interstitial ad.
 *
 * This is called once per adapter.
 *
 * @param parameters Parameters that should be used for this current ad load.
 * @param delegate   Delegate to be notified about rewarded ad events.
 */
- (void)loadRewardedInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedInterstitialAdapterDelegate>)delegate;

/**
 * Show the pre-loaded rewarded interstitial ad.
 *
 * This is called once per adapter.
 *
 * @param parameters Parameters used to show the ad.
 * @param delegate   Delegate to be notified about rewarded ad events.
 */
- (void)showRewardedInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedInterstitialAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
