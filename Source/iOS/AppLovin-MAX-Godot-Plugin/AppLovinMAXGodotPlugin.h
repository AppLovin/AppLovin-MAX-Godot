//
//  AppLovinMAXGodotPlugin.h
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/15/23.
//


#import <Foundation/Foundation.h>

#import "AppLovinMAXGodotManager.h"

#include "core/object/class_db.h"

void applovin_max_godot_plugin_init();
void applovin_max_godot_plugin_deinit();

class AppLovinMAXGodotPlugin : public Object
{
    GDCLASS(AppLovinMAXGodotPlugin, Object);
    
    static void _bind_methods();
    
    static AppLovinMAXGodotManager *_appLovinMAX;
    static ALSdk *_sdk;
    
    static bool _isSdkInitialized;
    
    // Store these values if pub attempts to set it before calling _MaxInitializeSdk()
    static NSString *_userIdentifierToSet;
    static NSString *_userSegmentNameToSet;
    static NSArray<NSString *> *_testDeviceIdentifiersToSet;
    static NSNumber *_verboseLoggingToSet;
    static NSNumber *_creativeDebuggerEnabledToSet;
    static NSNumber *_exceptionHandlerEnabledToSet;
    static NSNumber *_locationCollectionEnabledToSet;
    static NSNumber *_targetingYearOfBirth;
    static NSString *_targetingGender;
    static NSNumber *_targetingMaximumAdContentRating;
    static NSString *_targetingEmail;
    static NSString *_targetingPhoneNumber;
    static NSArray<NSString *> *_targetingKeywords;
    static NSArray<NSString *> *_targetingInterests;
    static NSMutableDictionary<NSString *, NSString *> *_extraParametersToSet;
    static NSObject *_extraParametersToSetLock;
    
    ALSdkSettings *generateSDKSettings(Array ad_unit_identifiers, Dictionary metadata);
    void setPendingExtraParametersIfNeeded(ALSdkSettings *settings);
    ALGender getAppLovinGender(NSString *gender_string);
    ALAdContentRating getAppLovinAdContentRating(int maximum_ad_content_rating);
    
public:
    AppLovinMAXGodotPlugin();
    ~AppLovinMAXGodotPlugin();
    
    static AppLovinMAXGodotPlugin *get_instance();
    
    void initialize(String sdk_key, Dictionary metadata, Array ad_unit_identifiers);
    bool is_initialized();
    
    void show_mediation_debugger();
    void show_creative_debugger();
    
    void set_user_id(String user_id);
    Dictionary get_sdk_configuration();
    String get_ad_value(String ad_unit_identifier, String key);
    
    bool is_tablet();
    bool is_physical_device();
    
#pragma mark - Privacy
    void set_has_user_consent(bool has_user_consent);
    bool get_has_user_consent();
    bool is_user_consent_set();
    
    void set_is_age_restricted_user(bool is_age_restricted_user);
    bool is_age_restricted_user();
    bool is_age_restricted_user_set();
    
    void set_do_not_sell(bool do_not_sell);
    bool get_do_not_sell();
    bool is_do_not_sell_set();
    
#pragma mark - Banners
    void create_banner(String ad_unit_identifier, String banner_position);
    void create_banner_xy(String ad_unit_identifier, float x, float y);
    void load_banner(String ad_unit_identifier);
    void set_banner_placement(String ad_unit_identifier, String placement);
    void start_banner_auto_refresh(String ad_unit_identifier);
    void stop_banner_auto_refresh(String ad_unit_identifier);
    void update_banner_position(String ad_unit_identifier, String banner_position);
    void update_banner_position_xy(String ad_unit_identifier, float x, float y);
    void set_banner_width(String ad_unit_identifier, float width);
    void show_banner(String ad_unit_identifier);
    void destroy_banner(String ad_unit_identifier);
    void hide_banner(String ad_unit_identifier);
    void set_banner_background_color(String ad_unit_identifier, String hex_color_code_string);
    void set_banner_extra_parameter(String ad_unit_identifier, String key, String value);
    void set_banner_local_extra_parameter(String ad_unit_identifier, String key, Variant value);
    void set_banner_custom_data(String ad_unit_identifier, String custom_data);
    float get_adaptive_banner_height(float width);
    
#pragma mark - MREC
    void create_mrec(String ad_unit_identifier, String mrec_position);
    void create_mrec_xy(String ad_unit_identifier, float x, float y);
    void load_mrec(String ad_unit_identifier);
    void set_mrec_placement(String ad_unit_identifier, String placement);
    void start_mrec_auto_refresh(String ad_unit_identifier);
    void stop_mrec_auto_refresh(String ad_unit_identifier);
    void update_mrec_position(String ad_unit_identifier, String mrec_position);
    void update_mrec_position_xy(String ad_unit_identifier, float x, float y);
    void show_mrec(String ad_unit_identifier);
    void destroy_mrec(String ad_unit_identifier);
    void hide_mrec(String ad_unit_identifier);
    void set_mrec_extra_parameter(String ad_unit_identifier, String key, String value);
    void set_mrec_local_extra_parameter(String ad_unit_identifier, String key, Variant value);
    void set_mrec_custom_data(String ad_unit_identifier, String custom_data);
    
#pragma mark - Interstitials
    void load_interstitial(String ad_unit_identifier);
    bool is_interstitial_ready(String ad_unit_identifier);
    void show_interstitial(String ad_unit_identifier, String placement, String custom_data);
    void set_interstitial_extra_parameter(String ad_unit_identifier, String key, String value);
    void set_interstitial_local_extra_parameter(String ad_unit_identifier, String key, Variant value);
    
#pragma mark - App Open
    void load_appopen_ad(String ad_unit_identifier);
    bool is_appopen_ad_ready(String ad_unit_identifier);
    void show_appopen_ad(String ad_unit_identifier, String placement, String custom_data);
    void set_appopen_ad_extra_parameter(String ad_unit_identifier, String key, String value);
    void set_appopen_ad_local_extra_parameter(String ad_unit_identifier, String key, Variant value);
    
#pragma mark - Rewarded
    void load_rewarded_ad(String ad_unit_identifier);
    bool is_rewarded_ad_ready(String ad_unit_identifier);
    void show_rewarded_ad(String ad_unit_identifier, String placement, String custom_data);
    void set_rewarded_ad_extra_parameter(String ad_unit_identifier, String key, String value);
    void set_rewarded_ad_local_extra_parameter(String ad_unit_identifier, String key, Variant value);
    
#pragma mark - Event Tracking
    void track_event(String name, Dictionary parameters);
    
#pragma mark - User Segment
    void set_user_segment_field(String field, String value);
    
#pragma mark - Targeting Data
    void set_targeting_data_year_of_birth(int year_of_birth);
    void set_targeting_data_gender(String gender);
    void set_targeting_data_maximum_ad_content_rating(int maximum_ad_content_rating);
    void set_targeting_data_email(String email);
    void set_targeting_data_phone_number(String phone_number);
    void set_targeting_data_keywords(Array keywords);
    void set_targeting_data_interests(Array interests);
    void clear_all_targeting_data();
    
#pragma mark - Settings
    void set_muted(bool muted);
    bool is_muted();
    void set_verbose_logging(bool enabled);
    bool is_verbose_logging_enabled();
    void set_creative_debugger_enabled(bool enabled);
    void set_test_device_advertising_identifiers(Array advertising_identifiers);
    void set_exception_handler_enabled(bool enabled);
    void set_location_collection_enabled(bool enabled);
    void set_extra_parameter(String key, String value);
};
