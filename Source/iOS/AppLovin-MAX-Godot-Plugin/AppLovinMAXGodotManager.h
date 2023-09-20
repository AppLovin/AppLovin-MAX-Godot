//
//  AppLovinMAXGodotManager.h
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/15/23.
//

#import <Foundation/Foundation.h>
#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppLovinMAXGodotManager : NSObject

- (ALSdk *)initializeSdkWithSettings:(ALSdkSettings *)settings andCompletionHandler:(ALSdkInitializationCompletionHandler)completionHandler;

- (void)createBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier atPosition:(NSString *)bannerPosition;
- (void)createBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier x:(CGFloat)xOffset y:(CGFloat)yOffset;
- (void)loadBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)setBannerBackgroundColorForAdUnitIdentifier:(NSString *)adUnitIdentifier hexColorCode:(NSString *)hexColorCode;
- (void)setBannerPlacement:(nullable NSString *)placement forAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)startBannerAutoRefreshForAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)stopBannerAutoRefreshForAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)setBannerExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable NSString *)value;
- (void)setBannerLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable id)value;
- (void)setBannerCustomData:(nullable NSString *)customData forAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)setBannerWidth:(CGFloat)width forAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)updateBannerPosition:(NSString *)bannerPosition forAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)updateBannerPosition:(CGFloat)xOffset y:(CGFloat)yOffset forAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)showBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)destroyBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)hideBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
+ (CGFloat)adaptiveBannerHeightForWidth:(CGFloat)width;

- (void)createMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier atPosition:(NSString *)mrecPosition;
- (void)createMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier x:(CGFloat)xOffset y:(CGFloat)yOffset;
- (void)loadMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)setMRecPlacement:(nullable NSString *)placement forAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)startMRecAutoRefreshForAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)stopMRecAutoRefreshForAdUnitIdentifier:(NSString *)adUnitIdentifer;
- (void)setMRecExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable NSString *)value;
- (void)setMRecLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable id)value;
- (void)setMRecCustomData:(nullable NSString *)customData forAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)showMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)destroyMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)hideMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)updateMRecPosition:(NSString *)mrecPosition forAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)updateMRecPosition:(CGFloat)xOffset y:(CGFloat)yOffset forAdUnitIdentifier:(NSString *)adUnitIdentifier;

- (void)loadInterstitialWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (BOOL)isInterstitialReadyWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)showInterstitialWithAdUnitIdentifier:(NSString *)adUnitIdentifier placement:(nullable NSString *)placement customData:(nullable NSString *)customData;
- (void)setInterstitialExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable NSString *)value;
- (void)setInterstitialLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable id)value;

- (void)loadAppOpenAdWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (BOOL)isAppOpenAdReadyWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)showAppOpenAdWithAdUnitIdentifier:(NSString *)adUnitIdentifier placement:(nullable NSString *)placement customData:(nullable NSString *)customData;
- (void)setAppOpenAdExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable NSString *)value;
- (void)setAppOpenAdLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable id)value;

- (void)loadRewardedAdWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (BOOL)isRewardedAdReadyWithAdUnitIdentifier:(NSString *)adUnitIdentifier;
- (void)showRewardedAdWithAdUnitIdentifier:(NSString *)adUnitIdentifier placement:(nullable NSString *)placement customData:(nullable NSString *)customData;
- (void)setRewardedAdExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable NSString *)value;
- (void)setRewardedAdLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable id)value;

// Event Tracking
- (void)trackEvent:(NSString *)event parameters:(NSDictionary<NSString *, id> *)parameters;

// Ad Value
- (NSString *)adValueForAdUnitIdentifier:(NSString *)adUnitIdentifier withKey:(NSString *)key;

+ (instancetype)shared;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

