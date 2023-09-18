//
//  ALMediationAdapterRouter.h
//  AppLovinSDK
//
//  Created by Christopher Cong on 10/25/18.
//

#import <UIKit/UIKit.h>
#import <AppLovinSDK/MAAdapter.h>
#import <AppLovinSDK/MAAdViewAdapterDelegate.h>
#import <AppLovinSDK/MAAppOpenAdapterDelegate.h>
#import <AppLovinSDK/MAInterstitialAdapterDelegate.h>
#import <AppLovinSDK/MARewardedAdapterDelegate.h>

@class MAAdapterError;
@class MAReward;

NS_ASSUME_NONNULL_BEGIN

/**
 * For ad networks with a singleton callback pattern, this class is responsible for routing their events to our mediation adapters.
 *
 * This class should only be initialized once per adapter and must be subclassed to be used. Use -sharedInstance to create and access a router.
 * Subclasses should map an ad network's ad events to the methods marked under Ad Network Event Router.
 **/
@interface ALMediationAdapterRouter : NSObject

/**
 * For ad networks whose initialization is completed asynchronously, the router will need to retain the completionHandler until the initialization is completed.
 * Be sure to set this to nil after calling it.
 */
//TODO: remove this once adapter routers have moved away from initialization.
@property (nonatomic, copy, nullable) void(^completionHandler)(void);

/**
 * Mediation adapters should call this when loading an interstitial ad.
 *
 * @param adapter             Mediation adapter responsible for the mediated ad request.
 * @param delegate            Delegate that is listening to the mediation adapter events.
 * @param placementIdentifier Placement identifier requested for the ad load.
 */
- (void)addInterstitialAdapter:(id<MAAdapter>)adapter
                      delegate:(id<MAInterstitialAdapterDelegate>)delegate
        forPlacementIdentifier:(NSString *)placementIdentifier;

/**
 * Mediation adapters should call this when loading an app open ad.
 *
 * @param adapter             Mediation adapter responsible for the mediated ad request.
 * @param delegate            Delegate that is listening to the mediation adapter events.
 * @param placementIdentifier Placement identifier requested for the ad load.
 */
- (void)addAppOpenAdapter:(id<MAAdapter>)adapter
                 delegate:(id<MAAppOpenAdapterDelegate>)delegate
   forPlacementIdentifier:(NSString *)placementIdentifier;

/**
 * Mediation adapters should call this when loading a rewarded ad.
 *
 * @param adapter             Mediation adapter responsible for the mediated ad request.
 * @param delegate            Delegate that is listening to the mediation adapter events.
 * @param placementIdentifier Placement identifier requested for the ad load.
 */
- (void)addRewardedAdapter:(id<MAAdapter>)adapter
                  delegate:(id<MARewardedAdapterDelegate>)delegate
    forPlacementIdentifier:(NSString *)placementIdentifier;

/**
 * Mediation adapters should call this when loading an ad view.
 *
 * @param adapter             Mediation adapter responsible for the mediated ad request.
 * @param delegate            Delegate that is listening to the mediation adapter events.
 * @param placementIdentifier Placement identifier requested for the ad load.
 * @param adView              The ad view for the adapter. May be null.
 */
- (void)addAdViewAdapter:(id<MAAdapter>)adapter
                delegate:(id<MAAdViewAdapterDelegate>)delegate
  forPlacementIdentifier:(NSString *)placementIdentifier
                  adView:(nullable UIView *)adView;

/**
 * Updates the underlying ad view for the given placement id. This is useful if by the time an adapter is added
 * to the router's map, there is no ad view present yet. (e.g. UnityAds).
 *
 * @param adView              The ad view to update for the adapter.
 * @param placementIdentifier Placement identifier for the ad view.
 */
- (void)updateAdView:(UIView *)adView forPlacementIdentifier:(NSString *)placementIdentifier;

/**
 * Mediation should call this on when showing an ad.
 */
- (void)addShowingAdapter:(id<MAAdapter>)showingAdapter;

/**
 * Mediation adapters should call this on -destroy.
 */
- (void)removeAdapter:(id<MAAdapter>)adapter forPlacementIdentifier:(NSString *)placementIdentifier;

#pragma mark - Ad Network Event Router

- (void)didLoadAdForPlacementIdentifier:(NSString *)placementIdentifier;
- (void)didLoadAdForPlacementIdentifier:(NSString *)placementIdentifier withExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;
- (void)didFailToLoadAdForPlacementIdentifier:(NSString *)placementIdentifier error:(MAAdapterError *)error;

- (void)didDisplayAdForPlacementIdentifier:(NSString *)placementIdentifier;
- (void)didDisplayAdForPlacementIdentifier:(NSString *)placementIdentifier withExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;
- (void)didFailToDisplayAdForPlacementIdentifier:(NSString *)placementIdentifier error:(MAAdapterError *)error;

- (void)didClickAdForPlacementIdentifier:(NSString *)placementIdentifier;
- (void)didHideAdForPlacementIdentifier:(NSString *)placementIdentifier;

// Rewarded delegate methods
- (void)didStartRewardedVideoForPlacementIdentifier:(NSString *)placementIdentifier;
- (void)didCompleteRewardedVideoForPlacementIdentifier:(NSString *)placementIdentifier;
- (void)didRewardUserForPlacementIdentifier:(NSString *)placementIdentifier withReward:(MAReward *)reward;

// AdView delegate methods
- (void)didExpandAdForPlacementIdentifier:(NSString *)placementIdentifier;
- (void)didCollapseAdForPlacementIdentifier:(NSString *)placementIdentifier;

#pragma mark - Adapter Reward Utility Methods

- (MAReward *)rewardForPlacementIdentifier:(NSString *)placementIdentifier;
- (BOOL)shouldAlwaysRewardUserForPlacementIdentifier:(NSString *)placementIdentifier;

#pragma mark - Logging Methods

- (void)log:(NSString *)format, ...;
- (void)log:(NSString *)message becauseOf:(NSException *)exception;

#pragma mark - Singleton

/**
 * This implementation uses the Registry Pattern to create/return the shared instance for a given subclass caller.
 */
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
