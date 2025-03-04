package com.applovin.godot;

import android.app.Activity;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import com.applovin.sdk.AppLovinPrivacySettings;
import com.applovin.sdk.AppLovinSdk;
import com.applovin.sdk.AppLovinSdkConfiguration;
import com.applovin.sdk.AppLovinSdkSettings;
import com.applovin.sdk.AppLovinSdkUtils;

import org.godotengine.godot.Dictionary;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class AppLovinMAXGodotPlugin
        extends GodotPlugin
{
    private final static String TAG     = "AppLovinMAX-Godot";
    private static final String SDK_TAG = "AppLovinSdk";

    private final AppLovinMAXGodotManager appLovinMAX;
    private       AppLovinSdk             sdk;

    private boolean isPluginInitialized = false;
    private boolean isSdkInitialized    = false;

    private WeakReference<Activity> activity;
    private FrameLayout             godotLayout;

    // Store these values if pub attempts to set it before calling initializeSdk()
    private List<String> testDeviceAdvertisingIds;
    private Boolean      verboseLogging;
    private Boolean      creativeDebuggerEnabled;
    private Boolean      exceptionHandlerEnabled;

    private final Map<String, String> extraParametersToSet     = new HashMap<>();
    private final Object              extraParametersToSetLock = new Object();

    public AppLovinMAXGodotPlugin(final Godot godot)
    {
        super( godot );

        AppLovinMAXGodotManager.setGodotActivity( getActivity() );
        appLovinMAX = new AppLovinMAXGodotManager( new WeakReference<>( this ) );
        isPluginInitialized = true;
    }

    @Override
    public String getPluginName()
    {
        return "AppLovinMAXGodotPlugin";
    }

    @Override
    public View onMainCreate(Activity activity)
    {
        this.activity = new WeakReference<>( activity );
        AppLovinMAXGodotManager.setMainActivity( activity );

        godotLayout = new FrameLayout( activity );
        return godotLayout;
    }

    @Override
    public void emitSignal(final String signalName, final Object... signalArgs)
    {
        super.emitSignal( signalName, signalArgs );
    }

    @Override
    public Set<SignalInfo> getPluginSignals()
    {
        HashSet<SignalInfo> signals = new HashSet<>();

        signals.add( new SignalInfo( Signal.SDK_INITIALIZATION,
                                     Dictionary.class ) );

        signals.add( new SignalInfo( Signal.BANNER_ON_AD_LOADED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.BANNER_ON_AD_LOAD_FAILED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.BANNER_ON_AD_CLICKED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.BANNER_ON_AD_REVENUE_PAID,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.BANNER_ON_AD_EXPANDED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.BANNER_ON_AD_COLLAPSED,
                                     String.class,
                                     Dictionary.class ) );

        signals.add( new SignalInfo( Signal.MREC_ON_AD_LOADED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.MREC_ON_AD_LOAD_FAILED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.MREC_ON_AD_CLICKED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.MREC_ON_AD_REVENUE_PAID,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.MREC_ON_AD_EXPANDED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.MREC_ON_AD_COLLAPSED,
                                     String.class,
                                     Dictionary.class ) );

        signals.add( new SignalInfo( Signal.INTERSTITIAL_ON_AD_LOADED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.INTERSTITIAL_ON_AD_LOAD_FAILED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.INTERSTITIAL_ON_AD_CLICKED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.INTERSTITIAL_ON_AD_REVENUE_PAID,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.INTERSTITIAL_ON_AD_DISPLAYED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.INTERSTITIAL_ON_AD_DISPLAY_FAILED,
                                     String.class,
                                     Dictionary.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.INTERSTITIAL_ON_AD_HIDDEN,
                                     String.class,
                                     Dictionary.class ) );

        signals.add( new SignalInfo( Signal.APP_OPEN_ON_AD_LOADED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.APP_OPEN_ON_AD_LOAD_FAILED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.APP_OPEN_ON_AD_CLICKED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.APP_OPEN_ON_AD_REVENUE_PAID,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.APP_OPEN_ON_AD_DISPLAYED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.APP_OPEN_ON_AD_DISPLAY_FAILED,
                                     String.class,
                                     Dictionary.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.APP_OPEN_ON_AD_HIDDEN,
                                     String.class,
                                     Dictionary.class ) );

        signals.add( new SignalInfo( Signal.REWARDED_ON_AD_LOADED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.REWARDED_ON_AD_LOAD_FAILED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.REWARDED_ON_AD_CLICKED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.REWARDED_ON_AD_REVENUE_PAID,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.REWARDED_ON_AD_DISPLAYED,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.REWARDED_ON_AD_DISPLAY_FAILED,
                                     String.class,
                                     Dictionary.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.REWARDED_ON_AD_HIDDEN,
                                     String.class,
                                     Dictionary.class ) );
        signals.add( new SignalInfo( Signal.REWARDED_ON_AD_RECEIVED_REWARD,
                                     String.class,
                                     Dictionary.class,
                                     Dictionary.class ) );

        return signals;
    }

    @UsedByGodot
    public void initialize(String sdkKey, Dictionary metadata, String[] adUnitIds)
    {
        sdk = appLovinMAX.initializeSdkWithCompletionHandler( sdkKey, generateSdkSettings( adUnitIds, metadata ), new AppLovinMAXGodotManager.Listener()
        {
            @Override
            public void onSdkInitializationComplete(final AppLovinSdkConfiguration sdkConfiguration)
            {
                isSdkInitialized = true;

                emitSignal( Signal.SDK_INITIALIZATION, get_sdk_configuration() );
            }
        } );

        setPendingExtraParametersIfNeeded( sdk.getSettings() );
    }

    @UsedByGodot
    public boolean is_initialized()
    {
        return isPluginInitialized && isSdkInitialized;
    }

    @UsedByGodot
    public void show_mediation_debugger()
    {
        if ( sdk == null )
        {
            Log.d( "[" + AppLovinMAXGodotPlugin.TAG + "]", "Failed to show mediation debugger - please ensure the AppLovin MAX Godot Plugin has been initialized by calling 'MaxSdk.InitializeSdk();'!" );
            return;
        }

        sdk.showMediationDebugger();
    }

    @UsedByGodot
    public void show_creative_debugger()
    {
        if ( sdk == null )
        {
            Log.d( "[" + AppLovinMAXGodotPlugin.TAG + "]", "Failed to show mediation debugger - please ensure the AppLovin MAX Godot Plugin has been initialized by calling 'MaxSdk.InitializeSdk();'!" );
            return;
        }

        sdk.showCreativeDebugger();
    }

    @UsedByGodot
    public Dictionary get_sdk_configuration()
    {
        if ( sdk == null ) return new Dictionary();

        AppLovinSdkConfiguration sdkConfiguration = sdk.getConfiguration();

        Dictionary configuration = new Dictionary();
        configuration.put( "countryCode", sdkConfiguration.getCountryCode() );
        configuration.put( "isSuccessfullyInitialized", sdk.isInitialized() );
        configuration.put( "isTestModeEnabled", sdkConfiguration.isTestModeEnabled() );

        return configuration;
    }

    @UsedByGodot
    public String get_ad_value(String adUnitId, String key)
    {
        return appLovinMAX.getAdValue( adUnitId.trim(), key );
    }

    @UsedByGodot
    public boolean is_tablet()
    {
        return AppLovinSdkUtils.isTablet( getCurrentActivity() );
    }

    @UsedByGodot
    public boolean is_physical_device()
    {
        return !AppLovinSdkUtils.isEmulator();
    }

    //region Privacy

    @UsedByGodot
    public void set_has_user_consent(boolean hasUserConsent)
    {
        AppLovinPrivacySettings.setHasUserConsent( hasUserConsent, getCurrentActivity() );
    }

    @UsedByGodot
    public boolean get_has_user_consent()
    {
        return AppLovinPrivacySettings.hasUserConsent( getCurrentActivity() );
    }

    @UsedByGodot
    public boolean is_user_consent_set()
    {
        return AppLovinPrivacySettings.isUserConsentSet( getCurrentActivity() );
    }

    @UsedByGodot
    public void set_do_not_sell(boolean doNotSell)
    {
        AppLovinPrivacySettings.setDoNotSell( doNotSell, getCurrentActivity() );
    }

    @UsedByGodot
    public boolean get_do_not_sell()
    {
        return AppLovinPrivacySettings.isDoNotSell( getCurrentActivity() );
    }

    @UsedByGodot
    public boolean is_do_not_sell_set()
    {
        return AppLovinPrivacySettings.isDoNotSellSet( getCurrentActivity() );
    }

    //endregion

    //region Banners

    @UsedByGodot
    public void create_banner(String adUnitId, String bannerPosition)
    {
        appLovinMAX.createBanner( adUnitId.trim(), bannerPosition );
    }

    @UsedByGodot
    public void create_banner_xy(String adUnitId, float x, float y)
    {
        appLovinMAX.createBanner( adUnitId.trim(), x, y );
    }

    @UsedByGodot
    public void load_banner(String adUnitId)
    {
        appLovinMAX.loadBanner( adUnitId.trim() );
    }

    @UsedByGodot
    public void set_banner_placement(String adUnitId, String placement)
    {
        appLovinMAX.setBannerPlacement( adUnitId.trim(), placement );
    }

    @UsedByGodot
    public void start_banner_auto_refresh(String adUnitId)
    {
        appLovinMAX.startBannerAutoRefresh( adUnitId.trim() );
    }

    @UsedByGodot
    public void stop_banner_auto_refresh(String adUnitId)
    {
        appLovinMAX.stopBannerAutoRefresh( adUnitId.trim() );
    }

    @UsedByGodot
    public void update_banner_position(String adUnitId, String bannerPosition)
    {
        appLovinMAX.updateBannerPosition( adUnitId.trim(), bannerPosition );
    }

    @UsedByGodot
    public void update_banner_position_xy(String adUnitId, float x, float y)
    {
        appLovinMAX.updateBannerPosition( adUnitId.trim(), x, y );
    }

    @UsedByGodot
    public void set_banner_width(String adUnitId, float width)
    {
        appLovinMAX.setBannerWidth( adUnitId.trim(), (int) width );
    }

    @UsedByGodot
    public void show_banner(String adUnitId)
    {
        appLovinMAX.showBanner( adUnitId.trim() );
    }

    @UsedByGodot
    public void destroy_banner(String adUnitId)
    {
        appLovinMAX.destroyBanner( adUnitId.trim() );
    }

    @UsedByGodot
    public void hide_banner(String adUnitId)
    {
        appLovinMAX.hideBanner( adUnitId.trim() );
    }

    @UsedByGodot
    public void set_banner_background_color(String adUnitId, String hexColorCodeString)
    {
        appLovinMAX.setBannerBackgroundColor( adUnitId.trim(), hexColorCodeString );
    }

    @UsedByGodot
    public void set_banner_extra_parameter(String adUnitId, String key, String value)
    {
        appLovinMAX.setBannerExtraParameter( adUnitId.trim(), key, value );
    }

    @UsedByGodot
    public void set_banner_local_extra_parameter(String adUnitId, String key, Object value)
    {
        appLovinMAX.setBannerLocalExtraParameter( adUnitId.trim(), key, value );
    }

    @UsedByGodot
    public void set_banner_custom_data(String adUnitId, String customData)
    {
        appLovinMAX.setBannerCustomData( adUnitId.trim(), customData );
    }

    @UsedByGodot
    public float get_adaptive_banner_height(float width)
    {
        return AppLovinMAXGodotManager.getAdaptiveBannerHeight( width );
    }

    //endgion

    //region MRec

    @UsedByGodot
    public void create_mrec(String adUnitId, String mrecPosition)
    {
        appLovinMAX.createMRec( adUnitId.trim(), mrecPosition );
    }

    @UsedByGodot
    public void create_mrec_xy(String adUnitId, float x, float y)
    {
        appLovinMAX.createMRec( adUnitId.trim(), x, y );
    }

    @UsedByGodot
    public void load_mrec(String adUnitId)
    {
        appLovinMAX.loadMRec( adUnitId.trim() );
    }

    @UsedByGodot
    public void set_mrec_placement(String adUnitId, String placement)
    {
        appLovinMAX.setMRecPlacement( adUnitId.trim(), placement );
    }

    @UsedByGodot
    public void start_mrec_auto_refresh(String adUnitId)
    {
        appLovinMAX.startMRecAutoRefresh( adUnitId.trim() );
    }

    @UsedByGodot
    public void stop_mrec_auto_refresh(String adUnitId)
    {
        appLovinMAX.stopMRecAutoRefresh( adUnitId.trim() );
    }

    @UsedByGodot
    public void update_mrec_position(String adUnitId, String mrecPosition)
    {
        appLovinMAX.updateMRecPosition( adUnitId.trim(), mrecPosition );
    }

    @UsedByGodot
    public void update_mrec_position_xy(String adUnitId, float x, float y)
    {
        appLovinMAX.updateMRecPosition( adUnitId.trim(), x, y );
    }

    @UsedByGodot
    public void show_mrec(String adUnitId)
    {
        appLovinMAX.showMRec( adUnitId.trim() );
    }

    @UsedByGodot
    public void destroy_mrec(String adUnitId)
    {
        appLovinMAX.destroyMRec( adUnitId.trim() );
    }

    @UsedByGodot
    public void hide_mrec(String adUnitId)
    {
        appLovinMAX.hideMRec( adUnitId.trim() );
    }

    @UsedByGodot
    public void set_mrec_extra_parameter(String adUnitId, String key, String value)
    {
        appLovinMAX.setMRecExtraParameter( adUnitId.trim(), key, value );
    }

    @UsedByGodot
    public void set_mrec_local_extra_parameter(String adUnitId, String key, Object value)
    {
        appLovinMAX.setMRecLocalExtraParameter( adUnitId.trim(), key, value );
    }

    @UsedByGodot
    public void set_mrec_custom_data(String adUnitId, String customData)
    {
        appLovinMAX.setMRecCustomData( adUnitId.trim(), customData );
    }

    //endregion

    //region Interstitials

    @UsedByGodot
    public void load_interstitial(String adUnitId)
    {
        appLovinMAX.loadInterstitial( adUnitId.trim() );
    }

    @UsedByGodot
    public boolean is_interstitial_ready(String adUnitId)
    {
        return appLovinMAX.isInterstitialReady( adUnitId.trim() );
    }

    @UsedByGodot
    public void show_interstitial(String adUnitId, String placement, String customData)
    {
        appLovinMAX.showInterstitial( adUnitId.trim(), placement, customData );
    }

    @UsedByGodot
    public void set_interstitial_extra_parameter(String adUnitId, String key, String value)
    {
        appLovinMAX.setInterstitialExtraParameter( adUnitId.trim(), key, value );
    }

    @UsedByGodot
    public void set_interstitial_local_extra_parameter(String adUnitId, String key, Object value)
    {
        appLovinMAX.setInterstitialLocalExtraParameter( adUnitId.trim(), key, value );
    }

    //endregion

    //region AppOpen

    @UsedByGodot
    public void load_appopen_ad(String adUnitId)
    {
        appLovinMAX.loadAppOpenAd( adUnitId.trim() );
    }

    @UsedByGodot
    public boolean is_appopen_ad_ready(String adUnitId)
    {
        return appLovinMAX.isAppOpenAdReady( adUnitId.trim() );
    }

    @UsedByGodot
    public void show_appopen_ad(String adUnitId, String placement, String customData)
    {
        appLovinMAX.showAppOpenAd( adUnitId.trim(), placement, customData );
    }

    @UsedByGodot
    public void set_appopen_ad_extra_parameter(String adUnitId, String key, String value)
    {
        appLovinMAX.setAppOpenAdExtraParameter( adUnitId.trim(), key, value );
    }

    @UsedByGodot
    public void set_appopen_ad_local_extra_parameter(String adUnitId, String key, Object value)
    {
        appLovinMAX.setAppOpenAdLocalExtraParameter( adUnitId.trim(), key, value );
    }

    //endregion

    //region Rewarded

    @UsedByGodot
    public void load_rewarded_ad(String adUnitId)
    {
        appLovinMAX.loadRewardedAd( adUnitId.trim() );
    }

    @UsedByGodot
    public boolean is_rewarded_ad_ready(String adUnitId)
    {
        return appLovinMAX.isRewardedAdReady( adUnitId.trim() );
    }

    @UsedByGodot
    public void show_rewarded_ad(String adUnitId, String placement, String customData)
    {
        appLovinMAX.showRewardedAd( adUnitId.trim(), placement, customData );
    }

    @UsedByGodot
    public void set_rewarded_ad_extra_parameter(String adUnitId, String key, String value)
    {
        appLovinMAX.setRewardedAdExtraParameter( adUnitId.trim(), key, value );
    }

    @UsedByGodot
    public void set_rewarded_ad_local_extra_parameter(String adUnitId, String key, Object value)
    {
        appLovinMAX.setRewardedAdLocalExtraParameter( adUnitId.trim(), key, value );
    }

    //endregion

    //region Event Tracking

    @UsedByGodot
    public void track_event(String name, Dictionary parameters)
    {
        if ( sdk == null ) return;

        sdk.getEventService().trackEvent( name, Utils.toJavaStringMap( parameters ) );
    }

    @UsedByGodot
    public void set_muted(boolean muted)
    {
        if ( sdk == null ) return;

        sdk.getSettings().setMuted( muted );
    }

    @UsedByGodot
    public boolean is_muted()
    {
        if ( sdk == null ) return false;

        return sdk.getSettings().isMuted();
    }

    @UsedByGodot
    public void set_verbose_logging(boolean enabled)
    {
        if ( sdk != null )
        {
            sdk.getSettings().setVerboseLogging( enabled );
            verboseLogging = null;
        }
        else
        {
            verboseLogging = enabled;
        }
    }

    @UsedByGodot
    public boolean is_verbose_logging_enabled()
    {
        if ( sdk != null )
        {
            return sdk.getSettings().isVerboseLoggingEnabled();
        }
        else if ( verboseLogging != null )
        {
            return verboseLogging;
        }

        return false;
    }

    @UsedByGodot
    public void set_creative_debugger_enabled(boolean enabled)
    {
        if ( sdk != null )
        {
            sdk.getSettings().setCreativeDebuggerEnabled( enabled );
            creativeDebuggerEnabled = null;
        }
        else
        {
            creativeDebuggerEnabled = enabled;
        }
    }

    @UsedByGodot
    public void set_test_device_advertising_identifiers(String[] advertisingIds)
    {
        testDeviceAdvertisingIds = Arrays.asList( advertisingIds );
    }

    @UsedByGodot
    public void set_exception_handler_enabled(boolean enabled)
    {
        if ( sdk != null )
        {
            sdk.getSettings().setExceptionHandlerEnabled( enabled );
            exceptionHandlerEnabled = null;
        }
        else
        {
            exceptionHandlerEnabled = enabled;
        }
    }

    @UsedByGodot
    public void set_extra_parameter(String key, String value)
    {
        if ( TextUtils.isEmpty( key ) )
        {
            Log.e( SDK_TAG, "[" + TAG + "] ERROR: Failed to set extra parameter for null or empty key: " + key );
            return;
        }

        if ( sdk != null )
        {
            AppLovinSdkSettings settings = sdk.getSettings();
            settings.setExtraParameter( key, value );
            setPendingExtraParametersIfNeeded( settings );
        }
        else
        {
            synchronized ( extraParametersToSetLock )
            {
                extraParametersToSet.put( key, value );
            }
        }
    }

    //region Private

    private Activity getCurrentActivity()
    {
        return activity != null ? activity.get() : getActivity();
    }

    private void setPendingExtraParametersIfNeeded(final AppLovinSdkSettings settings)
    {
        Map<String, String> extraParameters;
        synchronized ( extraParametersToSetLock )
        {
            if ( extraParametersToSet.size() <= 0 ) return;

            extraParameters = new HashMap<>( extraParametersToSet );
            extraParametersToSet.clear();
        }

        for ( final String key : extraParameters.keySet() )
        {
            settings.setExtraParameter( key, extraParameters.get( key ) );
        }
    }

    private AppLovinSdkSettings generateSdkSettings(final String[] adUnitIds, final Dictionary metaData)
    {
        AppLovinSdkSettings settings = new AppLovinSdkSettings( getCurrentActivity() );

        if ( testDeviceAdvertisingIds != null && !testDeviceAdvertisingIds.isEmpty() )
        {
            settings.setTestDeviceAdvertisingIds( testDeviceAdvertisingIds );
            testDeviceAdvertisingIds = null;
        }

        if ( verboseLogging != null )
        {
            settings.setVerboseLogging( verboseLogging );
            verboseLogging = null;
        }

        if ( creativeDebuggerEnabled != null )
        {
            settings.setCreativeDebuggerEnabled( creativeDebuggerEnabled );
            creativeDebuggerEnabled = null;
        }

        if ( exceptionHandlerEnabled != null )
        {
            settings.setExceptionHandlerEnabled( exceptionHandlerEnabled );
            exceptionHandlerEnabled = null;
        }

        settings.setInitializationAdUnitIds( Arrays.asList( adUnitIds ) );

        settings.setExtraParameter( "applovin_godot_metadata", Utils.toJSONString( metaData ) );

        return settings;
    }

    //endregion
}
