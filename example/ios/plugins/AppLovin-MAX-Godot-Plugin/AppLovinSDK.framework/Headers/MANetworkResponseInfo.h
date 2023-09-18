//
//  MANetworkResponseInfo.h
//  AppLovinSDK
//
//  Created by Thomas So on 10/30/21.
//

@class MAError;
@class MAMediatedNetworkInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * This enum contains possible states of an ad in the waterfall the adapter response info could represent.
 */
typedef NS_ENUM(NSInteger, MAAdLoadState)
{
    /**
     * The AppLovin MAX SDK did not attempt to load an ad from this network in the waterfall because an ad higher in the waterfall loaded successfully.
     */
    MAAdLoadStateAdLoadNotAttempted,
    
    /**
     * An ad successfully loaded from this network.
     */
    MAAdLoadStateAdLoaded,
    
    /**
     * An ad failed to load from this network.
     */
    MAAdLoadStateAdFailedToLoad,
};

/**
 * This class represents an ad response in a waterfall.
 */
@interface MANetworkResponseInfo : NSObject

/**
 * The state of the ad that this @c MAAdapterResponseInfo object represents. For more info, see the @c MAAdLoadState enum.
 */
@property (nonatomic, assign, readonly) MAAdLoadState adLoadState;

/**
 * The mediated network that this adapter response info object represents.
 */
@property (nonatomic, strong, readonly) MAMediatedNetworkInfo *mediatedNetwork;

/**
 * The credentials used to load an ad from this adapter, as entered in the AppLovin MAX dashboard.
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *credentials;

/**
 * Whether or not this response is from a bidding request.
 */
@property (nonatomic, assign, readonly, getter=isBidding) BOOL bidding;

/**
 * The amount of time the network took to load (either successfully or not) an ad, in seconds. If an attempt to load an ad has not been made (i.e. the @c loadState is @c MAAdLoadStateAdLoadNotAttempted), the value will be @c -1.
 */
@property (nonatomic, assign, readonly) NSTimeInterval latency;

/**
 * The ad load error this network response resulted in. Will be @c nil if an attempt to load an ad has not been made or an ad was loaded successfully (i.e. the @c loadState is NOT @c MAAdLoadStateAdFailedtoLoad).
 */
@property (nonatomic, strong, readonly, nullable) MAError *error;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
