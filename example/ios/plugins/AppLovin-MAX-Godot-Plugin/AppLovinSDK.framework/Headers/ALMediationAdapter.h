//
//  MAMediationAdapterBase.h
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 8/29/18.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/MAAdapter.h>
#import <AppLovinSDK/MAAdapterResponseParameters.h>

@class ALSdk;
@class MAReward;

NS_ASSUME_NONNULL_BEGIN

@interface ALMediationAdapter : NSObject <MAAdapter>

/**
 * Left here for backwards-compatibility purposes - to be removed when enough time passes
 * The AppLovin mediation tag to send to mediated ad networks.
 */
@property (nonatomic, copy, readonly) NSString *mediationTag;

// The AppLovin mediation tag to send to mediated ad networks.
@property (class, nonatomic, copy, readonly) NSString *mediationTag;

// Parent objects
@property (atomic, weak, readonly) ALSdk *sdk;
@property (atomic, copy, readonly) NSString *tag;

- (instancetype)initWithSdk:(ALSdk *)sdk;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface ALMediationAdapter (RewardUtils)

// AppLovin server-provided reward.
@property (nonatomic, strong, readonly) MAReward *reward;

/**
 * This property determines if the adapter should always reward the user.
 * Note: some networks let users opt out of a video/reward and have a corresponding callback for rewarding the user.
 *
 * @return if the adapter should always reward the user.
 */
@property (nonatomic, assign, readonly, getter=shouldAlwaysRewardUser) BOOL alwaysRewardUser;

/**
 * Creates a reward from the server parameters and configures any reward settings.
 */
- (void)configureRewardForParameters:(id<MAAdapterResponseParameters>)parameters;

@end

@interface ALMediationAdapter (Logging)

- (void)d:(NSString *)format, ...;
- (void)i:(NSString *)format, ...;
- (void)w:(NSString *)format, ...;
- (void)e:(NSString *)format, ...;
- (void)e:(NSString *)message becauseOf:(nullable NSException *)ex;
- (void)userError:(NSString *)format, ...;
- (void)userError:(NSString *)message becauseOf:(nullable NSException *)ex;

- (void)log:(NSString *)format, ...;

@end

@interface ALMediationAdapter (ALDeprecated)
extern NSString *const kMAConfigKeyMuted __deprecated_msg("Adapters no longer support mute APIs.");
@end

NS_ASSUME_NONNULL_END
