//
//  MARewardedAdapter.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/MAAdapter.h>
#import <AppLovinSDK/MAAdapterResponseParameters.h>
#import <AppLovinSDK/MARewardedAdapterDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines methods for rewarded (incentivized) adapters.
 */
@protocol MARewardedAdapter <MAAdapter>

/**
 * Load a rewarded ad.
 *
 * This is called once per adapter.
 *
 * @param parameters Parameters that should be used for this current ad load.
 * @param delegate   Delegate to be notified about rewarded ad events.
 */
- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate;

/**
 * Show the pre-loaded rewarded ad.
 *
 * This is called once per adapter.
 *
 * @param parameters Parameters used to show the ad.
 * @param delegate   Delegate to be notified about rewarded ad events.
 */
- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
