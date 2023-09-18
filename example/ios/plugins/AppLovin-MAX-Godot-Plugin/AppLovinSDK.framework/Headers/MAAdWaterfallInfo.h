//
//  MAAdWaterfallInfo.h
//  AppLovinSDK
//
//  Created by Thomas So on 10/30/21.
//

@class MAAd;
@class MANetworkResponseInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents an ad waterfall, encapsulating various metadata such as total latency, underlying ad responses, etc.
 */
@interface MAAdWaterfallInfo : NSObject

/**
 * The loaded ad, if any, for this waterfall.
 */
@property (nonatomic, weak, readonly, nullable) MAAd *loadedAd;

/**
 * The ad waterfall name.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The ad waterfall test name.
 */
@property (nonatomic, copy, readonly) NSString *testName;

/**
 * The list of @c MAAdapterResponseInfo info objects relating to each ad in the waterfall, ordered by their position.
 */
@property (nonatomic, strong, readonly) NSArray<MANetworkResponseInfo *> *networkResponses;

/**
 * The total latency in seconds for this waterfall to finish processing.
 */
@property (nonatomic, assign, readonly) NSTimeInterval latency;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
