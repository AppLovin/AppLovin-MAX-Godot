//
//  MASignalProvider.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/MASignalCollectionDelegate.h>
#import <AppLovinSDK/MASignalCollectionParameters.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol describes a mediation adapter that provides bid signals.
 */
@protocol MASignalProvider <NSObject>

/**
 * Retrieve the signal that should be passed up to the server.
 *
 * @param parameters Parameters that should be used to retrieve the signal.
 * @param delegate   Delegate that must be notified when signal collection has completed (or failed).
 */
- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
