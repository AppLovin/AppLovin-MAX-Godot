//
//  ALAd.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

@class ALAdSize;
@class ALAdType;

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents an ad that has been served from the AppLovin server.
 */
@interface ALAd : NSObject <NSCopying>

/**
 * The size category of this ad.
 */
@property (nonatomic, strong, readonly) ALAdSize *size;

/**
 * The type of this ad (regular or incentivized/rewarded).
 */
@property (nonatomic, strong, readonly) ALAdType *type;

/**
 * The zone ID for the ad, if any.
 */
@property (nonatomic, copy, readonly, nullable) NSString *zoneIdentifier;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

@interface ALAd (ALDeprecated)
@property (nonatomic, strong, readonly) NSNumber *adIdNumber __deprecated_msg("This API has been deprecated and will be removed in a future release.");
@property (nonatomic, assign, readonly, getter=isVideoAd) BOOL videoAd __deprecated_msg("This API has been deprecated and will be removed in a future release.");
- (nullable NSString *)adValueForKey:(NSString *)key __deprecated_msg("This API has been deprecated and will be removed in a future release.");
- (nullable NSString *)adValueForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue __deprecated_msg("This API has been deprecated and will be removed in a future release.");
@end

NS_ASSUME_NONNULL_END
