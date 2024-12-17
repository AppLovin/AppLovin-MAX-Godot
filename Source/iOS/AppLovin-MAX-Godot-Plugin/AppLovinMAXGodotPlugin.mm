//
//  AppLovinMAXGodotPlugin.mm
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/15/23.
//

#import "AppLovinMAXGodotPlugin.h"
#import "AppLovinMAXGodotSignal.h"
#import "Categories/NSArray+AppLovinMAXGodotPlugin.h"
#import "Categories/NSDictionary+AppLovinMAXGodotPlugin.h"
#import "Categories/NSObject+AppLovinMAXGodotPlugin.h"
#import "Categories/NSString+AppLovinMAXGodotPlugin.h"

#define DISABLE_DEPRECATED
#define DEBUG_METHODS_ENABLED
#include "core/config/engine.h"

#pragma mark - AppLovinMAXGodotPlugin Fields

AppLovinMAXGodotPlugin *_plugin_instance;
AppLovinMAXGodotManager *AppLovinMAXGodotPlugin::_appLovinMAX;
ALSdk *AppLovinMAXGodotPlugin::_sdk;

bool AppLovinMAXGodotPlugin::_isSdkInitialized;

NSString const *TAG = @"AppLovinMAXGodotPlugin";

NSArray<NSString *> *AppLovinMAXGodotPlugin::_testDeviceIdentifiersToSet;
NSNumber *AppLovinMAXGodotPlugin::_verboseLoggingToSet;
NSNumber *AppLovinMAXGodotPlugin::_creativeDebuggerEnabledToSet;
NSNumber *AppLovinMAXGodotPlugin::_exceptionHandlerEnabledToSet;
NSMutableDictionary<NSString *, NSString *> *AppLovinMAXGodotPlugin::_extraParametersToSet;
NSObject *AppLovinMAXGodotPlugin::_extraParametersToSetLock;

#pragma mark - AppLovinMAXGodotPlugin Initialization

void applovin_max_godot_plugin_init()
{
    _plugin_instance = memnew(AppLovinMAXGodotPlugin);
    Engine::get_singleton()->add_singleton(Engine::Singleton("AppLovinMAXGodotPlugin", _plugin_instance));
}

void applovin_max_godot_plugin_deinit()
{
    if ( _plugin_instance )
    {
       memdelete(_plugin_instance);
   }
}

AppLovinMAXGodotPlugin::AppLovinMAXGodotPlugin()
{
    ERR_FAIL_COND(_plugin_instance != NULL);
    
    _plugin_instance = this;
    _appLovinMAX = [AppLovinMAXGodotManager shared];
    _extraParametersToSet = [NSMutableDictionary dictionary];
    _extraParametersToSetLock = [[NSObject alloc] init];
}

AppLovinMAXGodotPlugin::~AppLovinMAXGodotPlugin()
{
    if ( this == _plugin_instance )
    {
        _plugin_instance = NULL;
        _appLovinMAX = NULL;
    }
}

AppLovinMAXGodotPlugin *AppLovinMAXGodotPlugin::get_instance() {
    return _plugin_instance;
};

void AppLovinMAXGodotPlugin::_bind_methods()
{
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalSdkInitialization, PropertyInfo(Variant::DICTIONARY, "sdk_configuration")));
    
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalBannerOnAdLoaded,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::STRING, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalBannerOnAdLoadFailed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "error_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalBannerOnAdClicked,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalBannerOnAdRevenuePaid,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalBannerOnAdExpanded,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalBannerOnAdCollapsed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalMRecOnAdLoaded,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalMRecOnAdLoadFailed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "error_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalMRecOnAdClicked,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalMRecOnAdRevenuePaid,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalMRecOnAdExpanded,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalMRecOnAdCollapsed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalInterstitialOnAdLoaded,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalInterstitialOnAdLoadFailed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "error_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalInterstitialOnAdClicked,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalInterstitialOnAdRevenuePaid,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalInterstitialOnAdDisplayed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalInterstitialOnAdDisplayFailed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "error_info"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalInterstitialOnAdHidden,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalAppOpenOnAdLoaded,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalAppOpenOnAdLoadFailed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "error_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalAppOpenOnAdClicked,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalAppOpenOnAdRevenuePaid,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalAppOpenOnAdDisplayed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalAppOpenOnAdDisplayFailed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "error_info"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalAppOpenOnAdHidden,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalRewardedOnAdLoaded,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalRewardedOnAdLoadFailed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "error_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalRewardedOnAdClicked,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalRewardedOnAdRevenuePaid,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalRewardedOnAdDisplayed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalRewardedOnAdDisplayFailed,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "error_info"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalRewardedOnAdHidden,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    ADD_SIGNAL(MethodInfo(AppLovinMAXSignalRewardedOnAdReceivedReward,
                          PropertyInfo(Variant::STRING, "ad_unit_identifier"),
                          PropertyInfo(Variant::DICTIONARY, "reward_info"),
                          PropertyInfo(Variant::DICTIONARY, "ad_info")));
    
    ClassDB::bind_method(D_METHOD("initialize"), &AppLovinMAXGodotPlugin::initialize, DEFVAL(""), DEFVAL(Dictionary()), DEFVAL(Array()));
    ClassDB::bind_method(D_METHOD("is_initialized"), &AppLovinMAXGodotPlugin::is_initialized);
    
    ClassDB::bind_method(D_METHOD("show_mediation_debugger"), &AppLovinMAXGodotPlugin::show_mediation_debugger);
    ClassDB::bind_method(D_METHOD("show_creative_debugger"), &AppLovinMAXGodotPlugin::show_creative_debugger);
    
    ClassDB::bind_method(D_METHOD("get_sdk_configuration"), &AppLovinMAXGodotPlugin::get_sdk_configuration);
    ClassDB::bind_method(D_METHOD("get_ad_value", "ad_unit_identifier", "key"), &AppLovinMAXGodotPlugin::get_ad_value, DEFVAL(""), DEFVAL(""));
    
    ClassDB::bind_method(D_METHOD("is_tablet"), &AppLovinMAXGodotPlugin::is_tablet);
    ClassDB::bind_method(D_METHOD("is_physical_device"), &AppLovinMAXGodotPlugin::is_physical_device);
    
    // Privacy
    ClassDB::bind_method(D_METHOD("set_has_user_consent"), &AppLovinMAXGodotPlugin::set_has_user_consent);
    ClassDB::bind_method(D_METHOD("get_has_user_consent"), &AppLovinMAXGodotPlugin::get_has_user_consent);
    ClassDB::bind_method(D_METHOD("is_user_consent_set"), &AppLovinMAXGodotPlugin::is_user_consent_set);

    ClassDB::bind_method(D_METHOD("set_do_not_sell"), &AppLovinMAXGodotPlugin::set_do_not_sell);
    ClassDB::bind_method(D_METHOD("get_do_not_sell"), &AppLovinMAXGodotPlugin::get_do_not_sell);
    ClassDB::bind_method(D_METHOD("is_do_not_sell_set"), &AppLovinMAXGodotPlugin::is_do_not_sell_set);

    // Banners
    ClassDB::bind_method(D_METHOD("create_banner"), &AppLovinMAXGodotPlugin::create_banner);
    ClassDB::bind_method(D_METHOD("create_banner_xy"), &AppLovinMAXGodotPlugin::create_banner_xy);
    ClassDB::bind_method(D_METHOD("load_banner"), &AppLovinMAXGodotPlugin::load_banner);
    ClassDB::bind_method(D_METHOD("set_banner_placement"), &AppLovinMAXGodotPlugin::set_banner_placement);
    ClassDB::bind_method(D_METHOD("start_banner_auto_refresh"), &AppLovinMAXGodotPlugin::start_banner_auto_refresh);
    ClassDB::bind_method(D_METHOD("stop_banner_auto_refresh"), &AppLovinMAXGodotPlugin::stop_banner_auto_refresh);
    ClassDB::bind_method(D_METHOD("update_banner_position"), &AppLovinMAXGodotPlugin::update_banner_position);
    ClassDB::bind_method(D_METHOD("update_banner_position_xy"), &AppLovinMAXGodotPlugin::update_banner_position_xy);
    ClassDB::bind_method(D_METHOD("set_banner_width"), &AppLovinMAXGodotPlugin::set_banner_width);
    ClassDB::bind_method(D_METHOD("show_banner"), &AppLovinMAXGodotPlugin::show_banner);
    ClassDB::bind_method(D_METHOD("destroy_banner"), &AppLovinMAXGodotPlugin::destroy_banner);
    ClassDB::bind_method(D_METHOD("hide_banner"), &AppLovinMAXGodotPlugin::hide_banner);
    ClassDB::bind_method(D_METHOD("set_banner_background_color"), &AppLovinMAXGodotPlugin::set_banner_background_color);
    ClassDB::bind_method(D_METHOD("set_banner_extra_parameter"), &AppLovinMAXGodotPlugin::set_banner_extra_parameter);
    ClassDB::bind_method(D_METHOD("set_banner_local_extra_parameter"), &AppLovinMAXGodotPlugin::set_banner_local_extra_parameter);
    ClassDB::bind_method(D_METHOD("set_banner_custom_data"), &AppLovinMAXGodotPlugin::set_banner_custom_data);
    ClassDB::bind_method(D_METHOD("get_adaptive_banner_height"), &AppLovinMAXGodotPlugin::get_adaptive_banner_height);

    // MREC
    ClassDB::bind_method(D_METHOD("create_mrec"), &AppLovinMAXGodotPlugin::create_mrec);
    ClassDB::bind_method(D_METHOD("create_mrec_xy"), &AppLovinMAXGodotPlugin::create_mrec_xy);
    ClassDB::bind_method(D_METHOD("load_mrec"), &AppLovinMAXGodotPlugin::load_mrec);
    ClassDB::bind_method(D_METHOD("set_mrec_placement"), &AppLovinMAXGodotPlugin::set_mrec_placement);
    ClassDB::bind_method(D_METHOD("start_mrec_auto_refresh"), &AppLovinMAXGodotPlugin::start_mrec_auto_refresh);
    ClassDB::bind_method(D_METHOD("stop_mrec_auto_refresh"), &AppLovinMAXGodotPlugin::stop_mrec_auto_refresh);
    ClassDB::bind_method(D_METHOD("update_mrec_position"), &AppLovinMAXGodotPlugin::update_mrec_position);
    ClassDB::bind_method(D_METHOD("update_mrec_position_xy"), &AppLovinMAXGodotPlugin::update_mrec_position_xy);
    ClassDB::bind_method(D_METHOD("show_mrec"), &AppLovinMAXGodotPlugin::show_mrec);
    ClassDB::bind_method(D_METHOD("destroy_mrec"), &AppLovinMAXGodotPlugin::destroy_mrec);
    ClassDB::bind_method(D_METHOD("hide_mrec"), &AppLovinMAXGodotPlugin::hide_mrec);
    ClassDB::bind_method(D_METHOD("set_mrec_extra_parameter"), &AppLovinMAXGodotPlugin::set_mrec_extra_parameter);
    ClassDB::bind_method(D_METHOD("set_mrec_local_extra_parameter"), &AppLovinMAXGodotPlugin::set_mrec_local_extra_parameter);
    ClassDB::bind_method(D_METHOD("set_mrec_custom_data"), &AppLovinMAXGodotPlugin::set_mrec_custom_data);

    // Interstitials
    ClassDB::bind_method(D_METHOD("load_interstitial"), &AppLovinMAXGodotPlugin::load_interstitial);
    ClassDB::bind_method(D_METHOD("is_interstitial_ready"), &AppLovinMAXGodotPlugin::is_interstitial_ready);
    ClassDB::bind_method(D_METHOD("show_interstitial"), &AppLovinMAXGodotPlugin::show_interstitial, DEFVAL(""), DEFVAL(""), DEFVAL(""));
    ClassDB::bind_method(D_METHOD("set_interstitial_extra_parameter"), &AppLovinMAXGodotPlugin::set_interstitial_extra_parameter);
    ClassDB::bind_method(D_METHOD("set_interstitial_local_extra_parameter"), &AppLovinMAXGodotPlugin::set_interstitial_local_extra_parameter);

    // App Open
    ClassDB::bind_method(D_METHOD("load_appopen_ad"), &AppLovinMAXGodotPlugin::load_appopen_ad);
    ClassDB::bind_method(D_METHOD("is_appopen_ad_ready"), &AppLovinMAXGodotPlugin::is_appopen_ad_ready);
    ClassDB::bind_method(D_METHOD("show_appopen_ad"), &AppLovinMAXGodotPlugin::show_appopen_ad, DEFVAL(""), DEFVAL(""), DEFVAL(""));
    ClassDB::bind_method(D_METHOD("set_appopen_ad_extra_parameter"), &AppLovinMAXGodotPlugin::set_appopen_ad_extra_parameter);
    ClassDB::bind_method(D_METHOD("set_appopen_ad_local_extra_parameter"), &AppLovinMAXGodotPlugin::set_appopen_ad_local_extra_parameter);

    // Rewarded
    ClassDB::bind_method(D_METHOD("load_rewarded_ad"), &AppLovinMAXGodotPlugin::load_rewarded_ad);
    ClassDB::bind_method(D_METHOD("is_rewarded_ad_ready"), &AppLovinMAXGodotPlugin::is_rewarded_ad_ready);
    ClassDB::bind_method(D_METHOD("show_rewarded_ad"), &AppLovinMAXGodotPlugin::show_rewarded_ad, DEFVAL(""), DEFVAL(""), DEFVAL(""));
    ClassDB::bind_method(D_METHOD("set_rewarded_ad_extra_parameter"), &AppLovinMAXGodotPlugin::set_rewarded_ad_extra_parameter);
    ClassDB::bind_method(D_METHOD("set_rewarded_ad_local_extra_parameter"), &AppLovinMAXGodotPlugin::set_rewarded_ad_local_extra_parameter);

    // Event Tracking
    ClassDB::bind_method(D_METHOD("track_event"), &AppLovinMAXGodotPlugin::track_event);

    // Settings
    ClassDB::bind_method(D_METHOD("set_muted"), &AppLovinMAXGodotPlugin::set_muted);
    ClassDB::bind_method(D_METHOD("is_muted"), &AppLovinMAXGodotPlugin::is_muted);
    ClassDB::bind_method(D_METHOD("set_verbose_logging"), &AppLovinMAXGodotPlugin::set_verbose_logging);
    ClassDB::bind_method(D_METHOD("is_verbose_logging_enabled"), &AppLovinMAXGodotPlugin::is_verbose_logging_enabled);
    ClassDB::bind_method(D_METHOD("set_creative_debugger_enabled"), &AppLovinMAXGodotPlugin::set_creative_debugger_enabled);
    ClassDB::bind_method(D_METHOD("set_test_device_advertising_identifiers"), &AppLovinMAXGodotPlugin::set_test_device_advertising_identifiers);
    ClassDB::bind_method(D_METHOD("set_exception_handler_enabled"), &AppLovinMAXGodotPlugin::set_exception_handler_enabled);
    ClassDB::bind_method(D_METHOD("set_extra_parameter"), &AppLovinMAXGodotPlugin::set_extra_parameter);
}

#pragma mark - SDK Initialization

void AppLovinMAXGodotPlugin::initialize(String sdk_key, Dictionary metadata, Array ad_unit_identifiers)
{
    NSString *sdkKey = NSSTRING(sdk_key);
    if ( [sdkKey al_isValidString] )
    {
        NSDictionary *infoDict = NSBundle.mainBundle.infoDictionary;
        [infoDict setValue: sdkKey forKey: @"AppLovinSdkKey"];
    }
    
    _sdk = [_appLovinMAX initializeSdkWithSettings: generateSDKSettings(ad_unit_identifiers, metadata)
                            andCompletionHandler:^(ALSdkConfiguration *configuration) {
        _isSdkInitialized = true;
        
        emit_signal(AppLovinMAXSignalSdkInitialization, get_sdk_configuration());
    }];
    
    setPendingExtraParametersIfNeeded( _sdk.settings );
}

bool AppLovinMAXGodotPlugin::is_initialized()
{
    return _isSdkInitialized;
}

void AppLovinMAXGodotPlugin::show_mediation_debugger()
{
    if ( !_sdk )
    {
        NSLog(@"[%@] Failed to show mediation debugger - please ensure the AppLovin MAX Godot Plugin has been initialized by calling 'AppLovinMAX.initialize()'!", TAG);
        return;
    }
    
    [_sdk showMediationDebugger];
}

void AppLovinMAXGodotPlugin::show_creative_debugger()
{
    if ( !_sdk )
    {
        NSLog(@"[%@] Failed to show creative debugger - please ensure the AppLovin MAX Godot Plugin has been initialized by calling 'AppLovinMAX.initialize()'!", TAG);
        return;
    }
    
    [_sdk showCreativeDebugger];
}

Dictionary AppLovinMAXGodotPlugin::get_sdk_configuration()
{
    if ( !_sdk )
    {
        return Dictionary();
    }
    
    Dictionary sdk_configuration = Dictionary();
    sdk_configuration["countryCode"] = _sdk.configuration.countryCode;
    sdk_configuration["appTrackingStatus"] = @(_sdk.configuration.appTrackingTransparencyStatus).stringValue; // Deliberately name it `appTrackingStatus` to be a bit more generic (in case Android introduces a similar concept)
    sdk_configuration["isSuccessfullyInitialized"] = [_sdk isInitialized];
    sdk_configuration["isTestModeEnabled"] = [_sdk.configuration isTestModeEnabled];
    return sdk_configuration;
}

String AppLovinMAXGodotPlugin::get_ad_value(String ad_unit_identifier, String key)
{
    return [_appLovinMAX adValueForAdUnitIdentifier: NSSTRING(ad_unit_identifier) withKey: NSSTRING(ad_unit_identifier)].alg_godotString;
}

bool AppLovinMAXGodotPlugin::is_tablet()
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

bool AppLovinMAXGodotPlugin::is_physical_device()
{
    return !ALUtils.simulator;
}

#pragma mark - Privacy

void AppLovinMAXGodotPlugin::set_has_user_consent(bool has_user_consent)
{
    [ALPrivacySettings setHasUserConsent: has_user_consent];
}

bool AppLovinMAXGodotPlugin::get_has_user_consent()
{
    return [ALPrivacySettings hasUserConsent];
}

bool AppLovinMAXGodotPlugin::is_user_consent_set()
{
    return [ALPrivacySettings isUserConsentSet];
}

void AppLovinMAXGodotPlugin::set_do_not_sell(bool do_not_sell)
{
    [ALPrivacySettings setDoNotSell: do_not_sell];
}

bool AppLovinMAXGodotPlugin::get_do_not_sell()
{
    return [ALPrivacySettings isDoNotSell];
}

bool AppLovinMAXGodotPlugin::is_do_not_sell_set()
{
    return [ALPrivacySettings isDoNotSellSet];
}

#pragma mark - Banners

void AppLovinMAXGodotPlugin::create_banner(String ad_unit_identifier, String banner_position)
{
    [_appLovinMAX createBannerWithAdUnitIdentifier: NSSTRING(ad_unit_identifier) atPosition: NSSTRING(banner_position)];
}

void AppLovinMAXGodotPlugin::create_banner_xy(String ad_unit_identifier, float x, float y)
{
    [_appLovinMAX createBannerWithAdUnitIdentifier: NSSTRING(ad_unit_identifier) x: x y: y];
}

void AppLovinMAXGodotPlugin::load_banner(String ad_unit_identifier)
{
    [_appLovinMAX loadBannerWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::set_banner_placement(String ad_unit_identifier, String placement)
{
    [_appLovinMAX setBannerPlacement: NSSTRING(placement) forAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::start_banner_auto_refresh(String ad_unit_identifier)
{
    [_appLovinMAX startBannerAutoRefreshForAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::stop_banner_auto_refresh(String ad_unit_identifier)
{
    [_appLovinMAX stopBannerAutoRefreshForAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::update_banner_position(String ad_unit_identifier, String banner_position)
{
    [_appLovinMAX updateBannerPosition: NSSTRING(banner_position) forAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::update_banner_position_xy(String ad_unit_identifier, float x, float y)
{
    [_appLovinMAX updateBannerPosition: x y: y forAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::set_banner_width(String ad_unit_identifier, float width)
{
    [_appLovinMAX setBannerWidth: width forAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::show_banner(String ad_unit_identifier)
{
    [_appLovinMAX showBannerWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::destroy_banner(String ad_unit_identifier)
{
    [_appLovinMAX destroyBannerWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::hide_banner(String ad_unit_identifier)
{
    [_appLovinMAX hideBannerWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::set_banner_background_color(String ad_unit_identifier, String hex_color_code_string)
{
    [_appLovinMAX setBannerBackgroundColorForAdUnitIdentifier: NSSTRING(ad_unit_identifier) hexColorCode: NSSTRING(hex_color_code_string)];
}

void AppLovinMAXGodotPlugin::set_banner_extra_parameter(String ad_unit_identifier, String key, String value)
{
    [_appLovinMAX setBannerExtraParameterForAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                                         key: NSSTRING(key)
                                                       value: NSSTRING(value)];
}

void AppLovinMAXGodotPlugin::set_banner_local_extra_parameter(String ad_unit_identifier, String key, Variant value)
{
    [_appLovinMAX setBannerLocalExtraParameterForAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                                              key: NSSTRING(key)
                                                            value: NSOBJECT(value)];
}

void AppLovinMAXGodotPlugin::set_banner_custom_data(String ad_unit_identifier, String custom_data)
{
    [_appLovinMAX setBannerCustomData: NSSTRING(custom_data) forAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

float AppLovinMAXGodotPlugin::get_adaptive_banner_height(float width)
{
    return [AppLovinMAXGodotManager adaptiveBannerHeightForWidth: width];
}

#pragma mark - MREC

void AppLovinMAXGodotPlugin::create_mrec(String ad_unit_identifier, String mrec_position)
{
    [_appLovinMAX createMRecWithAdUnitIdentifier: NSSTRING(ad_unit_identifier) atPosition: NSSTRING(mrec_position)];
}

void AppLovinMAXGodotPlugin::create_mrec_xy(String ad_unit_identifier, float x, float y)
{
    [_appLovinMAX createMRecWithAdUnitIdentifier: NSSTRING(ad_unit_identifier) x: x y: y];
}

void AppLovinMAXGodotPlugin::load_mrec(String ad_unit_identifier)
{
    [_appLovinMAX loadMRecWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::set_mrec_placement(String ad_unit_identifier, String placement)
{
    [_appLovinMAX setMRecPlacement: NSSTRING(placement) forAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::start_mrec_auto_refresh(String ad_unit_identifier)
{
    [_appLovinMAX startMRecAutoRefreshForAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::stop_mrec_auto_refresh(String ad_unit_identifier)
{
    [_appLovinMAX stopMRecAutoRefreshForAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::update_mrec_position(String ad_unit_identifier, String mrec_position)
{
    [_appLovinMAX updateMRecPosition: NSSTRING(mrec_position) forAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::update_mrec_position_xy(String ad_unit_identifier, float x, float y)
{
    [_appLovinMAX updateMRecPosition: x y: y forAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::show_mrec(String ad_unit_identifier)
{
    [_appLovinMAX showMRecWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::destroy_mrec(String ad_unit_identifier)
{
    [_appLovinMAX destroyMRecWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::hide_mrec(String ad_unit_identifier)
{
    [_appLovinMAX hideMRecWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::set_mrec_extra_parameter(String ad_unit_identifier, String key, String value)
{
    [_appLovinMAX setMRecExtraParameterForAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                                       key: NSSTRING(key)
                                                     value: NSSTRING(value)];
}

void AppLovinMAXGodotPlugin::set_mrec_local_extra_parameter(String ad_unit_identifier, String key, Variant value)
{
    [_appLovinMAX setMRecLocalExtraParameterForAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                                            key: NSSTRING(key)
                                                          value: NSOBJECT(value)];
}

void AppLovinMAXGodotPlugin::set_mrec_custom_data(String ad_unit_identifier, String custom_data)
{
    [_appLovinMAX setMRecCustomData: NSSTRING(custom_data) forAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}
    
#pragma mark - Interstitials

void AppLovinMAXGodotPlugin::load_interstitial(String ad_unit_identifier)
{
    [_appLovinMAX loadInterstitialWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

bool AppLovinMAXGodotPlugin::is_interstitial_ready(String ad_unit_identifier)
{
    return [_appLovinMAX isInterstitialReadyWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::show_interstitial(String ad_unit_identifier, String placement, String custom_data)
{
    [_appLovinMAX showInterstitialWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                             placement: NSSTRING(placement)
                                            customData: NSSTRING(custom_data)];
}

void AppLovinMAXGodotPlugin::set_interstitial_extra_parameter(String ad_unit_identifier, String key, String value)
{
    [_appLovinMAX setInterstitialExtraParameterForAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                                               key: NSSTRING(key)
                                                             value: NSSTRING(value)];
}

void AppLovinMAXGodotPlugin::set_interstitial_local_extra_parameter(String ad_unit_identifier, String key, Variant value)
{
    [_appLovinMAX setInterstitialLocalExtraParameterForAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                                                    key: NSSTRING(key)
                                                                  value: NSOBJECT(value)];
}

#pragma mark - App Open

void AppLovinMAXGodotPlugin::load_appopen_ad(String ad_unit_identifier)
{
    [_appLovinMAX loadAppOpenAdWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

bool AppLovinMAXGodotPlugin::is_appopen_ad_ready(String ad_unit_identifier)
{
    return [_appLovinMAX isAppOpenAdReadyWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::show_appopen_ad(String ad_unit_identifier, String placement, String custom_data)
{
    [_appLovinMAX showAppOpenAdWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                          placement: NSSTRING(placement)
                                         customData: NSSTRING(custom_data)];
}

void AppLovinMAXGodotPlugin::set_appopen_ad_extra_parameter(String ad_unit_identifier, String key, String value)
{
    [_appLovinMAX setAppOpenAdExtraParameterForAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                                            key: NSSTRING(key)
                                                          value: NSSTRING(value)];
}

void AppLovinMAXGodotPlugin::set_appopen_ad_local_extra_parameter(String ad_unit_identifier, String key, Variant value)
{
    [_appLovinMAX setAppOpenAdLocalExtraParameterForAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                                                 key: NSSTRING(key)
                                                               value: NSOBJECT(value)];
}
    
#pragma mark - Rewarded

void AppLovinMAXGodotPlugin::load_rewarded_ad(String ad_unit_identifier)
{
    [_appLovinMAX loadRewardedAdWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

bool AppLovinMAXGodotPlugin::is_rewarded_ad_ready(String ad_unit_identifier)
{
    return [_appLovinMAX isRewardedAdReadyWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)];
}

void AppLovinMAXGodotPlugin::show_rewarded_ad(String ad_unit_identifier, String placement, String custom_data)
{
    [_appLovinMAX showRewardedAdWithAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                           placement: NSSTRING(placement)
                                          customData: NSSTRING(custom_data)];
}

void AppLovinMAXGodotPlugin::set_rewarded_ad_extra_parameter(String ad_unit_identifier, String key, String value)
{
    [_appLovinMAX setRewardedAdExtraParameterForAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                                             key: NSSTRING(key)
                                                           value: NSSTRING(value)];
}

void AppLovinMAXGodotPlugin::set_rewarded_ad_local_extra_parameter(String ad_unit_identifier, String key, Variant value)
{
    [_appLovinMAX setRewardedAdLocalExtraParameterForAdUnitIdentifier: NSSTRING(ad_unit_identifier)
                                                                  key: NSSTRING(key)
                                                                value: NSOBJECT(value)];
}
    
#pragma mark - Event Tracking

void AppLovinMAXGodotPlugin::track_event(String name, Dictionary parameters)
{
    [_appLovinMAX trackEvent: NSSTRING(name) parameters: NSDICTIONARY(parameters)];
}
    
#pragma mark - Settings

void AppLovinMAXGodotPlugin::set_muted(bool muted)
{
    if ( !_sdk ) return;
    
    _sdk.settings.muted = muted;
}

bool AppLovinMAXGodotPlugin::is_muted()
{
    if ( !_sdk ) return false;
    
    return _sdk.settings.muted;
}

void AppLovinMAXGodotPlugin::set_verbose_logging(bool enabled)
{
    if ( _sdk )
    {
        _sdk.settings.verboseLoggingEnabled = enabled;
        _verboseLoggingToSet = nil;
    }
    else
    {
        _verboseLoggingToSet = @(enabled);
    }
}

bool AppLovinMAXGodotPlugin::is_verbose_logging_enabled()
{
    if ( _sdk )
    {
        return [_sdk.settings isVerboseLoggingEnabled];
    }
    else if ( _verboseLoggingToSet )
    {
        return _verboseLoggingToSet;
    }

    return false;
}

void AppLovinMAXGodotPlugin::set_creative_debugger_enabled(bool enabled)
{
    if ( _sdk )
    {
        _sdk.settings.creativeDebuggerEnabled = enabled;
        _creativeDebuggerEnabledToSet = nil;
    }
    else
    {
        _creativeDebuggerEnabledToSet = @(enabled);
    }
}

void AppLovinMAXGodotPlugin::set_test_device_advertising_identifiers(Array advertising_identifiers)
{
    NSArray<NSString *> *advertisingIdentifiersArray = NSARRAY(advertising_identifiers);
    _testDeviceIdentifiersToSet = advertisingIdentifiersArray;
}

void AppLovinMAXGodotPlugin::set_exception_handler_enabled(bool enabled)
{
    if ( _sdk )
    {
        _sdk.settings.exceptionHandlerEnabled = enabled;
        _exceptionHandlerEnabledToSet = nil;
    }
    else
    {
        _exceptionHandlerEnabledToSet = @(enabled);
    }
}

void AppLovinMAXGodotPlugin::set_extra_parameter(String key, String value)
{
    NSString *stringKey = NSSTRING(key);
    if ( ![stringKey al_isValidString] )
    {
        NSLog(@"[%@] Failed to set extra parameter for nil or empty key: %@", TAG, stringKey);
        return;
    }
    
    if ( _sdk )
    {
        ALSdkSettings *settings = _sdk.settings;
        [settings setExtraParameterForKey: stringKey value: NSSTRING(value)];
        setPendingExtraParametersIfNeeded( settings );
    }
    else
    {
        @synchronized ( _extraParametersToSetLock )
        {
            _extraParametersToSet[stringKey] = NSSTRING(value);
        }
    }
}

#pragma mark - Utility/Private Methods

ALSdkSettings *AppLovinMAXGodotPlugin::generateSDKSettings(Array ad_unit_identifiers, Dictionary metadata)
{
    ALSdkSettings *settings = [[ALSdkSettings alloc] init];
    
    if ( _testDeviceIdentifiersToSet )
    {
        settings.testDeviceAdvertisingIdentifiers = _testDeviceIdentifiersToSet;
        _testDeviceIdentifiersToSet = nil;
    }
    
    if ( _verboseLoggingToSet )
    {
        settings.verboseLoggingEnabled = _verboseLoggingToSet.boolValue;
        _verboseLoggingToSet = nil;
    }

    if ( _creativeDebuggerEnabledToSet )
    {
        settings.creativeDebuggerEnabled = _creativeDebuggerEnabledToSet.boolValue;
        _creativeDebuggerEnabledToSet = nil;
    }

    if ( _exceptionHandlerEnabledToSet )
    {
        settings.exceptionHandlerEnabled = _exceptionHandlerEnabledToSet.boolValue;
        _exceptionHandlerEnabledToSet = nil;
    }
    
    settings.initializationAdUnitIdentifiers = NSARRAY(ad_unit_identifiers);

    [settings setExtraParameterForKey: @"applovin_godot_metadata" value: NSDICTIONARY(metadata).serializedString];
    
    return settings;
}

void AppLovinMAXGodotPlugin::setPendingExtraParametersIfNeeded(ALSdkSettings *settings)
{
    NSDictionary *extraParameters;
    @synchronized ( _extraParametersToSetLock )
    {
        if ( _extraParametersToSet.count <= 0 ) return;
        
        extraParameters = [NSDictionary dictionaryWithDictionary: _extraParametersToSet];
        [_extraParametersToSet removeAllObjects];
    }
    
    for ( NSString *key in extraParameters.allKeys )
    {
        [settings setExtraParameterForKey: key value: extraParameters[key]];
    }
}
