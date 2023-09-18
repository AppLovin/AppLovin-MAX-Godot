//
//  MANativeAdAdapter.h
//  AppLovinSDK
//
//  Created by Thomas So on 6/16/21.
//

#import <AppLovinSDK/MAAdapter.h>
#import <AppLovinSDK/MAAdapterResponseParameters.h>
#import <AppLovinSDK/MANativeAdAdapterDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines methods for native adapters.
 */
@protocol MANativeAdAdapter <MAAdapter>

/**
 * Schedule loading of the next native ad.
 *
 * This is called once per adapter.
 *
 * @param parameters Parameters used to load the ads.
 * @param delegate   Delegate to be notified about ad events.
 */
- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
