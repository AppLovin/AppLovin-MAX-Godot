extends Node

class_name Main

const SDK_KEY = "YOUR_SDK_KEY_HERE"
const INTERSTITIAL_AD_UNIT_IDS = {
	"android" : "ENTER_ANDROID_INTERSTITIAL_AD_UNIT_ID_HERE",
	"ios" : "ENTER_IOS_INTERSTITIAL_AD_UNIT_ID_HERE"
}
const REWARDED_AD_UNIT_IDS = {
	"android" : "ENTER_ANDROID_REWARDED_AD_UNIT_ID_HERE",
	"ios" : "ENTER_IOS_REWARDED_AD_UNIT_ID_HERE"
}
const BANNER_AD_UNIT_IDS = {
	"android" : "ENTER_ANDROID_BANNER_AD_UNIT_ID_HERE",
	"ios" : "ENTER_IOS_BANNER_AD_UNIT_ID_HERE"
}

@onready var status_label = $MarginContainer/VBoxContainer/StatusContainer/StatusLabel
@onready var mediation_debugger_button = $MarginContainer/VBoxContainer/MediationDebuggerButtonContainer/MediationDebuggerButton
@onready var inter_button = $MarginContainer/VBoxContainer/InterButtonContainer/InterButton
@onready var rewarded_button = $MarginContainer/VBoxContainer/RewardedButtonContainer/RewardedButton
@onready var banner_button = $MarginContainer/VBoxContainer/BannerButtonContainer/BannerButton

var is_banner_created = false
var is_banner_showing = false

func _ready():
	
	status_label.text = "Initializing SDK v" + AppLovinMAX.version + "..."
	
	var init_listener = AppLovinMAX.InitializationListener.new()
	init_listener.on_sdk_initialized = func(sdk_configuration: AppLovinMAX.SdkConfiguration):

		_log_message("SDK Initialized: " + sdk_configuration.to_string())
		_attach_ad_listeners()
		
		mediation_debugger_button.disabled = false
		inter_button.disabled = false
		rewarded_button.disabled = false
		banner_button.disabled = false
		
	AppLovinMAX.initialize(SDK_KEY, init_listener)

func _attach_ad_listeners():
	
	var inter_listener = AppLovinMAX.InterstitialAdEventListener.new()
	inter_listener.on_ad_loaded = Callable(self, "_on_interstitial_ad_loaded")
	inter_listener.on_ad_load_failed = Callable(self, "_on_interstitial_ad_load_failed")
	inter_listener.on_ad_displayed = Callable(self, "_on_interstitial_ad_displayed")
	inter_listener.on_ad_display_failed = Callable(self, "_on_interstitial_ad_display_failed")
	inter_listener.on_ad_clicked = Callable(self, "_on_interstitial_ad_clicked")
	inter_listener.on_ad_hidden = Callable(self, "_on_interstitial_ad_hidden")
	AppLovinMAX.set_interstitial_ad_listener(inter_listener)
	
	# Set rewarded callbacks
	var rewarded_listener = AppLovinMAX.RewardedAdEventListener.new()
	rewarded_listener.on_ad_loaded = Callable(self, "_on_rewarded_ad_loaded")
	rewarded_listener.on_ad_load_failed = Callable(self, "_on_rewarded_ad_load_failed")
	rewarded_listener.on_ad_displayed = Callable(self, "_on_rewarded_ad_displayed")
	rewarded_listener.on_ad_display_failed = Callable(self, "_on_rewarded_ad_display_failed")
	rewarded_listener.on_ad_clicked = Callable(self, "_on_rewarded_ad_clicked")
	rewarded_listener.on_ad_received_reward = Callable(self, "_on_rewarded_ad_received_reward")
	rewarded_listener.on_ad_hidden = Callable(self, "_on_rewarded_ad_hidden")
	AppLovinMAX.set_rewarded_ad_listener(rewarded_listener)
	
	# Set banner callbacks
	var banner_listener = AppLovinMAX.BannerAdEventListener.new()
	banner_listener.on_ad_loaded = Callable(self, "_on_banner_ad_loaded")
	banner_listener.on_ad_load_failed = Callable(self, "_on_banner_ad_load_failed")
	banner_listener.on_ad_clicked = Callable(self, "_on_banner_ad_clicked")
	#banner_listener.on_banner_ad_expanded = Callable(self, "_on_banner_ad_expanded")
	#banner_listener.on_banner_ad_collapsed = Callable(self, "_on_banner_ad_collapsed")	
	AppLovinMAX.set_banner_ad_listener(banner_listener)
	
func _on_mediation_debugger_button_pressed():
	AppLovinMAX.show_mediation_debugger()

func _on_inter_button_pressed():
	AppLovinMAX.targeting_data.clear_all()
	var ad_unit_id = _get_ad_unit_id(INTERSTITIAL_AD_UNIT_IDS)
	if ad_unit_id == null:
		_log_message("Ad Unit ID unavailable")
		inter_button.disabled = false
		return
		
	if AppLovinMAX.is_interstitial_ready(ad_unit_id):
		_log_message("Showing interstitial ad...")
		AppLovinMAX.show_interstitial(ad_unit_id)
	else:
		_log_message("Loading interstitial ad...")
		inter_button.disabled = true
		AppLovinMAX.load_interstitial(ad_unit_id)

func _on_rewarded_button_pressed():
	
	var ad_unit_id = _get_ad_unit_id(REWARDED_AD_UNIT_IDS)
	if ad_unit_id == null:
		_log_message("Ad Unit ID unavailable")
		rewarded_button.disabled = false
		return
		
	if AppLovinMAX.is_rewarded_ad_ready(ad_unit_id):
		_log_message("Showing rewarded ad...")
		AppLovinMAX.show_rewarded_ad(ad_unit_id)
	else:
		_log_message("Loading rewarded ad...")
		rewarded_button.disabled = true
		AppLovinMAX.load_rewarded_ad(ad_unit_id)
	
func _on_banner_button_pressed():

	var ad_unit_id = _get_ad_unit_id(BANNER_AD_UNIT_IDS)
	if ad_unit_id != null:	
		is_banner_showing = !is_banner_showing
		if is_banner_showing:
			banner_button.text = "Hide Banner"
			
			if !is_banner_created:
				is_banner_created = true
				# Programmatic banner creation - banners are automatically sized to 320x50 on phones and 728x90 on tablets
				AppLovinMAX.create_banner(ad_unit_id, AppLovinMAX.AdViewPosition.BOTTOM_CENTER)

				# Set background color for banners to be fully functional In this case we are setting
				# it to black - PLEASE USE HEX STRINGS ONLY
				AppLovinMAX.set_banner_background_color(ad_unit_id, "#000000")
			
			AppLovinMAX.show_banner(ad_unit_id)
		else:
			banner_button.text = "Show Banner"
			AppLovinMAX.hide_banner(ad_unit_id)
	else:
		_log_message("Ad Unit ID unavailable")
		return

### Interstitial Ad Callbacks

func _on_interstitial_ad_loaded(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	inter_button.disabled = false
	inter_button.text = "Show Interstitial"
	_log_message("Interstitial ad loaded from" + ad_info.network_name)
	
func _on_interstitial_ad_load_failed(ad_unit_id: String, errorInfo: AppLovinMAX.ErrorInfo):
	_log_message("Interstitial ad failed to load with code " + str(errorInfo.code) + " with " + str(errorInfo.message))
	
func _on_interstitial_ad_displayed(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	_log_message("Interstitial ad displayed")
	
func _on_interstitial_ad_display_failed(ad_unit_id: String, errorInfo: AppLovinMAX.ErrorInfo, ad_info: AppLovinMAX.AdInfo):
	inter_button.disabled = false
	inter_button.text = "Load Interstitial"
	_log_message("Interstitial ad failed to display")
	
func _on_interstitial_ad_clicked(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	_log_message("Interstitial ad clicked")
	
func _on_interstitial_ad_hidden(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	inter_button.disabled = false
	inter_button.text = "Load Interstitial"
	_log_message("Interstitial ad hidden")

### Rewarded Ad Callbacks

func _on_rewarded_ad_loaded(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	rewarded_button.disabled = false
	rewarded_button.text = "Show Rewarded Ad"
	_log_message("Rewarded ad loaded from" + ad_info.network_name)
	
func _on_rewarded_ad_load_failed(ad_unit_id: String, errorInfo: AppLovinMAX.ErrorInfo):
	_log_message("Rewarded ad failed to load with code " + str(errorInfo.code) + " with " + str(errorInfo.message))
	
func _on_rewarded_ad_displayed(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	_log_message("Rewarded ad displayed")
	
func _on_rewarded_ad_display_failed(ad_unit_id: String, errorInfo: AppLovinMAX.ErrorInfo, ad_info: AppLovinMAX.AdInfo):
	rewarded_button.disabled = false
	rewarded_button.text = "Load Rewarded Ad"
	_log_message("Rewarded ad failed to display")
	
func _on_rewarded_ad_clicked(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	_log_message("Rewarded ad clicked")

func _on_rewarded_ad_received_reward(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo, reward: AppLovinMAX.Reward):
	_log_message("Rewarded ad granted reward")
	
func _on_rewarded_ad_hidden(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	rewarded_button.disabled = false
	rewarded_button.text = "Load Rewarded Ad"
	_log_message("Rewarded ad hidden")
	
### Banner Ad Callbacks

func _on_banner_ad_loaded(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	_log_message("Banner ad loaded from" + ad_info.network_name)
	
func _on_banner_ad_load_failed(ad_unit_id: String, errorInfo: AppLovinMAX.ErrorInfo):
	_log_message("Banner ad failed to load with code " + str(errorInfo.code) + " with " + str(errorInfo.message))
	
func _on_banner_ad_clicked(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	_log_message("Banner ad clicked")
	
func _on_banner_ad_expanded(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	_log_message("Banner ad expanded")
	
func _on_banner_ad_collapsed(ad_unit_id: String, ad_info: AppLovinMAX.AdInfo):
	_log_message("Banner ad collapsed")
	
### Utility Methods

func _log_message(message):
	print(message)
	status_label.text = message

func _get_ad_unit_id(ad_units_dict):
	var platform = OS.get_name().to_lower() # "android", "ios", etc
	return ad_units_dict.get(platform)
