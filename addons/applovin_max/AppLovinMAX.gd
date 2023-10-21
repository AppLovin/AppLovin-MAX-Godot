##
##  AppLovinMAX.gd
##  AppLovin MAX Godot Plugin
##
##  Created by Christopher Cong on 09/13/23.
##  Copyright © 2023 AppLovin. All rights reserved.
##

## AppLovin MAX Godot Plugin API
class_name AppLovinMAX

## Returns the plugin version
static var version: String = "1.0.2"
## This class allows you to provide user or app data that will improve how we target ads.
static var targeting_data: TargetingData = TargetingData.new()
## User segments allow us to serve ads using custom-defined rules based on which segment the user is in. For now, we only support a custom string 32 alphanumeric characters or less as the user segment.
static var user_segment: UserSegment = UserSegment.new()

static var _banner_ad_listener: AdEventListener
static var _mrec_ad_listener: AdEventListener
static var _interstitial_ad_listener: InterstitialAdEventListener
static var _appopen_ad_listener: AppOpenAdEventListener
static var _rewarded_ad_listener: RewardedAdEventListener

static var _plugin = _get_plugin("AppLovinMAXGodotPlugin")
	
	
class InitializationListener:
	var on_sdk_initialized: Callable = func(sdk_configuration : AppLovinMAX.SdkConfiguration): pass
	
	
class AdEventListener:
	var on_ad_loaded: Callable = func(ad_unit_identifier: String, ad_info: AppLovinMAX.AdInfo): pass
	var on_ad_load_failed: Callable = func(ad_unit_identifier: String, errorInfo: AppLovinMAX.ErrorInfo): pass
	var on_ad_clicked: Callable = func(ad_unit_identifier: String, ad_info: AppLovinMAX.AdInfo): pass
	var on_ad_revenue_paid: Callable = func(ad_unit_identifier: String, ad_info: AppLovinMAX.AdInfo): pass
		
		
class FullscreenAdEventListener:
	extends AdEventListener
	
	var on_ad_displayed: Callable = func(ad_unit_identifier: String, ad_info: AppLovinMAX.AdInfo): pass
	var on_ad_display_failed = func(ad_unit_identifier: String, errorInfo: AppLovinMAX.ErrorInfo, ad_info: AppLovinMAX.AdInfo): pass
	var on_ad_hidden: Callable = func(ad_unit_identifier: String, ad_info: AppLovinMAX.AdInfo): pass
	
	
class BannerAdEventListener:
	extends AdEventListener


class MRecAdEventListener:
	extends AdEventListener

	
class InterstitialAdEventListener:
	extends FullscreenAdEventListener
	
	
class AppOpenAdEventListener:
	extends FullscreenAdEventListener
		
	
class RewardedAdEventListener:
	extends FullscreenAdEventListener
	
	var on_ad_received_reward: Callable = func(ad_unit_identifier: String, reward: AppLovinMAX.Reward, ad_info: AppLovinMAX.AdInfo): pass
	
	
static func initialize(sdk_key: String, listener: InitializationListener = null, ad_unit_identifiers: Array = Array()) -> void:
	if _plugin == null:
		return
		
	_plugin.connect("on_sdk_initialized", func(sdk_configuration: Dictionary):
		if listener:
			listener.on_sdk_initialized.call(SdkConfiguration.create(sdk_configuration))
	)
		
	_plugin.initialize(sdk_key, _generate_metadata(), ad_unit_identifiers)

	
static func is_initialized() -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_initialized()
	
	
static func show_mediation_debugger() -> void:
	if _plugin == null:
		return
	
	_plugin.show_mediation_debugger()
	

static func show_creative_debugger() -> void:
	if _plugin == null:
		return
	
	_plugin.show_creative_debugger()
	
	
static func set_user_id(user_id: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_user_id(user_id)


static func get_sdk_configuration() -> SdkConfiguration:
	if _plugin == null:
		return null
			
	var configuration = _plugin.get_sdk_configuration();	
	return SdkConfiguration.create(configuration);


static func get_ad_value(ad_unit_identifier: String, key: String) -> String:
	if _plugin == null:
		return ""
	
	var value = _plugin.get_ad_value(ad_unit_identifier, key)
	return value if value else ""


static func is_tablet() -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_tablet()
	
	
static func is_physical_device() -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_physical_device()
	

### Privacy ###
	
static func set_has_user_consent(has_user_consent: bool) -> void:
	if _plugin == null:
		return
		
	_plugin.set_has_user_consent(has_user_consent)
	
	
static func get_has_user_consent() -> bool:
	if _plugin == null:
		return false
		
	return _plugin.get_has_user_consent()
	
	
static func is_user_consent_set() -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_user_consent_set()
	
	
static func set_is_age_restricted_user(is_age_restricted_user: bool) -> void:
	if _plugin == null:
		return
		
	_plugin.set_is_age_restricted_user(is_age_restricted_user)
	
	
static func is_age_restricted_user() -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_age_restricted_user()
	
	
static func is_age_restricted_user_set() -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_age_restricted_user_set()
	
	
static func set_do_not_sell(do_not_sell: bool) -> void:
	if _plugin == null:
		return
		
	_plugin.set_do_not_sell(do_not_sell)
	
	
static func get_do_not_sell() -> bool:
	if _plugin == null:
		return false
		
	return _plugin.get_do_not_sell()
	
	
static func is_do_not_sell_set() -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_do_not_sell_set()
	
	
### Banners ###

static func set_banner_ad_listener(listener: AdEventListener) -> void:
	_banner_ad_listener = listener
	
	_plugin.connect("banner_on_ad_loaded", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _banner_ad_listener:
			_banner_ad_listener.on_ad_loaded.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("banner_on_ad_load_failed", func(ad_unit_identifier: String, error_info: Dictionary):
		if _banner_ad_listener:
			_banner_ad_listener.on_ad_load_failed.call(ad_unit_identifier, ErrorInfo.new(error_info))
	)
	_plugin.connect("banner_on_ad_clicked", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _banner_ad_listener:
			_banner_ad_listener.on_ad_clicked.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("banner_on_ad_revenue_paid", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _banner_ad_listener:
			_banner_ad_listener.on_ad_revenue_paid.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	

static func create_banner(ad_unit_identifier: String, banner_position: AdViewPosition) -> void:
	if _plugin == null:
		return
	
	_plugin.create_banner(ad_unit_identifier, get_adview_position(banner_position).to_lower())


static func create_banner_xy(ad_unit_identifier: String, x: float, y: float) -> void:
	if _plugin == null:
		return
		
	_plugin.create_banner_xy(ad_unit_identifier, x, y)


static func load_banner(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.load_banner(ad_unit_identifier)


static func set_banner_placement(ad_unit_identifier: String, placement: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_banner_placement(ad_unit_identifier, placement)


static func start_banner_auto_refresh(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.start_banner_auto_refresh(ad_unit_identifier)


static func stop_banner_auto_refresh(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.stop_banner_auto_refresh(ad_unit_identifier)


static func update_banner_position(ad_unit_identifier: String, banner_position: AdViewPosition) -> void:
	if _plugin == null:
		return
		
	_plugin.update_banner_position(ad_unit_identifier, get_adview_position(banner_position).to_lower())


static func update_banner_position_xy(ad_unit_identifier: String, x: float, y: float) -> void:
	if _plugin == null:
		return
		
	_plugin.update_banner_position_xy(ad_unit_identifier, x, y)


static func set_banner_width(ad_unit_identifier: String, width: float) -> void:
	if _plugin == null:
		return
		
	_plugin.set_banner_width(ad_unit_identifier, width)


static func show_banner(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.show_banner(ad_unit_identifier)


static func destroy_banner(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.destroy_banner(ad_unit_identifier)


static func hide_banner(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.hide_banner(ad_unit_identifier)


static func set_banner_background_color(ad_unit_identifier: String, hex_color_code_string: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_banner_background_color(ad_unit_identifier, hex_color_code_string)


static func set_banner_extra_parameter(ad_unit_identifier: String, key: String, value: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_banner_extra_parameter(ad_unit_identifier, key, value)


static func set_banner_local_extra_parameter(ad_unit_identifier: String, key: String, value: Object) -> void:
	if _plugin == null:
		return
		
	_plugin.set_banner_local_extra_parameter(ad_unit_identifier, key, value)


static func set_banner_custom_data(ad_unit_identifier: String, custom_data: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_banner_custom_data(ad_unit_identifier, custom_data)


static func get_adaptive_banner_height(width: float) -> float:
	if _plugin == null:
		return 0.0
		
	return _plugin.get_adaptive_banner_height(width)
	

### MREC ###

static func set_mrec_ad_listener(listener: AdEventListener) -> void:
	_mrec_ad_listener = listener
	
	_plugin.connect("mrec_on_ad_loaded", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _mrec_ad_listener:
			_mrec_ad_listener.on_ad_loaded.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("mrec_on_ad_load_failed", func(ad_unit_identifier: String, error_info: Dictionary):
		if _mrec_ad_listener:
			_mrec_ad_listener.on_ad_load_failed.call(ad_unit_identifier, ErrorInfo.new(error_info))
	)
	_plugin.connect("mrec_on_ad_clicked", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _mrec_ad_listener:
			_mrec_ad_listener.on_ad_clicked.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("mrec_on_ad_revenue_paid", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _mrec_ad_listener:
			_mrec_ad_listener.on_ad_revenue_paid.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	

static func create_mrec(ad_unit_identifier: String, mrec_position: AdViewPosition) -> void:
	if _plugin == null:
		return
		
	_plugin.create_mrec(ad_unit_identifier, get_adview_position(mrec_position).to_lower())


static func create_mrec_xy(ad_unit_identifier: String, x: float, y: float) -> void:
	if _plugin == null:
		return
		
	_plugin.create_mrec_xy(ad_unit_identifier, x, y)


static func load_mrec(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.load_mrec(ad_unit_identifier)


static func set_mrec_placement(ad_unit_identifier: String, placement: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_mrec_placement(ad_unit_identifier, placement)


static func start_mrec_auto_refresh(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.start_mrec_auto_refresh(ad_unit_identifier)


static func stop_mrec_auto_refresh(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.stop_mrec_auto_refresh(ad_unit_identifier)


static func update_mrec_position(ad_unit_identifier: String, mrec_position: AdViewPosition) -> void:
	if _plugin == null:
		return
		
	_plugin.update_mrec_position(ad_unit_identifier, get_adview_position(mrec_position).to_lower())


static func update_mrec_position_xy(ad_unit_identifier: String, x: float, y: float) -> void:
	if _plugin == null:
		return
		
	_plugin.update_mrec_position_xy(ad_unit_identifier, x, y)
	
	
static func show_mrec(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.show_mrec(ad_unit_identifier)


static func destroy_mrec(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.destroy_mrec(ad_unit_identifier)


static func hide_mrec(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.hide_mrec(ad_unit_identifier)


static func set_mrec_extra_parameter(ad_unit_identifier: String, key: String, value: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_mrec_extra_parameter(ad_unit_identifier, key, value)


static func set_mrec_local_extra_parameter(ad_unit_identifier: String, key: String, value: Object) -> void:
	if _plugin == null:
		return
		
	_plugin.set_mrec_local_extra_parameter(ad_unit_identifier, key, value)


static func set_mrec_custom_data(ad_unit_identifier: String, custom_data: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_mrec_custom_data(ad_unit_identifier, custom_data)
	
	
### Interstitials ###

static func set_interstitial_ad_listener(listener: InterstitialAdEventListener) -> void:
	_interstitial_ad_listener = listener
	
	_plugin.connect("interstitial_on_ad_loaded", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _interstitial_ad_listener:
			print("[TEST] inter loaded, listener")
			_interstitial_ad_listener.on_ad_loaded.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("interstitial_on_ad_load_failed", func(ad_unit_identifier: String, error_info: Dictionary):
		if _interstitial_ad_listener:
			_interstitial_ad_listener.on_ad_load_failed.call(ad_unit_identifier, ErrorInfo.new(error_info))
	)
	_plugin.connect("interstitial_on_ad_clicked", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _interstitial_ad_listener:
			_interstitial_ad_listener.on_ad_clicked.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("interstitial_on_ad_revenue_paid", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _interstitial_ad_listener:
			_interstitial_ad_listener.on_ad_revenue_paid.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("interstitial_on_ad_displayed", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _interstitial_ad_listener:
			_interstitial_ad_listener.on_ad_displayed.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("interstitial_on_ad_display_failed", func(ad_unit_identifier: String, error_info: Dictionary, ad_info: Dictionary):
		if _interstitial_ad_listener:
			_interstitial_ad_listener.on_ad_display_failed.call(ad_unit_identifier, ErrorInfo.new(error_info), AdInfo.new(ad_info));
	)
	_plugin.connect("interstitial_on_ad_hidden", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _interstitial_ad_listener:
			_interstitial_ad_listener.on_ad_hidden.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	

static func load_interstitial(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.load_interstitial(ad_unit_identifier)
	
	
static func is_interstitial_ready(ad_unit_identifier: String) -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_interstitial_ready(ad_unit_identifier)

	
static func show_interstitial(ad_unit_identifier: String, placement: String = "", custom_data: String = "") -> void:
	if _plugin == null:
		return
		
	_plugin.show_interstitial(ad_unit_identifier, placement, custom_data)
	
	
static func set_interstitial_extra_parameter(ad_unit_identifier: String, key: String, value: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_interstitial_extra_parameter(ad_unit_identifier, key, value)


static func set_interstitial_local_extra_parameter(ad_unit_identifier: String, key: String, value: Object) -> void:
	if _plugin == null:
		return
		
	_plugin.set_interstitial_local_extra_parameter(ad_unit_identifier, key, value)
	
	
### App Open ###

static func set_appopen_ad_listener(listener: AppOpenAdEventListener) -> void:
	_appopen_ad_listener = listener
	
	_plugin.connect("appopen_on_ad_loaded", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _appopen_ad_listener:
			_appopen_ad_listener.on_ad_loaded.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("appopen_on_ad_load_failed", func(ad_unit_identifier: String, error_info: Dictionary):
		if _appopen_ad_listener:
			_appopen_ad_listener.on_ad_load_failed.call(ad_unit_identifier, ErrorInfo.new(error_info))
	)
	_plugin.connect("appopen_on_ad_clicked", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _appopen_ad_listener:
			_appopen_ad_listener.on_ad_clicked.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("appopen_on_ad_revenue_paid", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _appopen_ad_listener:
			_appopen_ad_listener.on_ad_revenue_paid.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("appopen_on_ad_displayed", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _appopen_ad_listener:
			_appopen_ad_listener.on_ad_displayed.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("appopen_on_ad_display_failed", func(ad_unit_identifier: String, error_info: Dictionary, ad_info: Dictionary):
		if _appopen_ad_listener:
			_appopen_ad_listener.on_ad_display_failed.call(ad_unit_identifier, ErrorInfo.new(error_info), AdInfo.new(ad_info))
	)
	_plugin.connect("appopen_on_ad_hidden", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _appopen_ad_listener:
			_appopen_ad_listener.on_ad_hidden.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	

static func load_appopen_ad(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.load_appopen_ad(ad_unit_identifier)
	
	
static func is_appopen_ad_ready(ad_unit_identifier: String) -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_appopen_ad_ready(ad_unit_identifier)

	
static func show_appopen_ad(ad_unit_identifier: String, placement: String = "", custom_data: String = "") -> void:
	if _plugin == null:
		return
		
	_plugin.show_appopen_ad(ad_unit_identifier, placement, custom_data)
	
	
static func set_appopen_ad(ad_unit_identifier: String, key: String = "", value: String = "") -> void:
	if _plugin == null:
		return
		
	_plugin.set_appopen_ad_extra_parameter(ad_unit_identifier, key, value)


static func set_appopen_ad_local_extra_parameter(ad_unit_identifier: String, key: String, value: Object) -> void:
	if _plugin == null:
		return
		
	_plugin.set_appopen_ad_local_extra_parameter(ad_unit_identifier, key, value)
	
	
### Rewarded ###

static func set_rewarded_ad_listener(listener: RewardedAdEventListener) -> void:
	_rewarded_ad_listener = listener
	
	_plugin.connect("rewarded_on_ad_loaded", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _rewarded_ad_listener:
			_rewarded_ad_listener.on_ad_loaded.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("rewarded_on_ad_load_failed", func(ad_unit_identifier: String, error_info: Dictionary):
		if _rewarded_ad_listener:
			_rewarded_ad_listener.on_ad_load_failed.call(ad_unit_identifier, ErrorInfo.new(error_info))
	)
	_plugin.connect("rewarded_on_ad_clicked", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _rewarded_ad_listener:
			_rewarded_ad_listener.on_ad_clicked.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("rewarded_on_ad_revenue_paid", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _rewarded_ad_listener:
			_rewarded_ad_listener.on_ad_revenue_paid.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("rewarded_on_ad_displayed", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _rewarded_ad_listener:
			_rewarded_ad_listener.on_ad_displayed.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("rewarded_on_ad_display_failed", func(ad_unit_identifier: String, error_info: Dictionary, ad_info: Dictionary):
		if _rewarded_ad_listener:
			_rewarded_ad_listener.on_ad_display_failed.call(ad_unit_identifier, ErrorInfo.new(error_info), AdInfo.new(ad_info))
	)
	_plugin.connect("rewarded_on_ad_hidden", func(ad_unit_identifier: String, ad_info: Dictionary):
		if _rewarded_ad_listener:
			_rewarded_ad_listener.on_ad_hidden.call(ad_unit_identifier, AdInfo.new(ad_info))
	)
	_plugin.connect("rewarded_on_ad_received_reward", func(ad_unit_identifier: String, reward: Dictionary, ad_info: Dictionary):
		if _rewarded_ad_listener:
			_rewarded_ad_listener.on_ad_received_reward.call(ad_unit_identifier, Reward.new(reward), AdInfo.new(ad_info))
	)
	

static func load_rewarded_ad(ad_unit_identifier: String) -> void:
	if _plugin == null:
		return
		
	_plugin.load_rewarded_ad(ad_unit_identifier)
	
	
static func is_rewarded_ad_ready(ad_unit_identifier: String) -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_rewarded_ad_ready(ad_unit_identifier)
	
	
static func show_rewarded_ad(ad_unit_identifier: String, placement: String = "", custom_data: String = "") -> void:
	if _plugin == null:
		return
		
	_plugin.show_rewarded_ad(ad_unit_identifier, placement, custom_data)
	
	
static func set_rewarded_ad_extra_parameter(ad_unit_identifier: String, key: String, value: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_rewarded_ad_extra_parameter(ad_unit_identifier, key, value)


static func set_rewarded_ad_local_extra_parameter(ad_unit_identifier: String, key: String, value: Object) -> void:
	if _plugin == null:
		return
		
	_plugin.set_rewarded_ad_local_extra_parameter(ad_unit_identifier, key, value)
	

### Event Tracking ###

static func track_event(name: String, parameters: Dictionary) -> void:
	if _plugin == null:
		return
		
	_plugin.track_event(name, parameters)
	

### Settings ###

static func set_muted(muted: bool) -> void:
	if _plugin == null:
		return
		
	_plugin.set_muted(muted)
	
	
static func is_muted() -> bool:
	if _plugin == null:
		return false
		
	return _plugin.is_muted()
	
	
static func set_verbose_logging(enabled: bool) -> void:
	if _plugin == null:
		return
		
	_plugin.set_verbose_logging(enabled)
	
	
static func is_verbose_logging_enabled() -> void:
	if _plugin == null:
		return
		
	return _plugin.is_verbose_logging_enabled()
	
	
static func set_creative_debugger_enabled(enabled: bool) -> void:
	if _plugin == null:
		return
		
	_plugin.set_creative_debugger_enabled(enabled)
	
	
static func set_test_device_advertising_identifiers(advertising_identifiers: Array) -> void:
	if _plugin == null:
		return
		
	_plugin.set_test_device_advertising_identifiers()
	
	
static func set_exception_handler_enabled(enabled: bool) -> void:
	if _plugin == null:
		return
		
	_plugin.set_exception_handler_enabled(enabled)
	
	
static func set_location_collection_enabled(enabled: bool) -> void:
	if _plugin == null:
		return
		
	_plugin.set_location_collection_enabled(enabled)
	
	
static func set_extra_parameter(key: String, value: String) -> void:
	if _plugin == null:
		return
		
	_plugin.set_extra_parameter(key, value)
	
	
static func _get_plugin(plugin_name: String) -> Object:
	if Engine.has_singleton(plugin_name):
		return Engine.get_singleton(plugin_name)

	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		printerr(plugin_name + " not found, make sure you marked all 'AppLovinMAX' plugins on export tab")

	return null
	

static func _generate_metadata() -> Dictionary:
	return {
		"GodotVersion": Engine.get_version_info()
	}


#func get_rect_from_string(rect_prop_string: String) -> Rect:
#	var rect_dict = parse_json(rect_prop_string)
#	var origin_x = AppLovinMAXDictionaryUtils.get_float(rect_dict, "origin_x", 0)
#	var origin_y = AppLovinMAXDictionaryUtils.get_float(rect_dict, "origin_y", 0)
#	var width = AppLovinMAXDictionaryUtils.get_float(rect_dict, "width", 0)
#	var height = AppLovinMAXDictionaryUtils.get_float(rect_dict, "height", 0)
#	return Rect2(origin_x, origin_y, width, height)


enum AppTrackingStatus {
	UNAVAILABLE,
	NOT_DETERMINED,
	RESTRICTED,
	DENIED,
	AUTHORIZED
}


enum AdViewPosition {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	CENTERED,
	CENTER_LEFT,
	CENTER_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT
}

static func get_adview_position(adview_position: AdViewPosition) -> String:
	match adview_position:
		AdViewPosition.TOP_LEFT:
			return "TOP_LEFT"
		AdViewPosition.TOP_CENTER:
			return "TOP_CENTER"
		AdViewPosition.TOP_RIGHT:
			return "TOP_RIGHT"
		AdViewPosition.CENTERED:
			return "CENTERED"
		AdViewPosition.CENTER_LEFT:
			return "CENTER_LEFT"
		AdViewPosition.CENTER_RIGHT:
			return "CENTER_RIGHT"
		AdViewPosition.BOTTOM_LEFT:
			return "BOTTOM_LEFT"
		AdViewPosition.BOTTOM_CENTER:
			return "BOTTOM_CENTER"
		_:
			return "BOTTOM_RIGHT"


enum ErrorCode {
	UNSPECIFIED = -1,
	NO_FILL = 204,
	AD_LOAD_FAILED = -5001,
	AD_DISPLAY_FAILED = -4205,
	NETWORK_ERROR = -1000,
	NETWORK_TIMEOUT = -1001,
	NO_NETWORK = -1009,
	FULLSCREEN_AD_ALREADY_SHOWING = -23,
	FULLSCREEN_AD_NOT_READY = -24,
	NO_ACTIVITY = -5601,
	DONT_KEEP_ACTIVITIES_ENABLED = -5602
}


enum AdLoadState {
	AD_LOAD_NOT_ATTEMPTED,
	AD_LOADED,
	FAILED_TO_LOAD
}


static func get_app_tracking_status(status_string: String) -> AppTrackingStatus:
	match status_string:
		"-1": 
			return AppTrackingStatus.UNAVAILABLE
		"0": 
			return AppTrackingStatus.NOT_DETERMINED
		"1": 
			return AppTrackingStatus.RESTRICTED
		"2":
			return AppTrackingStatus.DENIED
		_: 
			return AppTrackingStatus.AUTHORIZED
			

static func get_app_tracking_status_string(status: AppTrackingStatus) -> String:
	match status:
		AppTrackingStatus.UNAVAILABLE: 
			return "UNAVAILABLE"
		AppTrackingStatus.NOT_DETERMINED: 
			return "NOT_DETERMINED"
		AppTrackingStatus.RESTRICTED: 
			return "RESTRICTED"
		AppTrackingStatus.DENIED:
			return "DENIED"
		_: 
			return "AUTHORIZED"
			

class TargetingData:
	## This enumeration represents content ratings for the ads shown to users.
	## They correspond to IQG Media Ratings.
	enum AdContentRating {
		NONE,
		ALL_AUDIENCES,
		EVERYONE_OVER_TWELVE,
		MATURE_AUDIENCES
	}

	## This enumeration represents gender.
	enum UserGender {
		UNKNOWN,
		FEMALE,
		MALE,
		OTHER
	}

	var year_of_birth: int:
		set(value):
			if AppLovinMAX._plugin == null:
				return
				
			AppLovinMAX._plugin.set_targeting_data_year_of_birth(value)
			
			
	var gender: UserGender:
		set(value):
			if AppLovinMAX._plugin == null:
				return
			
			var string_value
			match value:
				UserGender.FEMALE:
					string_value = "F"
				UserGender.MALE:
					string_value = "M"
				UserGender.OTHER:
					string_value = "O"
				_:
					string_value = ""
			AppLovinMAX._plugin.set_targeting_data_gender(string_value)
			
			
	var maximum_ad_content_rating: AdContentRating:
		set(value):
			if AppLovinMAX._plugin == null:
				return
			
			AppLovinMAX._plugin.set_targeting_data_maximum_ad_content_rating(int(value))
		
		
	var email: String:
		set(value):
			if AppLovinMAX._plugin == null:
				return
			
			AppLovinMAX._plugin.set_targeting_data_email(value)
			
			
	var phone_number: String:
		set(value):
			if AppLovinMAX._plugin == null:
				return
			
			AppLovinMAX._plugin.set_targeting_data_phone_number(phone_number)
			
			
	var keywords: Array:
		set(value):
			if AppLovinMAX._plugin == null:
				return
			
			AppLovinMAX._plugin.set_targeting_data_keywords(value)
		
		
	var interests: Array:
		set(value):
			if AppLovinMAX._plugin == null:
				return
			
			AppLovinMAX._plugin.set_targeting_data_interests(value)


	func clear_all() -> void:
		if AppLovinMAX._plugin == null:
				return
		
		AppLovinMAX._plugin.clear_all_targeting_data()


class UserSegment:
	var name: String:
		set(value):
			if AppLovinMAX._plugin == null:
				return
		
			AppLovinMAX._plugin.set_user_segment_field("name", value)


class SdkConfiguration:
	var is_successfully_initialized: bool
	var country_code: String
	var app_tracking_status: AppTrackingStatus
	var is_test_mode_enabled: bool


	static func create_empty() -> SdkConfiguration:
		var sdk_configuration = SdkConfiguration.new()
		sdk_configuration.is_successfully_initialized = true
		var localeInfo = OS.get_locale().split("_", true)
		sdk_configuration.country_code = localeInfo[2] if localeInfo[2] != null else localeInfo[0]
		sdk_configuration.is_test_mode_enabled = false
		return sdk_configuration


	static func create(event_props: Dictionary) -> SdkConfiguration:
		var sdk_configuration = SdkConfiguration.new()
		sdk_configuration.is_successfully_initialized = AppLovinMAXDictionaryUtils.get_bool(event_props, "isSuccessfullyInitialized")
		sdk_configuration.country_code = AppLovinMAXDictionaryUtils.get_string(event_props, "countryCode", "")
		sdk_configuration.is_test_mode_enabled = AppLovinMAXDictionaryUtils.get_bool(event_props, "isTestModeEnabled")

		var app_tracking_status_string = AppLovinMAXDictionaryUtils.get_string(event_props, "appTrackingStatus", "-1")
		sdk_configuration.app_tracking_status = AppLovinMAX.get_app_tracking_status(app_tracking_status_string)

		return sdk_configuration
		
		
	func _to_string() -> String:
		return "[SdkConfiguration: is_successfully_initialized = " + str(is_successfully_initialized) +\
			   ", country_code = " + country_code +\
			   ", app_tracking_status = " + AppLovinMAX.get_app_tracking_status_string(app_tracking_status) +\
			   ", is_test_mode_enabled = " + str(is_test_mode_enabled) + "]"


class Reward:
	var label: String
	var amount: int
	
	func _init(reward_info: Dictionary):
		label = AppLovinMAXDictionaryUtils.get_string(reward_info, "label")
		amount = AppLovinMAXDictionaryUtils.get_int(reward_info, "amount")
		

	func _to_string() -> String:
		return "Reward: " + str(amount) + " " + label


	func is_valid() -> bool:
		return label != "" and amount > 0


class WaterfallInfo:
	var name: String
	var test_name: String
	var network_responses: Array[NetworkResponseInfo]
	var latency_millies: int


	func _init(waterfall_info_dict: Dictionary):
		name = AppLovinMAXDictionaryUtils.get_string(waterfall_info_dict, "name")
		test_name = AppLovinMAXDictionaryUtils.get_string(waterfall_info_dict, "testName")
		network_responses = []
		for network_response_object in AppLovinMAXDictionaryUtils.get_list(waterfall_info_dict, "networkResponses", []):
			var network_response_dict = network_response_object as Dictionary
			var network_response = NetworkResponseInfo.new(network_response_dict)
			network_responses.append(network_response)
		latency_millies = AppLovinMAXDictionaryUtils.get_long(waterfall_info_dict, "latencyMillis")


	func _to_string() -> String:
		var network_response_strings = []
		for network_response_info in network_responses:
			network_response_strings.append(network_response_info.to_string())
		return "[MediatedNetworkInfo: name = " + name +\
			   ", testName = " + test_name +\
			   ", latency = " + str(latency_millies) +\
			   ", networkResponse = " + ", ".join(network_response_strings) + "]"


class AdInfo:
	var ad_unit_identifier: String
	var ad_format: String
	var network_name: String
	var network_placement: String
	var placement: String
	var creative_identifier: String
	var revenue: float
	var revenue_precision: String
	var waterfall_info: WaterfallInfo
	var dsp_name: String


	func _init(ad_info_dictionary: Dictionary):
		ad_unit_identifier = AppLovinMAXDictionaryUtils.get_string(ad_info_dictionary, "adUnitId")
		ad_format = AppLovinMAXDictionaryUtils.get_string(ad_info_dictionary, "adFormat")
		network_name = AppLovinMAXDictionaryUtils.get_string(ad_info_dictionary, "networkName")
		network_placement = AppLovinMAXDictionaryUtils.get_string(ad_info_dictionary, "networkPlacement")
		placement = AppLovinMAXDictionaryUtils.get_string(ad_info_dictionary, "placement")
		creative_identifier = AppLovinMAXDictionaryUtils.get_string(ad_info_dictionary, "creativeId")
		revenue = AppLovinMAXDictionaryUtils.get_double(ad_info_dictionary, "revenue", -1)
		revenue_precision = AppLovinMAXDictionaryUtils.get_string(ad_info_dictionary, "revenuePrecision")
		waterfall_info = WaterfallInfo.new(ad_info_dictionary["waterfallInfo"])
		dsp_name = AppLovinMAXDictionaryUtils.get_string(ad_info_dictionary, "dspName")


	func _to_string() -> String:
		return "[AdInfo adUnitIdentifier: " + ad_unit_identifier +\
			   ", adFormat: " + ad_format +\
			   ", networkName: " + network_name +\
			   ", networkPlacement: " + network_placement +\
			   ", creativeIdentifier: " + creative_identifier +\
			   ", placement: " + placement +\
			   ", revenue: " + str(revenue) +\
			   ", revenuePrecision: " + revenue_precision +\
			   ", dspName: " + dsp_name + "]"


class NetworkResponseInfo:
	var ad_load_state: AdLoadState
	var mediated_network: MediatedNetworkInfo
	var credentials: Dictionary
	var is_bidding: bool
	var latency_millis: int
	var error: ErrorInfo


	func _init(network_response_info_dict: Dictionary):
		var mediated_network_info_dict = AppLovinMAXDictionaryUtils.get_dictionary(network_response_info_dict, "mediatedNetwork")
		mediated_network = MediatedNetworkInfo.new(mediated_network_info_dict) if mediated_network_info_dict != null else null
		credentials = AppLovinMAXDictionaryUtils.get_dictionary(network_response_info_dict, "credentials", {})
		is_bidding = AppLovinMAXDictionaryUtils.get_bool(network_response_info_dict, "isBidding")
		latency_millis = AppLovinMAXDictionaryUtils.get_long(network_response_info_dict, "latencyMillis")
		ad_load_state = AppLovinMAXDictionaryUtils.get_int(network_response_info_dict, "adLoadState")
		var error_info_dict = AppLovinMAXDictionaryUtils.get_dictionary(network_response_info_dict, "error")
		error = ErrorInfo.new(error_info_dict) if error_info_dict != null else null


	func _to_string() -> String:
		var stringBuilder = "[NetworkResponseInfo: adLoadState = " + str(ad_load_state) +\
							", mediatedNetwork = " + mediated_network.to_string() +\
							", credentials = " + str(credentials) + "]"
		match ad_load_state:
			AdLoadState.FAILED_TO_LOAD:
				stringBuilder += ", error = " + error.to_string()
			AdLoadState.AD_LOADED:
				stringBuilder += ", latency = " + str(latency_millis)
		return stringBuilder + "]"


class MediatedNetworkInfo:
	var name: String
	var adapter_class_name: String
	var adapter_version: String
	var sdk_version: String


	func _init(mediated_network_dictionary: Dictionary):
		name = AppLovinMAXDictionaryUtils.get_string(mediated_network_dictionary, "name", "")
		adapter_class_name = AppLovinMAXDictionaryUtils.get_string(mediated_network_dictionary, "adapterClassName", "")
		adapter_version = AppLovinMAXDictionaryUtils.get_string(mediated_network_dictionary, "adapterVersion", "")
		sdk_version = AppLovinMAXDictionaryUtils.get_string(mediated_network_dictionary, "sdkVersion", "")


	func to_string() -> String:
		return "[MediatedNetworkInfo name: " + name +\
			   ", adapterClassName: " + adapter_class_name +\
			   ", adapterVersion: " + adapter_version +\
			   ", sdkVersion: " + sdk_version + "]"


class ErrorInfo:
	var code: ErrorCode
	var message: String
	var mediated_network_error_code: int
	var mediated_network_error_message: String
	var ad_load_failure_info: String
	var waterfall_info: WaterfallInfo


	func _init(error_info_dictionary: Dictionary):
		code = AppLovinMAXDictionaryUtils.get_int(error_info_dictionary, "errorCode", ErrorCode.UNSPECIFIED)
		message = AppLovinMAXDictionaryUtils.get_string(error_info_dictionary, "errorMessage", "")
		mediated_network_error_code = AppLovinMAXDictionaryUtils.get_int(error_info_dictionary, "mediatedNetworkErrorCode", int(ErrorCode.UNSPECIFIED))
		mediated_network_error_message = AppLovinMAXDictionaryUtils.get_string(error_info_dictionary, "mediatedNetworkErrorMessage", "")
		ad_load_failure_info = AppLovinMAXDictionaryUtils.get_string(error_info_dictionary, "adLoadFailureInfo", "")
		waterfall_info = WaterfallInfo.new(error_info_dictionary["waterfallInfo"]) if "waterfallInfo" in error_info_dictionary else null


	func _to_string() -> String:
		var stringbuilder = "[ErrorInfo code: " + str(code) +\
							", message: " + message
		if code == ErrorCode.AD_DISPLAY_FAILED:
			stringbuilder += ", mediatedNetworkCode: " + str(mediated_network_error_code) +\
							 ", mediatedNetworkMessage: " + mediated_network_error_message
		return stringbuilder + ", adLoadFailureInfo: " + ad_load_failure_info + "]"
		
		
