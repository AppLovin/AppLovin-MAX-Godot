//
//  MAError+Internal.h
//  AppLovinSDK
//
//  Created by Thomas So on 5/3/21.
//

#import <AppLovinSDK/MAErrorCode.h>

@class MAAdWaterfallInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class encapsulates various data for MAX load and display errors.
 */
@interface MAError : NSObject

/**
 * The error code for the error. Will be one of the codes listed under the @c MAErrorCode enum.
 */
@property (nonatomic, assign, readonly) MAErrorCode code;

/**
 * The error message for the error.
 */
@property (nonatomic, copy, readonly) NSString *message;

/**
 * The mediated network's error code for the error. Available for errors returned in @c -[MAAdDelegate didFailToDisplayAd:withError:] only.
 */
@property (nonatomic, assign, readonly) NSInteger mediatedNetworkErrorCode;

/**
 * The mediated network's error message for the error. Defaults to an empty string. Available for errors returned in @c -[MAAdDelegate didFailToDisplayAd:withError:] only.
 */
@property (nonatomic, copy, readonly) NSString *mediatedNetworkErrorMessage;

/**
 * The underlying waterfall of ad responses.
 */
@property (nonatomic, strong, readonly, nullable) MAAdWaterfallInfo *waterfall;

/**
 * The latency of the mediation ad load request in seconds.
 */
@property (nonatomic, assign, readonly) NSTimeInterval requestLatency;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@end

@interface MAError (ALDeprecated)
@property (nonatomic, assign, readonly) NSInteger errorCode __deprecated_msg("This property is deprecated and removed in a future SDK version. Please use `-[MAError code]` instead.");
@property (nonatomic, copy, readonly) NSString *errorMessage __deprecated_msg("This property is deprecated and removed in a future SDK version. Please use `-[MAError message]` instead.");
@property (nonatomic, copy, readonly, nullable) NSString *adLoadFailureInfo __deprecated_msg("The ad load failure info string is deprecated and removed in a future SDK version. Please use `-[MAError waterfall]` instead.");
@end

NS_ASSUME_NONNULL_END
