//
//  MAAdapter.h
//  AppLovinSDK
//
//  Created by Thomas So on 8/10/18.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/MAAdapterInitializationParameters.h>
#import <AppLovinSDK/MAAdFormat.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * An enum describing the adapter's initialization status.
 */
typedef NS_ENUM(NSInteger, MAAdapterInitializationStatus)
{
    /**
     * The adapter is not initialized. Note: networks need to be enabled for an ad unit id to be initialized.
     */
    MAAdapterInitializationStatusAdapterNotInitialized = -4,
    
    /**
     * The 3rd-party SDK does not have an initialization callback with status.
     */
    MAAdapterInitializationStatusDoesNotApply = -3,
    
    /**
     * The 3rd-party SDK is currently initializing.
     */
    MAAdapterInitializationStatusInitializing = -2,
    
    /**
     * The 3rd-party SDK explicitly initialized, but without a status.
     */
    MAAdapterInitializationStatusInitializedUnknown = -1,
    
    /**
     * The 3rd-party SDK initialization failed.
     */
    MAAdapterInitializationStatusInitializedFailure = 0,
    
    /**
     * The 3rd-party SDK initialization was successful.
     */
    MAAdapterInitializationStatusInitializedSuccess = 1
};

/**
 * This protocol defines a mediation adapter which wraps a third-party ad SDK and will be used by AppLovin to load and display ads.
 */
@protocol MAAdapter <NSObject>

/**
 * Initialize current adapter. This method will be called at the beginning of the adapter lifecycle.
 *
 * @param parameters        Parameters passed from the server.
 * @param completionHandler Completion block to be called when the 3rd-party SDK finishes initialization, whether or not it was successful.
 */
- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters withCompletionHandler:(void(^)(void))completionHandler;

/**
 * The version of the third-party SDK.
 */
@property (nonatomic, copy, readonly) NSString *SDKVersion;

/**
 * The version of this adapter.
 */
@property (nonatomic, copy, readonly) NSString *adapterVersion;

/**
 * Whether or not this adapter is a beta version.
 */
@property (nonatomic, assign, readonly, getter=isBeta) BOOL beta;

/**
 * *********************
 * AVAILABLE IN v11.9.0+
 * *********************
 * <p>
 * Whether or not to initialize the third-party SDK on main thread.
 *
 * @return @c 1 if the SDK should be initialized on main thread. @c nil if we should fallback to using the adapter spec level setting.
 */
- (nullable NSNumber *)shouldInitializeOnMainThread;

/**
 * *********************
 * AVAILABLE IN v11.9.0+
 * *********************
 * <p>
 * Whether or not to collect signals on main thread.
 *
 * @return @c 1 if the SDK should collect signals on main thread. @c nil if we should fallback to using the adapter spec level setting.
 */
- (nullable NSNumber *)shouldCollectSignalsOnMainThread;

/**
 * *********************
 * AVAILABLE IN v11.9.0+
 * *********************
 * <p>
 * Whether or not to load ads on main thread.
 *
 * @param adFormat The @c MAAdFormat for which to check if we should load on main thread.
 *
 * @return @c 1 if the given ad format should be loaded on main thread. @c nil if we should fallback to using the adapter spec level setting.
 */
- (nullable NSNumber *)shouldLoadAdsOnMainThreadForAdFormat:(MAAdFormat *)adFormat;

/**
 * *********************
 * AVAILABLE IN v11.9.0+
 * *********************
 * <p> 
 * Whether or not to show ads on main thread.
 *
 * @param adFormat The @c MAAdFormat for which to check if we should show on main thread.
 *
 * @return @c 1 if the given ad format should be loaded on main thread. @c nil if we should fallback to using the adapter spec level setting.
 */
- (nullable NSNumber *)shouldShowAdsOnMainThreadForAdFormat:(MAAdFormat *)adFormat;

/**
 * This method is called when an ad associated with this adapter should be destroyed. Necessary cleanup should be performed here.
 */
- (void)destroy;

@optional

/**
 * Initialize current adapter. This method will be called at the beginning of the adapter lifecycle.
 *
 * @param parameters        Parameters passed from the server.
 * @param completionHandler Completion block to be called when the 3rd-party SDK finishes initialization, with the initialization status passed in.
 */
- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void(^)(MAAdapterInitializationStatus initializationStatus, NSString *_Nullable errorMessage))completionHandler;

@end

NS_ASSUME_NONNULL_END
