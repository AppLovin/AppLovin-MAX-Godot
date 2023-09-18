//
//  ALAdSize.h
//  AppLovinSDK
//
//  Created by Basil on 2/27/12.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This class defines the possible sizes of an ad.
 */
@interface ALAdSize : NSObject

/**
 * Represents the size of a 320×50 banner advertisement.
 */
@property (class, nonatomic, strong, readonly) ALAdSize *banner;

/**
 * Represents the size of a 728×90 leaderboard advertisement (for tablets).
 */
@property (class, nonatomic, strong, readonly) ALAdSize *leader;

/**
 * Represents the size of a 300x250 rectangular advertisement.
 */
@property (class, nonatomic, strong, readonly) ALAdSize *mrec;

/**
 * Represents the size of a full-screen advertisement.
 */
@property (class, nonatomic, strong, readonly) ALAdSize *interstitial;

/**
 * Represents the size of a cross promo advertisement.
 */
@property (class, nonatomic, strong, readonly) ALAdSize *crossPromo;

/**
 * Represents a native ad which can be integrated seemlessly into the environment of your app.
 */
@property (class, nonatomic, strong, readonly) ALAdSize *native;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
