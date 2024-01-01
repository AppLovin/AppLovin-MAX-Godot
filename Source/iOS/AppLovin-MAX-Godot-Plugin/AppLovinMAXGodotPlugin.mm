//
//  AppLovinMAXGodotPlugin.mm
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/15/23.
//

#import "AppLovinMAXGodotPlugin.h"
#import "AppLovinMAXGodotSignal.h"
#import "NSArray+AppLovinMAXGodotPlugin.h"
#import "NSDictionary+AppLovinMAXGodotPlugin.h"
#import "NSObject+AppLovinMAXGodotPlugin.h"
#import "NSString+AppLovinMAXGodotPlugin.h"

#include "core/config/engine.h"

#pragma mark - AppLovinMAXGodotPlugin Fields

AppLovinMAXGodotPlugin *_plugin_instance;
AppLovinMAXGodotManager *AppLovinMAXGodotPlugin::_appLovinMAX;
ALSdk *AppLovinMAXGodotPlugin::_sdk;

bool AppLovinMAXGodotPlugin::_isSdkInitialized;

NSString const *TAG = @"AppLovinMAXGodotPlugin";

NSString *AppLovinMAXGodotPlugin::_userIdentifierToSet;
NSString *AppLovinMAXGodotPlugin::_userSegmentNameToSet;
NSArray<NSString *> *AppLovinMAXGodotPlugin::_testDeviceIdentifiersToSet;
NSNumber *AppLovinMAXGodotPlugin::_verboseLoggingToSet;
NSNumber *AppLovinMAXGodotPlugin::_creativeDebuggerEnabledToSet;
NSNumber *AppLovinMAXGodotPlugin::_exceptionHandlerEnabledToSet;
NSNumber *AppLovinMAXGodotPlugin::_locationCollectionEnabledToSet;
NSNumber *AppLovinMAXGodotPlugin::_targetingYearOfBirth;
NSString *AppLovinMAXGodotPlugin::_targetingGender;
NSNumber *AppLovinMAXGodotPlugin::_targetingMaximumAdContentRating;
NSString *AppLovinMAXGodotPlugin::_targetingEmail;
NSString *AppLovinMAXGodotPlugin::_targetingPhoneNumber;
NSArray<NSString *> *AppLovinMAXGodotPlugin::_targetingKeywords;
NSArray<NSString *> *AppLovinMAXGodotPlugin::_targetingInterests;
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
    
    ClassDB::bind_method(D_METHOD("set_user_id"), &AppLovinMAXGodotPlugin::set_user_id);
    ClassDB::bind_method(D_METHOD("get_sdk_configuration"), &AppLovinMAXGodotPlugin::get_sdk_configuration);
    ClassDB::bind_method(D_METHOD("get_ad_value", "ad_unit_identifier", "key"), &AppLovinMAXGodotPlugin::get_ad_value, DEFVAL(""), DEFVAL(""));
    
    ClassDB::bind_method(D_METHOD("is_tablet"), &AppLovinMAXGodotPlugin::is_tablet);
    ClassDB::bind_method(D_METHOD("is_physical_device"), &AppLovinMAXGodotPlugin::is_physical_device);
    
    // Privacy
    ClassDB::bind_method(D_METHOD("set_has_user_consent"), &AppLovinMAXGodotPlugin::set_has_user_consent);
    ClassDB::bind_method(D_METHOD("get_has_user_consent"), &AppLovinMAXGodotPlugin::get_has_user_consent);
    ClassDB::bind_method(D_METHOD("is_user_consent_set"), &AppLovinMAXGodotPlugin::is_user_consent_set);

    ClassDB::bind_method(D_METHOD("set_is_age_restricted_user"), &AppLovinMAXGodotPlugin::set_is_age_restricted_user);
    ClassDB::bind_method(D_METHOD("is_age_restricted_user"), &AppLovinMAXGodotPlugin::is_age_restricted_user);
    ClassDB::bind_method(D_METHOD("is_age_restricted_user_set"), &AppLovinMAXGodotPlugin::is_age_restricted_user_set);

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
    
    // User Segment
    ClassDB::bind_method(D_METHOD("set_user_segment_field"), &AppLovinMAXGodotPlugin::set_user_segment_field);
    
    // Targeting Data
    ClassDB::bind_method(D_METHOD("set_targeting_data_year_of_birth"), &AppLovinMAXGodotPlugin::set_targeting_data_year_of_birth);
    ClassDB::bind_method(D_METHOD("set_targeting_data_gender"), &AppLovinMAXGodotPlugin::set_targeting_data_gender);
    ClassDB::bind_method(D_METHOD("set_targeting_data_maximum_ad_content_rating"), &AppLovinMAXGodotPlugin::set_targeting_data_maximum_ad_content_rating);
    ClassDB::bind_method(D_METHOD("set_targeting_data_email"), &AppLovinMAXGodotPlugin::set_targeting_data_email);
    ClassDB::bind_method(D_METHOD("set_targeting_data_phone_number"), &AppLovinMAXGodotPlugin::set_targeting_data_phone_number);
    ClassDB::bind_method(D_METHOD("set_targeting_data_keywords"), &AppLovinMAXGodotPlugin::set_targeting_data_keywords);
    ClassDB::bind_method(D_METHOD("set_targeting_data_interests"), &AppLovinMAXGodotPlugin::set_targeting_data_interests);
    ClassDB::bind_method(D_METHOD("clear_all_targeting_data"), &AppLovinMAXGodotPlugin::clear_all_targeting_data);

    // Settings
    ClassDB::bind_method(D_METHOD("set_muted"), &AppLovinMAXGodotPlugin::set_muted);
    ClassDB::bind_method(D_METHOD("is_muted"), &AppLovinMAXGodotPlugin::is_muted);
    ClassDB::bind_method(D_METHOD("set_verbose_logging"), &AppLovinMAXGodotPlugin::set_verbose_logging);
    ClassDB::bind_method(D_METHOD("is_verbose_logging_enabled"), &AppLovinMAXGodotPlugin::is_verbose_logging_enabled);
    ClassDB::bind_method(D_METHOD("set_creative_debugger_enabled"), &AppLovinMAXGodotPlugin::set_creative_debugger_enabled);
    ClassDB::bind_method(D_METHOD("set_test_device_advertising_identifiers"), &AppLovinMAXGodotPlugin::set_test_device_advertising_identifiers);
    ClassDB::bind_method(D_METHOD("set_exception_handler_enabled"), &AppLovinMAXGodotPlugin::set_exception_handler_enabled);
    ClassDB::bind_method(D_METHOD("set_location_collection_enabled"), &AppLovinMAXGodotPlugin::set_location_collection_enabled);
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
    
    if ( _userIdentifierToSet )
    {
        _sdk.userIdentifier = _userIdentifierToSet;
        _userIdentifierToSet = nil;
    }
    
    if ( _userSegmentNameToSet )
    {
        _sdk.userSegment.name = _userSegmentNameToSet;
        _userSegmentNameToSet = nil;
    }
    
    if ( _targetingYearOfBirth )
    {
        _sdk.targetingData.yearOfBirth = _targetingYearOfBirth.intValue <= 0 ? nil : _targetingYearOfBirth;
        _targetingYearOfBirth = nil;
    }
    
    if ( _targetingGender )
    {
        _sdk.targetingData.gender = getAppLovinGender(_targetingGender);
        _targetingGender = nil;
    }

    if ( _targetingMaximumAdContentRating )
    {
        _sdk.targetingData.maximumAdContentRating = getAppLovinAdContentRating(_targetingMaximumAdContentRating.intValue);
        _targetingMaximumAdContentRating = nil;
    }
    
    if ( _targetingEmail )
    {
        _sdk.targetingData.email = _targetingEmail;
        _targetingEmail = nil;
    }
    
    if ( _targetingPhoneNumber )
    {
        _sdk.targetingData.phoneNumber = _targetingPhoneNumber;
        _targetingPhoneNumber = nil;
    }
    
    if ( _targetingKeywords )
    {
        _sdk.targetingData.keywords = _targetingKeywords;
        _targetingKeywords = nil;
    }
    
    if ( _targetingInterests )
    {
        _sdk.targetingData.interests = _targetingInterests;
        _targetingInterests = nil;
    }
    
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

void AppLovinMAXGodotPlugin::set_user_id(String user_id)
{
    if ( _sdk )
    {
        _sdk.userIdentifier = NSSTRING(user_id);
    }
    else
    {
        _userIdentifierToSet = NSSTRING(user_id);
    }
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

void AppLovinMAXGodotPlugin::set_is_age_restricted_user(bool is_age_restricted_user)
{
    [ALPrivacySettings setIsAgeRestrictedUser: is_age_restricted_user];
}

bool AppLovinMAXGodotPlugin::is_age_restricted_user()
{
    return [ALPrivacySettings isAgeRestrictedUser];
}

bool AppLovinMAXGodotPlugin::is_age_restricted_user_set()
{
    return [ALPrivacySettings isAgeRestrictedUserSet];
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

#pragma mark - User Segment

void AppLovinMAXGodotPlugin::set_user_segment_field(String field, String value)
{
    if ( _sdk )
    {
        _sdk.userSegment.name = NSSTRING(value);
    }
    else
    {
        _userSegmentNameToSet = NSSTRING(value);
    }
}
    
#pragma mark - Targeting Data

void AppLovinMAXGodotPlugin::set_targeting_data_year_of_birth(int year_of_birth)
{
    if ( !_sdk )
    {
        _targetingYearOfBirth = @(year_of_birth);
        return;
    }
    
    _sdk.targetingData.yearOfBirth = year_of_birth <= 0 ? nil : @(year_of_birth);
}
    
void AppLovinMAXGodotPlugin::set_targeting_data_gender(String gender)
{
    if ( !_sdk )
    {
        _targetingGender = NSSTRING(gender);
        return;
    }
    
    NSString *genderString = NSSTRING(gender);
    _sdk.targetingData.gender = getAppLovinGender(genderString);
}
    
void AppLovinMAXGodotPlugin::set_targeting_data_maximum_ad_content_rating(int maximum_ad_content_rating)
{
    if ( !_sdk )
    {
        _targetingMaximumAdContentRating = @(maximum_ad_content_rating);
        return;
    }
    
    _sdk.targetingData.maximumAdContentRating = getAppLovinAdContentRating(maximum_ad_content_rating);
}
    
void AppLovinMAXGodotPlugin::set_targeting_data_email(String email)
{
    if ( !_sdk )
    {
        _targetingEmail = NSSTRING(email);
        return;
    }
    
    _sdk.targetingData.email = NSSTRING(email);
}
    
void AppLovinMAXGodotPlugin::set_targeting_data_phone_number(String phone_number)
{
    if ( !_sdk )
    {
        _targetingPhoneNumber = NSSTRING(phone_number);
        return;
    }
    
    _sdk.targetingData.phoneNumber = NSSTRING(phone_number);
}
    
void AppLovinMAXGodotPlugin::set_targeting_data_keywords(Array keywords)
{
    if ( !_sdk )
    {
        _targetingKeywords = NSARRAY(keywords);
        return;
    }
    
    _sdk.targetingData.keywords = NSARRAY(keywords);
}
    
void AppLovinMAXGodotPlugin::set_targeting_data_interests(Array interests)
{
    if ( !_sdk )
    {
        _targetingInterests = NSARRAY(interests);
        return;
    }
    
    _sdk.targetingData.interests = NSARRAY(interests);
}
    
void AppLovinMAXGodotPlugin::clear_all_targeting_data()
{
    if ( !_sdk )
    {
        _targetingYearOfBirth = nil;
        _targetingGender = nil;
        _targetingMaximumAdContentRating = nil;
        _targetingEmail = nil;
        _targetingPhoneNumber = nil;
        _targetingKeywords = nil;
        _targetingInterests = nil;
        return;
    }
    
    [_sdk.targetingData clearAll];
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

void AppLovinMAXGodotPlugin::set_location_collection_enabled(bool enabled)
{
    if ( _sdk )
    {
        _sdk.settings.locationCollectionEnabled = enabled;
        _locationCollectionEnabledToSet = nil;
    }
    else
    {
        _locationCollectionEnabledToSet = @(enabled);
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
    
    if ( _locationCollectionEnabledToSet )
    {
        settings.locationCollectionEnabled = _locationCollectionEnabledToSet.boolValue;
        _locationCollectionEnabledToSet = nil;
    }
    
    settings.initializationAdUnitIdentifiers = NSARRAY(ad_unit_identifiers);

    // Set the meta data to settings.
    NSMutableDictionary<NSString *, NSString *> *metaDataDict = [settings valueForKey: @"metaData"];
    [metaDataDict addEntriesFromDictionary: NSDICTIONARY(metadata)];
    
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

ALGender AppLovinMAXGodotPlugin::getAppLovinGender(NSString *gender_string)
{
    if ( [@"F" al_isEqualToStringIgnoringCase: gender_string] )
    {
        return ALGenderFemale;
    }
    else if ( [@"M" al_isEqualToStringIgnoringCase: gender_string] )
    {
        return ALGenderMale;
    }
    else if ( [@"O" al_isEqualToStringIgnoringCase: gender_string] )
    {
        return ALGenderOther;
    }
    
    return ALGenderUnknown;
}

ALAdContentRating AppLovinMAXGodotPlugin::getAppLovinAdContentRating(int maximum_ad_content_rating)
{
    if ( maximum_ad_content_rating == 1 )
    {
        return ALAdContentRatingAllAudiences;
    }
    else if ( maximum_ad_content_rating == 2 )
    {
        return ALAdContentRatingEveryoneOverTwelve;
    }
    else if ( maximum_ad_content_rating == 3 )
    {
        return ALAdContentRatingMatureAudiences;
    }
    
    return ALAdContentRatingNone;
}
