//
//  MAInterstitialAdapter.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/MAAdapter.h>
#import <AppLovinSDK/MAAdapterResponseParameters.h>
#import <AppLovinSDK/MAInterstitialAdapterDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines methods for interstitial adapters.
 */
@protocol MAInterstitialAdapter <MAAdapter>

/**
 * Load a interstitial ad.
 *
 * This is called once per adapter.
 *
 * @param parameters Parameters used to load the ad.
 * @param delegate   Delegate to be notified about ad events.
 */
- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate;

/**
 * Show the pre-loaded interstitial.
 *
 * This is called once per adapter.
 *
 * @param parameters Parameters used to show the ad.
 * @param delegate   Delegate to be notified about ad events.
 */
- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
