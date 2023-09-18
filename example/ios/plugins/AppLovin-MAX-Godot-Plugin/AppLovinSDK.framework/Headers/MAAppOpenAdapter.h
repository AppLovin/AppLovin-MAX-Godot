//
//  MAAppOpenAdapter.h
//  AppLovinSDK
//
//  Created by Andrew Tian on 7/26/22.
//

#import <AppLovinSDK/MAAdapter.h>
#import <AppLovinSDK/MAAdapterResponseParameters.h>
#import <AppLovinSDK/MAAppOpenAdapterDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines methods for app open ad adapters.
 */
@protocol MAAppOpenAdapter <MAAdapter>

/**
 * Load an app open ad.
 *
 * This is called once per adapter.
 *
 * @param parameters Parameters used to load the ad.
 * @param delegate   Delegate to be notified about ad events.
 */
- (void)loadAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegate>)delegate;

/**
 * Show the pre-loaded app open ad.
 *
 * This is called once per adapter.
 *
 * @param parameters Parameters used to show the ad.
 * @param delegate   Delegate to be notified about ad events.
 */
- (void)showAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
