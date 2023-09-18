//
//  MAAdapterError.h
//  AppLovinSDK
//
//  Created by Thomas So on 11/13/18.
//

#import <AppLovinSDK/MAError.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This enum contains possible error codes that should be returned by the mediation adapter.
 */
@interface MAAdapterError : MAError

/**
 * The mediation adapter can not load an ad because of no fill.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeNoFill;
@property (class, nonatomic, readonly) MAAdapterError *noFill;

/**
 * The mediation adapter failed to load an ad for an unspecified reason.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeUnspecified;
@property (class, nonatomic, readonly) MAAdapterError *unspecified;

/**
 * The mediation adapter can not load an ad because it is currently in an invalid state.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeInvalidLoadState;
@property (class, nonatomic, readonly) MAAdapterError *invalidLoadState;

/**
 * The mediation adapter can not load an ad because it is currently not configured correctly.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeInvalidConfiguration;
@property (class, nonatomic, readonly) MAAdapterError *invalidConfiguration;

/**
 * The mediation adapter can not load an ad because of a bad request.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeBadRequest;
@property (class, nonatomic, readonly) MAAdapterError *badRequest;

/**
 * The mediation adapter can not load an ad because the SDK is not initialized yet.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeNotInitialized;
@property (class, nonatomic, readonly) MAAdapterError *notInitialized;

/**
 * The mediation adapter can not load an ad because of a timeout.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeTimeout;
@property (class, nonatomic, readonly) MAAdapterError *timeout;

/**
 * The mediation adapter can not load an ad because it can not detect an active internet connection.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeNoConnection;
@property (class, nonatomic, readonly) MAAdapterError *noConnection;

/**
 * The mediation adapter did not have an ad ready in time for showing.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeAdNotReady;
@property (class, nonatomic, readonly) MAAdapterError *adNotReady;

/**
 * The mediation adapter ran into a remote server error.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeServerError;
@property (class, nonatomic, readonly) MAAdapterError *serverError;

/**
 * The mediation adapter ran into an unspecified internal error.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeInternalError;
@property (class, nonatomic, readonly) MAAdapterError *internalError;

/**
 * The mediation adapter has timed out while collecting a signal.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeSignalCollectionTimeout;
@property (class, nonatomic, readonly) MAAdapterError *signalCollectionTimeout;

/**
 * The mediation adapter does not support signal collection.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeSignalCollectionNotSupported;
@property (class, nonatomic, readonly) MAAdapterError *signalCollectionNotSupported;

/**
 * The mediation adapter ran into a WebView-related error.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeWebViewError;
@property (class, nonatomic, readonly) MAAdapterError *webViewError;

/**
 * The mediation adapter ran into an expired ad.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeAdExpired;
@property (class, nonatomic, readonly) MAAdapterError *adExpiredError;

/**
 * The mediation ad frequency capped.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeAdFrequencyCapped;
@property (class, nonatomic, readonly) MAAdapterError *adFrequencyCappedError;

/**
 * The mediation adapter ran into an error while displaying rewarded ad.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeRewardError;
@property (class, nonatomic, readonly) MAAdapterError *rewardError;

/**
 * The mediation adapter failed to load a native ad because of missing required assets.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeMissingRequiredNativeAdAssets;
@property (class, nonatomic, readonly) MAAdapterError *missingRequiredNativeAdAssets;

/**
 * The mediation ad failed to load because an Activity context was required, but missing.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeMissingViewController;
@property (class, nonatomic, readonly) MAAdapterError *missingViewController;

/*
 * The mediation adapter failed to display the ad.
 */
@property (class, nonatomic, readonly) NSInteger errorCodeAdDisplayFailedError;
@property (class, nonatomic, readonly) MAAdapterError *adDisplayFailedError;

+ (instancetype)errorWithCode:(NSInteger)code;
+ (instancetype)errorWithCode:(NSInteger)code errorString:(NSString *)errorString;
+ (instancetype)errorWithNSError:(NSError *)error;
+ (instancetype)errorWithAdapterError:(MAAdapterError *)error
             mediatedNetworkErrorCode:(NSInteger)mediatedNetworkErrorCode
          mediatedNetworkErrorMessage:(NSString *)mediatedNetworkErrorMessage;
+ (instancetype)errorWithCode:(NSInteger)code
                  errorString:(NSString *)errorString
     mediatedNetworkErrorCode:(NSInteger)mediatedNetworkErrorCode
  mediatedNetworkErrorMessage:(NSString *)mediatedNetworkErrorMessage;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface MAAdapterError(ALDeprecated)
+ (instancetype)errorWithAdapterError:(MAAdapterError *)error thirdPartySdkErrorCode:(NSInteger)thirdPartySdkErrorCode thirdPartySdkErrorMessage:(NSString *)thirdPartySdkErrorMessage
__deprecated_msg("This method has been deprecated in v11.4.0 and will be removed in a future SDK version. Please use -[MAAdapterError errorWithAdapterError:mediatedNetworkErrorCode:mediatedNetworkErrorMessage:] instead.");
+ (instancetype)errorWithCode:(NSInteger)code errorString:(NSString *)errorString thirdPartySdkErrorCode:(NSInteger)thirdPartySdkErrorCode thirdPartySdkErrorMessage:(NSString *)thirdPartySdkErrorMessage
__deprecated_msg("This method has been deprecated in v11.4.0 and will be removed in a future SDK version. Please use -[MAAdapterError errorWithCode:errorString:mediatedNetworkErrorCode:mediatedNetworkErrorMessage:] instead.");
@end

NS_ASSUME_NONNULL_END
