//
//  MASignalCollectionDelegate.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/27/18.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol for adapters to forward signal collection events to the MAX SDK.
 */
@protocol MASignalCollectionDelegate <NSObject>

/**
 * This method must be called when signal collection has completed.
 */
- (void)didCollectSignal:(nullable NSString *)signal;

/**
 * This method should be called when signal collection has failed.
 */
- (void)didFailToCollectSignalWithErrorMessage:(nullable NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
