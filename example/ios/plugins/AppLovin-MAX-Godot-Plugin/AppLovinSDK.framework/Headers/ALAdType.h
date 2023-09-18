//
//  ALAdType.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This class defines the possible types of an interstitial ad (i.e. regular or incentivized/rewarded).
 */
@interface ALAdType : NSObject

/**
 * A standard advertisement that does not provide a reward to the user.
 */
@property (class, nonatomic, strong, readonly) ALAdType *regular;

/**
 * Represents a standard advertisement that does not provide a reward to the user and is shown upon opening the app.
 */
@property (class, nonatomic, strong, readonly) ALAdType *appOpen;

/**
 * A rewarded ad, which will provide the user virtual currency upon completion.
 */
@property (class, nonatomic, strong, readonly) ALAdType *incentivized;

/**
 * A rewarded interstitial ad, which the user can skip or be granted a reward upon successful completion of the ad.
 */
@property (class, nonatomic, strong, readonly) ALAdType *autoIncentivized;

/**
 * Represents a native ad which can be integrated seemlessly into the environment of your app.
 */
@property (class, nonatomic, strong, readonly) ALAdType *native;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
