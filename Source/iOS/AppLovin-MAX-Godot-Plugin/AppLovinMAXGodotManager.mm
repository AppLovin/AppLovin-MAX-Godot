//
//  AppLovinMAXGodotManager.m
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/15/23.
//

#import "AppLovinMAXGodotManager.h"
#import "AppLovinMAXGodotPlugin.h"
#import "AppLovinMAXGodotSignal.h"
#import "Categories/NSArray+AppLovinMAXGodotPlugin.h"
#import "Categories/NSDictionary+AppLovinMAXGodotPlugin.h"
#import "Categories/NSObject+AppLovinMAXGodotPlugin.h"
#import "Categories/NSString+AppLovinMAXGodotPlugin.h"

#define KEY_WINDOW [UIApplication sharedApplication].keyWindow
#define DEVICE_SPECIFIC_ADVIEW_AD_FORMAT ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? MAAdFormat.leader : MAAdFormat.banner
#define IS_VERTICAL_BANNER_POSITION(_POS) ( [@"center_left" isEqual: adViewPosition] || [@"center_right" isEqual: adViewPosition] )
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

NS_INLINE void max_godot_dispatch_on_main_thread(dispatch_block_t block)
{
    if ( block )
    {
        if ( [NSThread isMainThread] )
        {
            block();
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}

@interface AppLovinMAXGodotManager()<MAAdDelegate, MAAdViewAdDelegate, MARewardedAdDelegate, MAAdRevenueDelegate>

// Parent Fields
@property (nonatomic, weak) ALSdk *sdk;

// Fullscreen Ad Fields
@property (nonatomic, strong) NSMutableDictionary<NSString *, MAInterstitialAd *> *interstitials;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MAAppOpenAd *> *appOpenAds;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MARewardedAd *> *rewardedAds;

// AdView Fields
@property (nonatomic, strong) NSMutableDictionary<NSString *, MAAdView *> *adViews;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MAAdFormat *> *adViewAdFormats;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *adViewPositions;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSValue *> *adViewOffsets;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *adViewWidths;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MAAdFormat *> *verticalAdViewFormats;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSLayoutConstraint *> *> *adViewConstraints;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *> *> *adViewExtraParametersToSetAfterCreate;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *adViewLocalExtraParametersToSetAfterCreate;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *adViewCustomDataToSetAfterCreate;
@property (nonatomic, strong) NSMutableArray<NSString *> *adUnitIdentifiersToShowAfterCreate;
@property (nonatomic, strong) NSMutableSet<NSString *> *disabledAdaptiveBannerAdUnitIdentifiers;
@property (nonatomic, strong) NSMutableSet<NSString *> *disabledAutoRefreshAdViewAdUnitIdentifiers;
@property (nonatomic, strong) UIView *safeAreaBackground;
@property (nonatomic, strong, nullable) UIColor *publisherBannerBackgroundColor;

@property (nonatomic, strong) NSMutableDictionary<NSString *, MAAd *> *adInfoDict;
@property (nonatomic, strong) NSObject *adInfoDictLock;

@end

// Internal
@interface UIColor (ALUtils)
+ (nullable UIColor *)al_colorWithHexString:(NSString *)hexString;
@end

@interface NSNumber (ALUtils)
+ (NSNumber *)al_numberWithString:(NSString *)string;
@end

@interface NSString (ALUtils)
@property (assign, readonly, getter=al_isValidString) BOOL al_validString;
@end

@interface MAAdFormat (ALUtils)
@property (nonatomic, assign, readonly, getter=isFullscreenAd) BOOL fullscreenAd;
@property (nonatomic, assign, readonly, getter=isAdViewAd) BOOL adViewAd;
@end

@implementation AppLovinMAXGodotManager
static NSString *const SDK_TAG = @"AppLovinSdk";
static NSString *const TAG = @"AppLovinMAXGodotManager";
static NSString *const DEFAULT_AD_VIEW_POSITION = @"top_left";

#pragma mark - Initialization

+ (AppLovinMAXGodotManager *)shared
{
    static dispatch_once_t token;
    static AppLovinMAXGodotManager *shared;
    dispatch_once(&token, ^{
        shared = [[AppLovinMAXGodotManager alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.sdk = [ALSdk shared];

        self.interstitials = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.appOpenAds = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.rewardedAds = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.adViews = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.adViewAdFormats = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.adViewPositions = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.adViewOffsets = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.adViewWidths = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.verticalAdViewFormats = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.adViewConstraints = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.adViewExtraParametersToSetAfterCreate = [NSMutableDictionary dictionaryWithCapacity: 1];
        self.adViewLocalExtraParametersToSetAfterCreate = [NSMutableDictionary dictionaryWithCapacity: 1];
        self.adViewCustomDataToSetAfterCreate = [NSMutableDictionary dictionaryWithCapacity: 1];
        self.adUnitIdentifiersToShowAfterCreate = [NSMutableArray arrayWithCapacity: 2];
        self.disabledAdaptiveBannerAdUnitIdentifiers = [NSMutableSet setWithCapacity: 2];
        self.disabledAutoRefreshAdViewAdUnitIdentifiers = [NSMutableSet setWithCapacity: 2];
        self.adInfoDict = [NSMutableDictionary dictionary];
        self.adInfoDictLock = [[NSObject alloc] init];
        
        max_godot_dispatch_on_main_thread(^{
            self.safeAreaBackground = [[UIView alloc] init];
            self.safeAreaBackground.hidden = YES;
            self.safeAreaBackground.backgroundColor = UIColor.clearColor;
            self.safeAreaBackground.translatesAutoresizingMaskIntoConstraints = NO;
            self.safeAreaBackground.userInteractionEnabled = NO;
            
            [KEY_WINDOW.rootViewController.view addSubview: self.safeAreaBackground];
        });
        
        // Enable orientation change listener, so that the position can be updated for vertical banners.
        [[NSNotificationCenter defaultCenter] addObserverForName: UIDeviceOrientationDidChangeNotification
                                                          object: nil
                                                           queue: [NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
            
            for ( NSString *adUnitIdentifier in self.verticalAdViewFormats )
            {
                [self positionAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: self.verticalAdViewFormats[adUnitIdentifier]];
            }
        }];
    }
    return self;
}

#pragma mark - Banners

- (void)createBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier atPosition:(NSString *)bannerPosition
{
    [self createAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier] atPosition: bannerPosition withOffset: CGPointZero];
}

- (void)createBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier x:(CGFloat)xOffset y:(CGFloat)yOffset
{
    [self createAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier] atPosition: DEFAULT_AD_VIEW_POSITION withOffset: CGPointMake(xOffset, yOffset)];
}

- (void)loadBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self loadAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

- (void)setBannerBackgroundColorForAdUnitIdentifier:(NSString *)adUnitIdentifier hexColorCode:(NSString *)hexColorCode
{
    [self setAdViewBackgroundColorForAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier] hexColorCode: hexColorCode];
}

- (void)setBannerPlacement:(nullable NSString *)placement forAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self setAdViewPlacement: placement forAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

- (void)startBannerAutoRefreshForAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self startAdViewAutoRefreshForAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

- (void)stopBannerAutoRefreshForAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self stopAdViewAutoRefreshForAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

- (void)setBannerWidth:(CGFloat)width forAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self setAdViewWidth: width forAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

- (void)updateBannerPosition:(NSString *)bannerPosition forAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self updateAdViewPosition: bannerPosition withOffset: CGPointZero forAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

- (void)updateBannerPosition:(CGFloat)xOffset y:(CGFloat)yOffset forAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self updateAdViewPosition: DEFAULT_AD_VIEW_POSITION withOffset: CGPointMake(xOffset, yOffset) forAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

- (void)setBannerExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable NSString *)value
{
    [self setAdViewExtraParameterForAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier] key: key value: value];
}

- (void)setBannerLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable id)value
{
    [self setAdViewLocalExtraParameterForAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier] key: key value: value];
}

- (void)setBannerCustomData:(nullable NSString *)customData forAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self setAdViewCustomData: customData forAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

- (void)showBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self showAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

- (void)hideBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self hideAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

- (void)destroyBannerWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self destroyAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: [self adViewAdFormatForAdUnitIdentifier: adUnitIdentifier]];
}

+ (CGFloat)adaptiveBannerHeightForWidth:(CGFloat)width
{
    return [DEVICE_SPECIFIC_ADVIEW_AD_FORMAT adaptiveSizeForWidth: width].height;
}

#pragma mark - MRECs

- (void)createMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier atPosition:(NSString *)mrecPosition
{
    [self createAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec atPosition: mrecPosition withOffset: CGPointZero];
}

- (void)createMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier x:(CGFloat)xOffset y:(CGFloat)yOffset
{
    [self createAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec atPosition: DEFAULT_AD_VIEW_POSITION withOffset: CGPointMake(xOffset, yOffset)];
}

- (void)loadMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self loadAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec];
}

- (void)setMRecPlacement:(nullable NSString *)placement forAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self setAdViewPlacement: placement forAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec];
}

- (void)startMRecAutoRefreshForAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self startAdViewAutoRefreshForAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec];
}

- (void)stopMRecAutoRefreshForAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self stopAdViewAutoRefreshForAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec];
}

- (void)updateMRecPosition:(NSString *)mrecPosition forAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self updateAdViewPosition: mrecPosition withOffset: CGPointZero forAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec];
}

- (void)updateMRecPosition:(CGFloat)xOffset y:(CGFloat)yOffset forAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self updateAdViewPosition: DEFAULT_AD_VIEW_POSITION withOffset: CGPointMake(xOffset, yOffset) forAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec];
}

- (void)setMRecExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable NSString *)value
{
    [self setAdViewExtraParameterForAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec key: key value: value];
}

- (void)setMRecLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable id)value
{
    [self setAdViewLocalExtraParameterForAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec key: key value: value];
}

- (void)setMRecCustomData:(nullable NSString *)customData forAdUnitIdentifier:(NSString *)adUnitIdentifier;
{
    [self setAdViewCustomData: customData forAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec];
}

- (void)showMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self showAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec];
}

- (void)destroyMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self destroyAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec];
}

- (void)hideMRecWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    [self hideAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: MAAdFormat.mrec];
}

#pragma mark - Interstitials

- (void)loadInterstitialWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    MAInterstitialAd *interstitial = [self retrieveInterstitialForAdUnitIdentifier: adUnitIdentifier];
    [interstitial loadAd];
}

- (BOOL)isInterstitialReadyWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    MAInterstitialAd *interstitial = [self retrieveInterstitialForAdUnitIdentifier: adUnitIdentifier];
    return [interstitial isReady];
}

- (void)showInterstitialWithAdUnitIdentifier:(NSString *)adUnitIdentifier placement:(nullable NSString *)placement customData:(nullable NSString *)customData
{
    MAInterstitialAd *interstitial = [self retrieveInterstitialForAdUnitIdentifier: adUnitIdentifier];
    [interstitial showAdForPlacement: placement customData: customData];
}

- (void)setInterstitialExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable NSString *)value
{
    MAInterstitialAd *interstitial = [self retrieveInterstitialForAdUnitIdentifier: adUnitIdentifier];
    [interstitial setExtraParameterForKey: key value: value];
}

- (void)setInterstitialLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable id)value
{
    MAInterstitialAd *interstitial = [self retrieveInterstitialForAdUnitIdentifier: adUnitIdentifier];
    [interstitial setLocalExtraParameterForKey: key value: value];
}

#pragma mark - App Open Ads

- (void)loadAppOpenAdWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    MAAppOpenAd *appOpenAd = [self retrieveAppOpenAdForAdUnitIdentifier: adUnitIdentifier];
    [appOpenAd loadAd];
}

- (BOOL)isAppOpenAdReadyWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    MAAppOpenAd *appOpenAd = [self retrieveAppOpenAdForAdUnitIdentifier: adUnitIdentifier];
    return [appOpenAd isReady];
}

- (void)showAppOpenAdWithAdUnitIdentifier:(NSString *)adUnitIdentifier placement:(nullable NSString *)placement customData:(nullable NSString *)customData
{
    MAAppOpenAd *appOpenAd = [self retrieveAppOpenAdForAdUnitIdentifier: adUnitIdentifier];
    [appOpenAd showAdForPlacement: placement customData: customData];
}

- (void)setAppOpenAdExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable NSString *)value
{
    MAAppOpenAd *appOpenAd = [self retrieveAppOpenAdForAdUnitIdentifier: adUnitIdentifier];
    [appOpenAd setExtraParameterForKey: key value: value];
}

- (void)setAppOpenAdLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable id)value
{
    MAAppOpenAd *appOpenAd = [self retrieveAppOpenAdForAdUnitIdentifier: adUnitIdentifier];
    [appOpenAd setLocalExtraParameterForKey: key value: value];
}

#pragma mark - Rewarded

- (void)loadRewardedAdWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    MARewardedAd *rewardedAd = [self retrieveRewardedAdForAdUnitIdentifier: adUnitIdentifier];
    [rewardedAd loadAd];
}

- (BOOL)isRewardedAdReadyWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    MARewardedAd *rewardedAd = [self retrieveRewardedAdForAdUnitIdentifier: adUnitIdentifier];
    return [rewardedAd isReady];
}

- (void)showRewardedAdWithAdUnitIdentifier:(NSString *)adUnitIdentifier placement:(nullable NSString *)placement customData:(nullable NSString *)customData
{
    MARewardedAd *rewardedAd = [self retrieveRewardedAdForAdUnitIdentifier: adUnitIdentifier];
    [rewardedAd showAdForPlacement: placement customData: customData];
}

- (void)setRewardedAdExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable NSString *)value
{
    MARewardedAd *rewardedAd = [self retrieveRewardedAdForAdUnitIdentifier: adUnitIdentifier];
    [rewardedAd setExtraParameterForKey: key value: value];
}

- (void)setRewardedAdLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier key:(NSString *)key value:(nullable id)value;
{
    MARewardedAd *rewardedAd = [self retrieveRewardedAdForAdUnitIdentifier: adUnitIdentifier];
    [rewardedAd setLocalExtraParameterForKey: key value: value];
}

#pragma mark - Event Tracking

- (void)trackEvent:(NSString *)event parameters:(NSDictionary<NSString *, id> *)parameters
{
    [self.sdk.eventService trackEvent: event parameters: parameters];
}

#pragma mark - Ad Info

- (MAAd *)adInfoForAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    if ( adUnitIdentifier.length == 0 ) return nil;
    
    return [self adWithAdUnitIdentifier: adUnitIdentifier];
}

- (Dictionary)adInfoForAd:(MAAd *)ad
{
    Dictionary ad_info = Dictionary();
    ad_info["adUnitId"] = GODOT_STRING(ad.adUnitIdentifier);
    ad_info["adFormat"] = GODOT_STRING(ad.format.label);
    ad_info["networkName"] = GODOT_STRING(ad.networkName);
    ad_info["networkPlacement"] = GODOT_STRING(ad.networkPlacement);
    ad_info["creativeId"] = GODOT_STRING(ad.creativeIdentifier);
    ad_info["placement"] = GODOT_STRING(ad.placement);
    ad_info["revenue"] = ad.revenue;
    ad_info["revenuePrecision"] = ad.revenuePrecision;
    ad_info["waterfallInfo"] = [self createAdWaterfallInfo: ad.waterfall];
    ad_info["dspName"] = GODOT_STRING(ad.DSPName);
    return ad_info;
}

#pragma mark - Waterfall Information

- (Dictionary)createAdWaterfallInfo:(MAAdWaterfallInfo *)waterfallInfo
{
    Dictionary result = Dictionary();
    if ( !waterfallInfo ) return result;
    
    result["name"] = GODOT_STRING(waterfallInfo.name);
    result["testName"] = GODOT_STRING(waterfallInfo.testName);
    
    Array networkResponsesArray = Array();
    for ( MANetworkResponseInfo *response in  waterfallInfo.networkResponses )
    {
        networkResponsesArray.push_back([self createNetworkResponseInfo: response]);
    }
    result["networkResponses"] = networkResponsesArray;
    
    // Convert latency from seconds to milliseconds to match Android.
    result["latencyMillis"] = waterfallInfo.latency * 1000;
    
    return result;
}

- (Dictionary)createNetworkResponseInfo:(MANetworkResponseInfo *)response
{
    Dictionary networkResponseDict = Dictionary();
    
    networkResponseDict["adLoadState"] = (int) response.adLoadState;
    
    MAMediatedNetworkInfo *mediatedNetworkInfo = response.mediatedNetwork;
    if ( mediatedNetworkInfo )
    {
        Dictionary networkInfoObject = Dictionary();
        networkInfoObject["name"] = GODOT_STRING(response.mediatedNetwork.name);
        networkInfoObject["adapterClassName"] = GODOT_STRING(response.mediatedNetwork.adapterClassName);
        networkInfoObject["adapterVersion"] = GODOT_STRING(response.mediatedNetwork.adapterVersion);
        networkInfoObject["sdkVersion"] = GODOT_STRING(response.mediatedNetwork.sdkVersion);
        
        networkResponseDict["mediatedNetwork"] = networkInfoObject;
    }
    
    networkResponseDict["credentials"] = GODOT_DICTIONARY(response.credentials);
    networkResponseDict["isBidding"] = [response isBidding];
    
    MAError *error = response.error;
    if ( error )
    {
        Dictionary errorObject = Dictionary();
        errorObject["errorMessage"] = GODOT_STRING(error.message);
        errorObject["adLoadFailure"] = GODOT_STRING(error.adLoadFailureInfo);
        errorObject["errorCode"] = (int) error.code;
        
        networkResponseDict["error"] = errorObject;
    }
    
    // Convert latency from seconds to milliseconds to match Android.
    long latencySeconds = response.latency * 1000;
    networkResponseDict["latencyMillis"] = @(latencySeconds).stringValue;
    
    return networkResponseDict;
}

#pragma mark - Ad Value

- (NSString *)adValueForAdUnitIdentifier:(NSString *)adUnitIdentifier withKey:(NSString *)key
{
    if ( adUnitIdentifier.length == 0 ) return @"";
    
    MAAd *ad = [self adWithAdUnitIdentifier: adUnitIdentifier];
    if ( !ad ) return @"";
    
    return [ad adValueForKey: key];
}

#pragma mark - Ad Callbacks

- (void)didLoadAd:(MAAd *)ad
{
    String signalName;
    MAAdFormat *adFormat = ad.format;
    if ( [adFormat isAdViewAd] )
    {
        MAAdView *adView = [self retrieveAdViewForAdUnitIdentifier: ad.adUnitIdentifier adFormat: adFormat];
        // An ad is now being shown, enable user interaction.
        adView.userInteractionEnabled = YES;
        
        if ( MAAdFormat.mrec == adFormat )
        {
            signalName = AppLovinMAXSignalMRecOnAdLoaded;
        }
        else
        {
            signalName = AppLovinMAXSignalBannerOnAdLoaded;
        }
        [self positionAdViewForAd: ad];
        
        // Do not auto-refresh by default if the ad view is not showing yet (e.g. first load during app launch and publisher does not automatically show banner upon load success)
        // We will resume auto-refresh in -[MAUnityAdManager showBannerWithAdUnitIdentifier:].
        if ( adView && [adView isHidden] )
        {
            [adView stopAutoRefresh];
        }
    }
    else if ( MAAdFormat.interstitial == adFormat )
    {
        signalName = AppLovinMAXSignalInterstitialOnAdLoaded;
    }
    else if ( MAAdFormat.appOpen == adFormat )
    {
        signalName = AppLovinMAXSignalAppOpenOnAdLoaded;
    }
    else if ( MAAdFormat.rewarded == adFormat )
    {
        signalName = AppLovinMAXSignalRewardedOnAdLoaded;
    }
    else
    {
        [self logInvalidAdFormat: adFormat];
        return;
    }
    
    @synchronized ( self.adInfoDictLock )
    {
        self.adInfoDict[ad.adUnitIdentifier] = ad;
    }
    
    Dictionary adInfo = [self adInfoForAd: ad];
    max_godot_dispatch_on_main_thread(^{
        AppLovinMAXGodotPlugin::get_instance()->emit_signal(signalName, GODOT_STRING(ad.adUnitIdentifier), adInfo);
    });
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error
{
    if ( !adUnitIdentifier )
    {
        [self log: @"adUnitIdentifier cannot be nil from %@", [NSThread callStackSymbols]];
        return;
    }
    
    String signalName;
    if ( self.adViews[adUnitIdentifier] )
    {
        MAAdFormat *adFormat = self.adViewAdFormats[adUnitIdentifier];
        if ( MAAdFormat.mrec == adFormat )
        {
            signalName = AppLovinMAXSignalBannerOnAdLoadFailed;
        }
        else
        {
            signalName = AppLovinMAXSignalMRecOnAdLoadFailed;
        }
    }
    else if ( self.interstitials[adUnitIdentifier] )
    {
        signalName = AppLovinMAXSignalInterstitialOnAdLoadFailed;
    }
    else if ( self.appOpenAds[adUnitIdentifier] )
    {
        signalName = AppLovinMAXSignalAppOpenOnAdLoadFailed;
    }
    else if ( self.rewardedAds[adUnitIdentifier] )
    {
        signalName = AppLovinMAXSignalRewardedOnAdLoadFailed;
    }
    else
    {
        [self log: @"invalid adUnitId from %@", [NSThread callStackSymbols]];
        return;
    }
    
    @synchronized ( self.adInfoDictLock )
    {
        [self.adInfoDict removeObjectForKey: adUnitIdentifier];
    }
    
    Dictionary errorInfo = Dictionary();
    errorInfo["errorCode"] = (int) error.code;
    errorInfo["errorMessage"] = GODOT_STRING(error.message);
    errorInfo["waterfallInfo"] = [self createAdWaterfallInfo: error.waterfall];
    
    max_godot_dispatch_on_main_thread(^{
        AppLovinMAXGodotPlugin::get_instance()->emit_signal(signalName, GODOT_STRING(adUnitIdentifier), errorInfo);
    });
}

- (void)didClickAd:(MAAd *)ad
{
    String signalName;
    MAAdFormat *adFormat = ad.format;
    if ( MAAdFormat.banner == adFormat || MAAdFormat.leader == adFormat )
    {
        signalName = AppLovinMAXSignalBannerOnAdClicked;
    }
    else if ( MAAdFormat.mrec == adFormat )
    {
        signalName = AppLovinMAXSignalMRecOnAdClicked;
    }
    else if ( MAAdFormat.interstitial == adFormat )
    {
        signalName = AppLovinMAXSignalInterstitialOnAdClicked;
    }
    else if ( MAAdFormat.appOpen == adFormat )
    {
        signalName = AppLovinMAXSignalAppOpenOnAdClicked;
    }
    else if ( MAAdFormat.rewarded == adFormat )
    {
        signalName = AppLovinMAXSignalRewardedOnAdClicked;
    }
    else
    {
        [self logInvalidAdFormat: adFormat];
        return;
    }
    
    Dictionary adInfo = [self adInfoForAd: ad];
    max_godot_dispatch_on_main_thread(^{
        AppLovinMAXGodotPlugin::get_instance()->emit_signal(signalName, GODOT_STRING(ad.adUnitIdentifier), adInfo);
    });
}

- (void)didDisplayAd:(MAAd *)ad
{
    // BMLs do not support [DISPLAY] events in Godot
    MAAdFormat *adFormat = ad.format;
    if ( ![adFormat isFullscreenAd] ) return;
    
    String signalName;
    if ( MAAdFormat.interstitial == adFormat )
    {
        signalName = AppLovinMAXSignalInterstitialOnAdDisplayed;
    }
    else if ( MAAdFormat.appOpen == adFormat )
    {
        signalName = AppLovinMAXSignalAppOpenOnAdDisplayed;
    }
    else if ( MAAdFormat.rewarded == adFormat )
    {
        signalName = AppLovinMAXSignalRewardedOnAdDisplayed;
    }
    else
    {
        [self logInvalidAdFormat: adFormat];
        return;
    }
    
    Dictionary adInfo = [self adInfoForAd: ad];
    max_godot_dispatch_on_main_thread(^{
        AppLovinMAXGodotPlugin::get_instance()->emit_signal(signalName, GODOT_STRING(ad.adUnitIdentifier), adInfo);
    });
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error
{
    // BMLs do not support [DISPLAY] events in Unity
    MAAdFormat *adFormat = ad.format;
    if ( ![adFormat isFullscreenAd] ) return;
    
    String signalName;
    if ( MAAdFormat.interstitial == adFormat )
    {
        signalName = AppLovinMAXSignalInterstitialOnAdDisplayFailed;
    }
    else if ( MAAdFormat.appOpen == adFormat )
    {
        signalName = AppLovinMAXSignalAppOpenOnAdDisplayFailed;
    }
    else if ( MAAdFormat.rewarded == adFormat )
    {
        signalName = AppLovinMAXSignalRewardedOnAdDisplayFailed;
    }
    else
    {
        [self logInvalidAdFormat: adFormat];
        return;
    }
    
    Dictionary adInfo = [self adInfoForAd: ad];
    
    Dictionary errorInfo = Dictionary();
    errorInfo["errorCode"] = (int) error.code;
    errorInfo["errorMessage"] = GODOT_STRING(error.message);
    errorInfo["mediatedNetworkErrorCode"] = (int) error.mediatedNetworkErrorCode;
    errorInfo["mediatedNetworkErrorMessage"] = GODOT_STRING(error.mediatedNetworkErrorMessage);
    errorInfo["waterfallInfo"] = [self createAdWaterfallInfo: error.waterfall];
    
    max_godot_dispatch_on_main_thread(^{
        AppLovinMAXGodotPlugin::get_instance()->emit_signal(signalName, GODOT_STRING(ad.adUnitIdentifier), errorInfo, adInfo);
    });
}

- (void)didHideAd:(MAAd *)ad
{
    // BMLs do not support [HIDDEN] events in Unity
    MAAdFormat *adFormat = ad.format;
    if ( ![adFormat isFullscreenAd] ) return;
    
    String signalName;
    if ( MAAdFormat.interstitial == adFormat )
    {
        signalName = AppLovinMAXSignalInterstitialOnAdHidden;
    }
    else if ( MAAdFormat.appOpen == adFormat )
    {
        signalName = AppLovinMAXSignalAppOpenOnAdHidden;
    }
    else if ( MAAdFormat.rewarded == adFormat )
    {
        signalName = AppLovinMAXSignalRewardedOnAdHidden;
    }
    else
    {
        [self logInvalidAdFormat: adFormat];
        return;
    }
    
    Dictionary adInfo = [self adInfoForAd: ad];
    max_godot_dispatch_on_main_thread(^{
        AppLovinMAXGodotPlugin::get_instance()->emit_signal(signalName, GODOT_STRING(ad.adUnitIdentifier), adInfo);
    });
}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward
{
    MAAdFormat *adFormat = ad.format;
    if ( adFormat != MAAdFormat.rewarded )
    {
        [self logInvalidAdFormat: adFormat];
        return;
    }
    
    String signalName = AppLovinMAXSignalRewardedOnAdReceivedReward;
    
    Dictionary adInfo = [self adInfoForAd: ad];
    
    Dictionary rewardInfo = Dictionary();
    rewardInfo["label"] = GODOT_STRING(reward.label);
    rewardInfo["amount"] = (int) reward.amount;
    
    max_godot_dispatch_on_main_thread(^{
        AppLovinMAXGodotPlugin::get_instance()->emit_signal(signalName, GODOT_STRING(ad.adUnitIdentifier), rewardInfo, adInfo);
    });
}

- (void)didPayRevenueForAd:(MAAd *)ad
{
    String signalName;
    MAAdFormat *adFormat = ad.format;
    if ( MAAdFormat.banner == adFormat || MAAdFormat.leader == adFormat )
    {
        signalName = AppLovinMAXSignalBannerOnAdRevenuePaid;
    }
    else if ( MAAdFormat.mrec == adFormat )
    {
        signalName = AppLovinMAXSignalMRecOnAdRevenuePaid;
    }
    else if ( MAAdFormat.interstitial == adFormat )
    {
        signalName = AppLovinMAXSignalInterstitialOnAdRevenuePaid;
    }
    else if ( MAAdFormat.appOpen == adFormat )
    {
        signalName = AppLovinMAXSignalAppOpenOnAdRevenuePaid;
    }
    else if ( MAAdFormat.rewarded == adFormat )
    {
        signalName = AppLovinMAXSignalRewardedOnAdRevenuePaid;
    }
    else
    {
        [self logInvalidAdFormat: adFormat];
        return;
    }
    
    Dictionary adInfo = [self adInfoForAd: ad];
    max_godot_dispatch_on_main_thread(^{
        AppLovinMAXGodotPlugin::get_instance()->emit_signal(signalName, GODOT_STRING(ad.adUnitIdentifier), adInfo);
    });
}

- (void)didExpandAd:(nonnull MAAd *)ad
{
    MAAdFormat *adFormat = ad.format;
    if ( ![adFormat isAdViewAd] ) return;
    
    String signalName;
    if ( MAAdFormat.banner == adFormat ||  MAAdFormat.leader == adFormat )
    {
        signalName = AppLovinMAXSignalBannerOnAdExpanded;
    }
    else if ( MAAdFormat.mrec == adFormat )
    {
        signalName = AppLovinMAXSignalMRecOnAdExpanded;
    }
    else
    {
        [self logInvalidAdFormat: adFormat];
        return;
    }
    
    Dictionary adInfo = [self adInfoForAd: ad];
    max_godot_dispatch_on_main_thread(^{
        AppLovinMAXGodotPlugin::get_instance()->emit_signal(signalName, GODOT_STRING(ad.adUnitIdentifier), adInfo);
    });
}

- (void)didCollapseAd:(nonnull MAAd *)ad
{
    MAAdFormat *adFormat = ad.format;
    if ( ![adFormat isAdViewAd] ) return;
    
    String signalName;
    if ( MAAdFormat.banner == adFormat || MAAdFormat.leader == adFormat )
    {
        signalName = AppLovinMAXSignalBannerOnAdCollapsed;
    }
    else if ( MAAdFormat.mrec == adFormat )
    {
        signalName = AppLovinMAXSignalMRecOnAdCollapsed;
    }
    else
    {
        [self logInvalidAdFormat: adFormat];
        return;
    }
    
    Dictionary adInfo = [self adInfoForAd: ad];
    max_godot_dispatch_on_main_thread(^{
        AppLovinMAXGodotPlugin::get_instance()->emit_signal(signalName, GODOT_STRING(ad.adUnitIdentifier), adInfo);
    });
}

#pragma mark - Internal Methods

- (void)createAdViewWithAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat atPosition:(NSString *)adViewPosition withOffset:(CGPoint)offset
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Creating %@ with ad unit identifier \"%@\" and position: \"%@\"", adFormat, adUnitIdentifier, adViewPosition];
        
        if ( self.adViews[adUnitIdentifier] )
        {
            [self log: @"Trying to create a %@ that was already created. This will cause the current ad to be hidden.", adFormat.label];
        }
        
        // Retrieve ad view from the map
        MAAdView *adView = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat atPosition: adViewPosition withOffset: offset];
        adView.hidden = YES;
        self.safeAreaBackground.hidden = YES;
        
        // Position ad view immediately so if publisher sets color before ad loads, it will not be the size of the screen
        self.adViewAdFormats[adUnitIdentifier] = adFormat;
        [self positionAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        
        // Enable adaptive banners by default.
        if ( ( self.adViewExtraParametersToSetAfterCreate[@"adaptive_banner"] != nil ) && ( adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader ) )
        {
            [adView setExtraParameterForKey: @"adaptive_banner" value: @"true"];
        }
        
        // Handle initial extra parameters if publisher sets it before creating ad view
        if ( self.adViewExtraParametersToSetAfterCreate[adUnitIdentifier] )
        {
            NSDictionary<NSString *, NSString *> *extraParameters = self.adViewExtraParametersToSetAfterCreate[adUnitIdentifier];
            for ( NSString *key in extraParameters )
            {
                [adView setExtraParameterForKey: key value: extraParameters[key]];
                
                [self handleExtraParameterChangesIfNeededForAdUnitIdentifier: adUnitIdentifier
                                                                    adFormat: adFormat
                                                                         key: key
                                                                       value: extraParameters[key]];
            }
            
            [self.adViewExtraParametersToSetAfterCreate removeObjectForKey: adUnitIdentifier];
        }
        
        // Handle initial local extra parameters if publisher sets it before creating ad view
        if ( self.adViewLocalExtraParametersToSetAfterCreate[adUnitIdentifier] )
        {
            NSDictionary<NSString *, NSString *> *localExtraParameters = self.adViewLocalExtraParametersToSetAfterCreate[adUnitIdentifier];
            for ( NSString *key in localExtraParameters )
            {
                [adView setLocalExtraParameterForKey: key value: localExtraParameters[key]];
            }
            
            [self.adViewLocalExtraParametersToSetAfterCreate removeObjectForKey: adUnitIdentifier];
        }
        
        // Handle initial custom data if publisher sets it before creating ad view
        if ( self.adViewCustomDataToSetAfterCreate[adUnitIdentifier] )
        {
            NSString *customData = self.adViewCustomDataToSetAfterCreate[adUnitIdentifier];
            adView.customData = customData;
            
            [self.adViewCustomDataToSetAfterCreate removeObjectForKey: adUnitIdentifier];
        }
        
        [adView loadAd];
        
        // Disable auto-refresh if publisher sets it before creating the ad view.
        if ( [self.disabledAutoRefreshAdViewAdUnitIdentifiers containsObject: adUnitIdentifier] )
        {
            [adView stopAutoRefresh];
        }
        
        // The publisher may have requested to show the banner before it was created. Now that the banner is created, show it.
        if ( [self.adUnitIdentifiersToShowAfterCreate containsObject: adUnitIdentifier] )
        {
            [self showAdViewWithAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
            [self.adUnitIdentifiersToShowAfterCreate removeObject: adUnitIdentifier];
        }
    });
}

- (void)loadAdViewWithAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        MAAdView *adView = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        if ( !adView )
        {
            [self log: @"%@ does not exist for ad unit identifier %@.", adFormat.label, adUnitIdentifier];
            return;
        }
        
        if ( ![self.disabledAutoRefreshAdViewAdUnitIdentifiers containsObject: adUnitIdentifier] )
        {
            if ( [adView isHidden] )
            {
                [self log: @"Auto-refresh will resume when the %@ ad is shown. You should only call LoadBanner() or LoadMRec() if you explicitly pause auto-refresh and want to manually load an ad.", adFormat.label];
                return;
            }
            
            [self log: @"You must stop auto-refresh if you want to manually load %@ ads.", adFormat.label];
            return;
        }
        
        [adView loadAd];
    });
}

- (void)setAdViewBackgroundColorForAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat hexColorCode:(NSString *)hexColorCode
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Setting %@ with ad unit identifier \"%@\" to color: \"%@\"", adFormat, adUnitIdentifier, hexColorCode];
        
        // In some cases, black color may get redrawn on each frame update, resulting in an undesired flicker
        NSString *hexColorCodeToUse = [hexColorCode containsString: @"FF000000"] ? @"FF000001" : hexColorCode;
        UIColor *convertedColor = [UIColor al_colorWithHexString: hexColorCodeToUse];
        
        MAAdView *view = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        self.publisherBannerBackgroundColor = convertedColor;
        self.safeAreaBackground.backgroundColor = view.backgroundColor = convertedColor;
        
        // Position adView to ensure logic that depends on background color is properly run
        [self positionAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
    });
}

- (void)setAdViewPlacement:(nullable NSString *)placement forAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Setting placement \"%@\" for \"%@\" with ad unit identifier \"%@\"", placement, adFormat, adUnitIdentifier];
        
        MAAdView *adView = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        adView.placement = placement;
    });
}

- (void)startAdViewAutoRefreshForAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Starting %@ auto refresh for ad unit identifier \"%@\"", adFormat.label, adUnitIdentifier];
        
        [self.disabledAutoRefreshAdViewAdUnitIdentifiers removeObject: adUnitIdentifier];
        
        MAAdView *adView = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        if ( !adView )
        {
            [self log: @"%@ does not exist for ad unit identifier %@.", adFormat.label, adUnitIdentifier];
            return;
        }
        
        [adView startAutoRefresh];
    });
}

- (void)stopAdViewAutoRefreshForAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Stopping %@ auto refresh for ad unit identifier \"%@\"", adFormat.label, adUnitIdentifier];
        
        [self.disabledAutoRefreshAdViewAdUnitIdentifiers addObject: adUnitIdentifier];
        
        MAAdView *adView = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        if ( !adView )
        {
            [self log: @"%@ does not exist for ad unit identifier %@.", adFormat.label, adUnitIdentifier];
            return;
        }
        
        [adView stopAutoRefresh];
    });
}

- (void)setAdViewWidth:(CGFloat)width forAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Setting width %f for \"%@\" with ad unit identifier \"%@\"", width, adFormat, adUnitIdentifier];
        
        CGFloat minWidth = adFormat.size.width;
        if ( width < minWidth )
        {
            [self log: @"The provided with: %f is smaller than the minimum required width: %f for ad format: %@. Please set the width higher than the minimum required.", width, minWidth, adFormat];
        }
        
        self.adViewWidths[adUnitIdentifier] = @(width);
        [self positionAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
    });
}

- (void)updateAdViewPosition:(NSString *)adViewPosition withOffset:(CGPoint)offset forAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        self.adViewPositions[adUnitIdentifier] = adViewPosition;
        self.adViewOffsets[adUnitIdentifier] = [NSValue valueWithCGPoint: offset];
        [self positionAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
    });
}

- (void)setAdViewExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat key:(NSString *)key value:(nullable NSString *)value
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Setting %@ extra with key: \"%@\" value: \"%@\"", adFormat, key, value];
        
        MAAdView *adView = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        if ( adView )
        {
            [adView setExtraParameterForKey: key value: value];
        }
        else
        {
            [self log: @"%@ does not exist for ad unit identifier %@. Saving extra parameter to be set when it is created.", adFormat, adUnitIdentifier];
            
            // The adView has not yet been created. Store the extra parameters, so that they can be added once the banner has been created.
            NSMutableDictionary<NSString *, NSString *> *extraParameters = self.adViewExtraParametersToSetAfterCreate[adUnitIdentifier];
            if ( !extraParameters )
            {
                extraParameters = [NSMutableDictionary dictionaryWithCapacity: 1];
                self.adViewExtraParametersToSetAfterCreate[adUnitIdentifier] = extraParameters;
            }
            
            extraParameters[key] = value;
        }
        
        // Certain extra parameters need to be handled immediately
        [self handleExtraParameterChangesIfNeededForAdUnitIdentifier: adUnitIdentifier
                                                            adFormat: adFormat
                                                                 key: key
                                                               value: value];
    });
}

- (void)setAdViewLocalExtraParameterForAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat key:(NSString *)key value:(nullable id)value
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Setting %@ local extra with key: \"%@\" value: \"%@\"", adFormat, key, value];
        
        MAAdView *adView = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        if ( adView )
        {
            [adView setLocalExtraParameterForKey: key value: value];
        }
        else
        {
            [self log: @"%@ does not exist for ad unit identifier %@. Saving local extra parameter to be set when it is created.", adFormat, adUnitIdentifier];
            
            // The adView has not yet been created. Store the loca extra parameters, so that they can be added once the adview has been created.
            NSMutableDictionary<NSString *, id> *localExtraParameters = self.adViewLocalExtraParametersToSetAfterCreate[adUnitIdentifier];
            if ( !localExtraParameters )
            {
                localExtraParameters = [NSMutableDictionary dictionaryWithCapacity: 1];
                self.adViewLocalExtraParametersToSetAfterCreate[adUnitIdentifier] = localExtraParameters;
            }
            
            localExtraParameters[key] = value;
        }
    });
}

- (void)setAdViewCustomData:(nullable NSString *)customData forAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        
        MAAdView *adView = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        if ( adView )
        {
            adView.customData = customData;
        }
        else
        {
            [self log: @"%@ does not exist for ad unit identifier %@. Saving custom data to be set when it is created.", adFormat, adUnitIdentifier];
            
            // The adView has not yet been created. Store the custom data, so that they can be added once the AdView has been created.
            self.adViewCustomDataToSetAfterCreate[adUnitIdentifier] = customData;
        }
    });
}

- (void)handleExtraParameterChangesIfNeededForAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat key:(NSString *)key value:(nullable NSString *)value
{
    if ( MAAdFormat.mrec != adFormat )
    {
        if ( [@"force_banner" isEqualToString: key] )
        {
            BOOL shouldForceBanner = [NSNumber al_numberWithString: value].boolValue;
            MAAdFormat *forcedAdFormat = shouldForceBanner ? MAAdFormat.banner : DEVICE_SPECIFIC_ADVIEW_AD_FORMAT;
            
            self.adViewAdFormats[adUnitIdentifier] = forcedAdFormat;
            [self positionAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: forcedAdFormat];
        }
        else if ( [@"adaptive_banner" isEqualToString: key] )
        {
            BOOL shouldUseAdaptiveBanner = [NSNumber al_numberWithString: value].boolValue;
            if ( shouldUseAdaptiveBanner )
            {
                [self.disabledAdaptiveBannerAdUnitIdentifiers removeObject: adUnitIdentifier];
            }
            else
            {
                [self.disabledAdaptiveBannerAdUnitIdentifiers addObject: adUnitIdentifier];
            }
            
            [self positionAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        }
    }
}

- (void)showAdViewWithAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Showing %@ with ad unit identifier \"%@\"", adFormat, adUnitIdentifier];
        
        MAAdView *view = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        if ( !view )
        {
            [self log: @"%@ does not exist for ad unit identifier %@.", adFormat, adUnitIdentifier];
            
            // The adView has not yet been created. Store the ad unit ID, so that it can be displayed once the banner has been created.
            [self.adUnitIdentifiersToShowAfterCreate addObject: adUnitIdentifier];
        }
        else
        {
            // Check edge case where ad may be detatched from view controller
            if ( !view.window.rootViewController )
            {
                [self log: @"%@ missing view controller - re-attaching to %@...", adFormat, KEY_WINDOW.rootViewController];
                
                UIViewController *rootViewController = KEY_WINDOW.rootViewController;
                [rootViewController.view addSubview: view];
                
                [self positionAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
            }
        }
        
        self.safeAreaBackground.hidden = NO;
        view.hidden = NO;
        
        if ( ![self.disabledAutoRefreshAdViewAdUnitIdentifiers containsObject: adUnitIdentifier] )
        {
            [view startAutoRefresh];
        }
    });
}

- (void)hideAdViewWithAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Hiding %@ with ad unit identifier \"%@\"", adFormat, adUnitIdentifier];
        [self.adUnitIdentifiersToShowAfterCreate removeObject: adUnitIdentifier];
        
        MAAdView *view = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        view.hidden = YES;
        self.safeAreaBackground.hidden = YES;
        
        [view stopAutoRefresh];
    });
}

- (void)destroyAdViewWithAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        [self log: @"Destroying %@ with ad unit identifier \"%@\"", adFormat, adUnitIdentifier];
        
        MAAdView *view = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        view.delegate = nil;
        view.revenueDelegate = nil;
        view.adReviewDelegate = nil;
        
        [view removeFromSuperview];
        
        [self.adViews removeObjectForKey: adUnitIdentifier];
        [self.adViewAdFormats removeObjectForKey: adUnitIdentifier];
        [self.adViewPositions removeObjectForKey: adUnitIdentifier];
        [self.adViewOffsets removeObjectForKey: adUnitIdentifier];
        [self.adViewWidths removeObjectForKey: adUnitIdentifier];
        [self.verticalAdViewFormats removeObjectForKey: adUnitIdentifier];
        [self.disabledAdaptiveBannerAdUnitIdentifiers removeObject: adUnitIdentifier];
    });
}

- (void)logInvalidAdFormat:(MAAdFormat *)adFormat
{
    [self log: @"invalid ad format: %@, from %@", adFormat, [NSThread callStackSymbols]];
}

- (void)log:(NSString *)format, ...
{
    va_list valist;
    va_start(valist, format);
    NSString *message = [[NSString alloc] initWithFormat: format arguments: valist];
    va_end(valist);
    
    NSLog(@"[%@] [%@] %@", SDK_TAG, TAG, message);
}

+ (void)log:(NSString *)format, ...
{
    va_list valist;
    va_start(valist, format);
    NSString *message = [[NSString alloc] initWithFormat: format arguments: valist];
    va_end(valist);
    
    NSLog(@"[%@] [%@] %@", SDK_TAG, TAG, message);
}

- (MAInterstitialAd *)retrieveInterstitialForAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    MAInterstitialAd *result = self.interstitials[adUnitIdentifier];
    if ( !result )
    {
        result = [[MAInterstitialAd alloc] initWithAdUnitIdentifier: adUnitIdentifier sdk: self.sdk];
        result.delegate = self;
        result.revenueDelegate = self;
        
        self.interstitials[adUnitIdentifier] = result;
    }
    
    return result;
}

- (MAAppOpenAd *)retrieveAppOpenAdForAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    MAAppOpenAd *result = self.appOpenAds[adUnitIdentifier];
    if ( !result )
    {
        result = [[MAAppOpenAd alloc] initWithAdUnitIdentifier: adUnitIdentifier sdk: self.sdk];
        result.delegate = self;
        result.revenueDelegate = self;
        
        self.appOpenAds[adUnitIdentifier] = result;
    }
    
    return result;
}

- (MARewardedAd *)retrieveRewardedAdForAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    MARewardedAd *result = self.rewardedAds[adUnitIdentifier];
    if ( !result )
    {
        result = [MARewardedAd sharedWithAdUnitIdentifier: adUnitIdentifier sdk: self.sdk];
        result.delegate = self;
        result.revenueDelegate = self;
        
        self.rewardedAds[adUnitIdentifier] = result;
    }
    
    return result;
}

- (MAAdView *)retrieveAdViewForAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    return [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat atPosition: nil withOffset: CGPointZero];
}

- (MAAdView *)retrieveAdViewForAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat atPosition:(NSString *)adViewPosition withOffset:(CGPoint)offset
{
    MAAdView *result = self.adViews[adUnitIdentifier];
    if ( !result && adViewPosition )
    {
        result = [[MAAdView alloc] initWithAdUnitIdentifier: adUnitIdentifier adFormat: adFormat sdk: self.sdk];
        result.userInteractionEnabled = NO;
        result.translatesAutoresizingMaskIntoConstraints = NO;
        result.delegate = self;
        result.revenueDelegate = self;
        
        self.adViews[adUnitIdentifier] = result;
        self.adViewPositions[adUnitIdentifier] = adViewPosition;
        self.adViewOffsets[adUnitIdentifier] = [NSValue valueWithCGPoint: offset];
        
        [KEY_WINDOW.rootViewController.view addSubview: result];
        
        // Allow pubs to pause auto-refresh immediately, by default.
        [result setExtraParameterForKey: @"allow_pause_auto_refresh_immediately" value: @"true"];
    }
    
    return result;
}

- (void)positionAdViewForAd:(MAAd *)ad
{
    [self positionAdViewForAdUnitIdentifier: ad.adUnitIdentifier adFormat: ad.format];
}

- (void)positionAdViewForAdUnitIdentifier:(NSString *)adUnitIdentifier adFormat:(MAAdFormat *)adFormat
{
    max_godot_dispatch_on_main_thread(^{
        MAAdView *adView = [self retrieveAdViewForAdUnitIdentifier: adUnitIdentifier adFormat: adFormat];
        NSString *adViewPosition = self.adViewPositions[adUnitIdentifier];
        NSValue *adViewPositionValue = self.adViewOffsets[adUnitIdentifier];
        CGPoint adViewOffset = [adViewPositionValue CGPointValue];
        BOOL isAdaptiveBannerDisabled = [self.disabledAdaptiveBannerAdUnitIdentifiers containsObject: adUnitIdentifier];
        BOOL isWidthPtsOverridden = self.adViewWidths[adUnitIdentifier] != nil;
        
        UIView *superview = adView.superview;
        if ( !superview ) return;
        
        // Deactivate any previous constraints and reset rotation so that the banner can be positioned again.
        NSArray<NSLayoutConstraint *> *activeConstraints = self.adViewConstraints[adUnitIdentifier];
        [NSLayoutConstraint deactivateConstraints: activeConstraints];
        adView.transform = CGAffineTransformIdentity;
        [self.verticalAdViewFormats removeObjectForKey: adUnitIdentifier];
        
        // Ensure superview contains the safe area background.
        if ( ![superview.subviews containsObject: self.safeAreaBackground] )
        {
            [self.safeAreaBackground removeFromSuperview];
            [superview insertSubview: self.safeAreaBackground belowSubview: adView];
        }
        
        // Deactivate any previous constraints and reset visibility state so that the safe area background can be positioned again.
        [NSLayoutConstraint deactivateConstraints: self.safeAreaBackground.constraints];
        self.safeAreaBackground.hidden = adView.hidden;
        
        //
        // Determine ad width
        //
        CGFloat adViewWidth;
        
        // Check if publisher has overridden width as points
        if ( isWidthPtsOverridden )
        {
            adViewWidth = self.adViewWidths[adUnitIdentifier].floatValue;
        }
        // Top center / bottom center stretches full screen
        else if ( [adViewPosition isEqual: @"top_center"] || [adViewPosition isEqual: @"bottom_center"] )
        {
            adViewWidth = CGRectGetWidth(KEY_WINDOW.bounds);
        }
        // Else use standard widths of 320, 728, or 300
        else
        {
            adViewWidth = adFormat.size.width;
        }
        
        //
        // Determine ad height
        //
        CGFloat adViewHeight;
        
        if ( (adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader) && !isAdaptiveBannerDisabled )
        {
            adViewHeight = [adFormat adaptiveSizeForWidth: adViewWidth].height;
        }
        else
        {
            adViewHeight = adFormat.size.height;
        }
        
        CGSize adViewSize = CGSizeMake(adViewWidth, adViewHeight);
        
        // All positions have constant height
        NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithObject: [adView.heightAnchor constraintEqualToConstant: adViewSize.height]];
        
        UILayoutGuide *layoutGuide;
        if ( @available(iOS 11.0, *) )
        {
            layoutGuide = superview.safeAreaLayoutGuide;
        }
        else
        {
            layoutGuide = superview.layoutMarginsGuide;
        }
        
        if ( [adViewPosition isEqual: @"top_center"] || [adViewPosition isEqual: @"bottom_center"] )
        {
            // Non AdMob banners will still be of 50/90 points tall. Set the auto sizing mask such that the inner ad view is pinned to the bottom or top according to the ad view position.
            if ( !isAdaptiveBannerDisabled )
            {
                adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                
                if ( [@"top_center" isEqual: adViewPosition] )
                {
                    adView.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin;
                }
                else // bottom_center
                {
                    adView.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
                }
            }
            
            // If publisher actually provided a banner background color
            if ( self.publisherBannerBackgroundColor && adFormat != MAAdFormat.mrec )
            {
                if ( isWidthPtsOverridden )
                {
                    [constraints addObjectsFromArray: @[[adView.widthAnchor constraintEqualToConstant: adViewWidth],
                                                        [adView.centerXAnchor constraintEqualToAnchor: layoutGuide.centerXAnchor],
                                                        [self.safeAreaBackground.widthAnchor constraintEqualToConstant: adViewWidth],
                                                        [self.safeAreaBackground.centerXAnchor constraintEqualToAnchor: layoutGuide.centerXAnchor]]];
                    
                    if ( [adViewPosition isEqual: @"top_center"] )
                    {
                        [constraints addObjectsFromArray: @[[adView.topAnchor constraintEqualToAnchor: layoutGuide.topAnchor],
                                                            [self.safeAreaBackground.topAnchor constraintEqualToAnchor: superview.topAnchor],
                                                            [self.safeAreaBackground.bottomAnchor constraintEqualToAnchor: adView.topAnchor]]];
                    }
                    else // bottom_center
                    {
                        [constraints addObjectsFromArray: @[[adView.bottomAnchor constraintEqualToAnchor: layoutGuide.bottomAnchor],
                                                            [self.safeAreaBackground.topAnchor constraintEqualToAnchor: adView.bottomAnchor],
                                                            [self.safeAreaBackground.bottomAnchor constraintEqualToAnchor: superview.bottomAnchor]]];
                    }
                }
                else
                {
                    [constraints addObjectsFromArray: @[[adView.leftAnchor constraintEqualToAnchor: superview.leftAnchor],
                                                        [adView.rightAnchor constraintEqualToAnchor: superview.rightAnchor],
                                                        [self.safeAreaBackground.leftAnchor constraintEqualToAnchor: superview.leftAnchor],
                                                        [self.safeAreaBackground.rightAnchor constraintEqualToAnchor: superview.rightAnchor]]];
                    
                    if ( [adViewPosition isEqual: @"top_center"] )
                    {
                        [constraints addObjectsFromArray: @[[adView.topAnchor constraintEqualToAnchor: layoutGuide.topAnchor],
                                                            [self.safeAreaBackground.topAnchor constraintEqualToAnchor: superview.topAnchor],
                                                            [self.safeAreaBackground.bottomAnchor constraintEqualToAnchor: adView.topAnchor]]];
                    }
                    else // bottom_center
                    {
                        [constraints addObjectsFromArray: @[[adView.bottomAnchor constraintEqualToAnchor: layoutGuide.bottomAnchor],
                                                            [self.safeAreaBackground.topAnchor constraintEqualToAnchor: adView.bottomAnchor],
                                                            [self.safeAreaBackground.bottomAnchor constraintEqualToAnchor: superview.bottomAnchor]]];
                    }
                }
            }
            // If pub does not have a background color set or this is not a banner
            else
            {
                self.safeAreaBackground.hidden = YES;
                
                [constraints addObjectsFromArray: @[[adView.widthAnchor constraintEqualToConstant: adViewWidth],
                                                    [adView.centerXAnchor constraintEqualToAnchor: layoutGuide.centerXAnchor]]];
                
                if ( [adViewPosition isEqual: @"top_center"] )
                {
                    [constraints addObject: [adView.topAnchor constraintEqualToAnchor: layoutGuide.topAnchor]];
                }
                else // BottomCenter
                {
                    [constraints addObject: [adView.bottomAnchor constraintEqualToAnchor: layoutGuide.bottomAnchor]];
                }
            }
        }
        // Check if the publisher wants vertical banners.
        else if ( [adViewPosition isEqual: @"center_left"] || [adViewPosition isEqual: @"center_right"] )
        {
            if ( MAAdFormat.mrec == adFormat )
            {
                [constraints addObject: [adView.widthAnchor constraintEqualToConstant: adViewSize.width]];
                
                if ( [adViewPosition isEqual: @"center_left"] )
                {
                    [constraints addObjectsFromArray: @[[adView.centerYAnchor constraintEqualToAnchor: layoutGuide.centerYAnchor],
                                                        [adView.leftAnchor constraintEqualToAnchor: superview.leftAnchor]]];
                    
                    [constraints addObjectsFromArray: @[[self.safeAreaBackground.rightAnchor constraintEqualToAnchor: layoutGuide.leftAnchor],
                                                        [self.safeAreaBackground.leftAnchor constraintEqualToAnchor: superview.leftAnchor]]];
                }
                else // center_right
                {
                    [constraints addObjectsFromArray: @[[adView.centerYAnchor constraintEqualToAnchor: layoutGuide.centerYAnchor],
                                                        [adView.rightAnchor constraintEqualToAnchor: superview.rightAnchor]]];
                    
                    [constraints addObjectsFromArray: @[[self.safeAreaBackground.leftAnchor constraintEqualToAnchor: layoutGuide.rightAnchor],
                                                        [self.safeAreaBackground.rightAnchor constraintEqualToAnchor: superview.rightAnchor]]];
                }
            }
            else
            {
                /* Align the center of the view such that when rotated it snaps into place.
                 *
                 *                  +---+---+-------+
                 *                  |   |           |
                 *                  |   |           |
                 *                  |   |           |
                 *                  |   |           |
                 *                  |   |           |
                 *                  |   |           |
                 *    +-------------+---+-----------+--+
                 *    |             | + |   +       |  |
                 *    +-------------+---+-----------+--+
                 *                  <+> |           |
                 *                  |+  |           |
                 *                  ||  |           |
                 *                  ||  |           |
                 *                  ||  |           |
                 *                  ||  |           |
                 *                  +|--+-----------+
                 *                   v
                 *            Banner Half Height
                 */
                self.safeAreaBackground.hidden = YES;
                
                adView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
                
                CGFloat width;
                // If the publiser has a background color set - set the width to the height of the screen, to span the ad across the screen after it is rotated.
                if ( self.publisherBannerBackgroundColor )
                {
                    if ( isWidthPtsOverridden )
                    {
                        width = adViewWidth;
                    }
                    else
                    {
                        width = CGRectGetHeight(KEY_WINDOW.bounds);
                    }
                }
                // Otherwise - we shouldn't span the banner the width of the realm (there might be user-interactable UI on the sides)
                else
                {
                    width = adViewWidth;
                }
                [constraints addObject: [adView.widthAnchor constraintEqualToConstant: width]];
                
                // Set constraints such that the center of the banner aligns with the center left or right as needed. That way, once rotated, the banner snaps into place.
                [constraints addObject: [adView.centerYAnchor constraintEqualToAnchor: superview.centerYAnchor]];
                
                // Place the center of the banner half the height of the banner away from the side. If we align the center exactly with the left/right anchor, only half the banner will be visible.
                CGFloat bannerHalfHeight = adViewSize.height / 2.0;
                UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
                if ( [adViewPosition isEqual: @"center_left"] )
                {
                    NSLayoutAnchor *anchor = ( orientation == UIInterfaceOrientationLandscapeRight ) ? layoutGuide.leftAnchor : superview.leftAnchor;
                    [constraints addObject: [adView.centerXAnchor constraintEqualToAnchor: anchor constant: bannerHalfHeight]];
                }
                else // CenterRight
                {
                    NSLayoutAnchor *anchor = ( orientation == UIInterfaceOrientationLandscapeLeft ) ? layoutGuide.rightAnchor : superview.rightAnchor;
                    [constraints addObject: [adView.centerXAnchor constraintEqualToAnchor: anchor constant: -bannerHalfHeight]];
                }
                
                // Store the ad view with format, so that it can be updated when the orientation changes.
                self.verticalAdViewFormats[adUnitIdentifier] = adFormat;
                
                // If adaptive - make top flexible since we anchor with the bottom of the banner at the edge of the screen
                if ( !isAdaptiveBannerDisabled )
                {
                    adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
                }
            }
        }
        // Otherwise, publisher will likely construct his own views around the adview
        else
        {
            self.safeAreaBackground.hidden = YES;
            
            [constraints addObject: [adView.widthAnchor constraintEqualToConstant: adViewWidth]];
            
            if ( [adViewPosition isEqual: @"top_left"] )
            {
                [constraints addObjectsFromArray: @[[adView.leftAnchor constraintEqualToAnchor: superview.leftAnchor constant: adViewOffset.x],
                                                    [adView.topAnchor constraintEqualToAnchor: layoutGuide.topAnchor constant: adViewOffset.y]]];
            }
            else if ( [adViewPosition isEqual: @"top_right"] )
            {
                [constraints addObjectsFromArray: @[[adView.topAnchor constraintEqualToAnchor: layoutGuide.topAnchor],
                                                    [adView.rightAnchor constraintEqualToAnchor: superview.rightAnchor]]];
            }
            else if ( [adViewPosition isEqual: @"centered"] )
            {
                [constraints addObjectsFromArray: @[[adView.centerXAnchor constraintEqualToAnchor: layoutGuide.centerXAnchor],
                                                    [adView.centerYAnchor constraintEqualToAnchor: layoutGuide.centerYAnchor]]];
            }
            else if ( [adViewPosition isEqual: @"bottom_left"] )
            {
                [constraints addObjectsFromArray: @[[adView.bottomAnchor constraintEqualToAnchor: layoutGuide.bottomAnchor],
                                                    [adView.leftAnchor constraintEqualToAnchor: superview.leftAnchor]]];
            }
            else if ( [adViewPosition isEqual: @"bottom_right"] )
            {
                [constraints addObjectsFromArray: @[[adView.bottomAnchor constraintEqualToAnchor: layoutGuide.bottomAnchor],
                                                    [adView.rightAnchor constraintEqualToAnchor: superview.rightAnchor]]];
            }
        }
        
        self.adViewConstraints[adUnitIdentifier] = constraints;
        
        [NSLayoutConstraint activateConstraints: constraints];
    });
}

- (MAAdFormat *)adViewAdFormatForAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    if ( self.adViewAdFormats[adUnitIdentifier] )
    {
        return self.adViewAdFormats[adUnitIdentifier];
    }
    else
    {
        return DEVICE_SPECIFIC_ADVIEW_AD_FORMAT;
    }
}

- (MAAd *)adWithAdUnitIdentifier:(NSString *)adUnitIdentifier
{
    @synchronized ( self.adInfoDictLock )
    {
        return self.adInfoDict[adUnitIdentifier];
    }
}

@end
