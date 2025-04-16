//
//  AppLovinMAXGodotPlugin.h
//  AppLovin-MAX-Godot-Plugin
//
//  Created by Chris Cong on 9/15/23.
//


#import <Foundation/Foundation.h>

#import "AppLovinMAXGodotManager.h"

#include "core/object/object.h"
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
    
    static MASegmentCollectionBuilder *_segmentCollectionBuilder;

    // Store these values if pub attempts to set it before calling _MaxInitializeSdk()
    static NSArray<NSString *> *_testDeviceIdentifiersToSet;

public:
    AppLovinMAXGodotPlugin();
    ~AppLovinMAXGodotPlugin();
    
    static AppLovinMAXGodotPlugin *get_instance();
    
    void initialize(String sdk_key, Dictionary metadata, Array ad_unit_identifiers);
    bool is_initialized();
    
    void show_mediation_debugger();
    void show_creative_debugger();
    
    Dictionary get_sdk_configuration();
    String get_ad_value(String ad_unit_identifier, String key);
    
    bool is_tablet();
    bool is_physical_device();
    
#pragma mark - Consent Flow
    void set_terms_and_privacy_policy_flow_enabled(bool enabled);
    void set_privacy_policy_url(String url_string);
    void set_terms_of_service_url(String url_string);
    void set_consent_flow_debug_user_geography(String user_geography);
    void show_cmp_for_existing_user();
    bool has_supported_cmp();

#pragma mark - Segment Targeting
    void add_segment(int key, Array values);
    Dictionary get_segment();

#pragma mark - Privacy
    void set_has_user_consent(bool has_user_consent);
    bool get_has_user_consent();
    bool is_user_consent_set();
    
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
    
#pragma mark - Settings
    void set_muted(bool muted);
    bool is_muted();
    void set_verbose_logging(bool enabled);
    bool is_verbose_logging_enabled();
    void set_creative_debugger_enabled(bool enabled);
    void set_test_device_advertising_identifiers(Array advertising_identifiers);
    void set_exception_handler_enabled(bool enabled);
    void set_extra_parameter(String key, String value);
};
