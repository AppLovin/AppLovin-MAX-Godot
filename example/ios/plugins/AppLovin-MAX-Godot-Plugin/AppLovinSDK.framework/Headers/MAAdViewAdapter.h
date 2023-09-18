//
//  MAAdViewAdapter.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/MAAdapter.h>
#import <AppLovinSDK/MAAdapterResponseParameters.h>
#import <AppLovinSDK/MAAdViewAdapterDelegate.h>

@class MAAdFormat;

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines methods for ad view-based adapters (banners, mrecs, and leaders).
 */
@protocol MAAdViewAdapter <MAAdapter>

/**
 * Schedule loading of the next ad view ad.
 *
 * This is called once per adapter.
 *
 * @param parameters Parameters used to load the ads.
 * @param adFormat   Format of the ad to load.
 * @param delegate   Delegate to be notified about ad events.
 */
- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
