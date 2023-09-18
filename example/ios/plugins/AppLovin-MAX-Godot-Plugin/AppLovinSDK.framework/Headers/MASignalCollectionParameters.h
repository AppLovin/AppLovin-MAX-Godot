//
//  MASignalCollectionParameters.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/27/18.
//

#import <AppLovinSDK/MAAdapterParameters.h>

@class MAAdFormat;

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol contains parameters passed to a mediation adapter to load the signal.
 */
@protocol MASignalCollectionParameters <MAAdapterParameters>

/**
 * The ad format we are currently collecting the signal for.
 */
@property (nonatomic, strong, readonly) MAAdFormat *adFormat;

@end

NS_ASSUME_NONNULL_END
