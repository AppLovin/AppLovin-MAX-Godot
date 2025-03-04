package com.applovin.godot;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.Rect;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;
import android.view.DisplayCutout;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.Window;
import android.view.WindowInsets;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.applovin.impl.sdk.utils.JsonUtils;
import com.applovin.impl.sdk.utils.StringUtils;
import com.applovin.mediation.MaxAd;
import com.applovin.mediation.MaxAdFormat;
import com.applovin.mediation.MaxAdListener;
import com.applovin.mediation.MaxAdRevenueListener;
import com.applovin.mediation.MaxAdViewAdListener;
import com.applovin.mediation.MaxAdWaterfallInfo;
import com.applovin.mediation.MaxError;
import com.applovin.mediation.MaxMediatedNetworkInfo;
import com.applovin.mediation.MaxNetworkResponseInfo;
import com.applovin.mediation.MaxReward;
import com.applovin.mediation.MaxRewardedAdListener;
import com.applovin.mediation.ads.MaxAdView;
import com.applovin.mediation.ads.MaxAppOpenAd;
import com.applovin.mediation.ads.MaxInterstitialAd;
import com.applovin.mediation.ads.MaxRewardedAd;
import com.applovin.sdk.AppLovinMediationProvider;
import com.applovin.sdk.AppLovinSdk;
import com.applovin.sdk.AppLovinSdkConfiguration;
import com.applovin.sdk.AppLovinSdkSettings;
import com.applovin.sdk.AppLovinSdkUtils;

import org.godotengine.godot.Dictionary;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.ThreadFactory;

import static com.applovin.godot.Utils.runSafelyOnUiThread;
import static com.applovin.sdk.AppLovinSdkUtils.runOnUiThread;

public class AppLovinMAXGodotManager
        implements MaxAdListener, MaxAdViewAdListener, MaxRewardedAdListener, MaxAdRevenueListener
{
    private static final String SDK_TAG = "AppLovinSdk";
    private static final String TAG     = "AppLovinMAXGodotManager";
    private static final String VERSION = "1.1.1";

    private static final String DEFAULT_AD_VIEW_POSITION = "top_left";
    private static final Point  DEFAULT_AD_VIEW_OFFSET   = new Point( 0, 0 );

    private static final ScheduledThreadPoolExecutor threadPoolExecutor = new ScheduledThreadPoolExecutor( 3, new SdkThreadFactory() );

    private static WeakReference<Activity> currentActivity;
    private static WeakReference<Activity> godotActivity;

    public interface Listener
    {
        void onSdkInitializationComplete(AppLovinSdkConfiguration appLovinSdkConfiguration);
    }

    /**
     * A class representing the safe area insets of the display cutout.
     */
    private static class Insets
    {
        int left;
        int top;
        int right;
        int bottom;
    }

    // Parent Fields
    private       AppLovinSdk                           sdk;
    private final WeakReference<AppLovinMAXGodotPlugin> plugin;

    // Fullscreen Ad Fields
    private final Map<String, MaxInterstitialAd>         interstitials;
    private final Map<String, MaxAppOpenAd>              appOpenAds;
    private final Map<String, MaxRewardedAd>             rewardedAds;

    // AdView Fields
    private final Map<String, MaxAdView>           adViews;
    private final Map<String, MaxAdFormat>         adViewAdFormats;
    private final Map<String, String>              adViewPositions;
    private final Map<String, Point>               adViewOffsets;
    private final Map<String, Integer>             adViewWidths;
    private final Map<String, Map<String, String>> adViewExtraParametersToSetAfterCreate;
    private final Map<String, Map<String, Object>> adViewLocalExtraParametersToSetAfterCreate;
    private final Map<String, String>              adViewCustomDataToSetAfterCreate;
    private final List<String>                     adUnitIdsToShowAfterCreate;
    private final Set<String>                      disabledAdaptiveBannerAdUnitIds;
    private final Set<String>                      disabledAutoRefreshAdViewAdUnitIds;
    private       View                             safeAreaBackground;
    private       Integer                          publisherBannerBackgroundColor = null;

    private final Map<String, MaxAd> adInfoMap;
    private final Object             adInfoMapLock;

    public AppLovinMAXGodotManager(final WeakReference<AppLovinMAXGodotPlugin> plugin)
    {
        this.plugin = plugin;
        interstitials = new HashMap<>( 2 );
        appOpenAds = new HashMap<>( 2 );
        rewardedAds = new HashMap<>( 2 );
        adViews = new HashMap<>( 2 );
        adViewAdFormats = new HashMap<>( 2 );
        adViewPositions = new HashMap<>( 2 );
        adViewOffsets = new HashMap<>( 2 );
        adViewWidths = new HashMap<>( 2 );
        adInfoMap = new HashMap<>();
        adInfoMapLock = new Object();
        adViewExtraParametersToSetAfterCreate = new HashMap<>( 1 );
        adViewLocalExtraParametersToSetAfterCreate = new HashMap<>( 1 );
        adViewCustomDataToSetAfterCreate = new HashMap<>( 1 );
        adUnitIdsToShowAfterCreate = new ArrayList<>( 2 );
        disabledAdaptiveBannerAdUnitIds = new HashSet<>( 2 );
        disabledAutoRefreshAdViewAdUnitIds = new HashSet<>( 2 );

        runOnUiThread( true, new Runnable()
        {
            @Override
            public void run()
            {
                safeAreaBackground = new View( getCurrentActivity() );
                safeAreaBackground.setVisibility( View.GONE );
                safeAreaBackground.setBackgroundColor( Color.TRANSPARENT );
                safeAreaBackground.setClickable( false );
                FrameLayout layout = new FrameLayout( getCurrentActivity() );
                layout.addView( safeAreaBackground, new FrameLayout.LayoutParams( 0, 0 ) );
                getCurrentActivity().addContentView( layout, new LinearLayout.LayoutParams( LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT ) );
            }
        } );

        // Enable orientation change listener, so that the ad view positions can be updated when the device is rotated.
        getCurrentActivity().getWindow().getDecorView().getRootView().addOnLayoutChangeListener( new View.OnLayoutChangeListener()
        {
            @Override
            public void onLayoutChange(final View view, final int left, final int top, final int right, final int bottom, final int oldLeft, final int oldTop, final int oldRight, final int oldBottom)
            {
                boolean viewBoundsChanged = left != oldLeft || right != oldRight || bottom != oldBottom || top != oldTop;
                if ( !viewBoundsChanged ) return;

                for ( final Map.Entry<String, MaxAdFormat> adUnitFormats : adViewAdFormats.entrySet() )
                {
                    positionAdView( adUnitFormats.getKey(), adUnitFormats.getValue() );
                }
            }
        } );
    }

    public static void setMainActivity(final Activity mainActivity)
    {
        if ( mainActivity != null )
        {
            AppLovinMAXGodotManager.currentActivity = new WeakReference<>( mainActivity );
        }
    }

    public static void setGodotActivity(final Activity godotActivity)
    {
        if ( godotActivity != null )
        {
            AppLovinMAXGodotManager.godotActivity = new WeakReference<>( godotActivity );
        }
    }

    public AppLovinSdk initializeSdkWithCompletionHandler(final String sdkKey,
                                                          final AppLovinSdkSettings settings,
                                                          final Listener listener)
    {
        final Activity currentActivity = getCurrentActivity();
        if ( StringUtils.isValidString( sdkKey ) )
        {
            sdk = AppLovinSdk.getInstance( sdkKey, settings, currentActivity );
        }
        else
        {
            sdk = AppLovinSdk.getInstance( settings, currentActivity );
        }

        sdk.setPluginVersion( "Godot-" + VERSION );
        sdk.setMediationProvider( AppLovinMediationProvider.MAX );
        sdk.initializeSdk( new AppLovinSdk.SdkInitializationListener()
        {
            @Override
            public void onSdkInitialized(final AppLovinSdkConfiguration config)
            {
                listener.onSdkInitializationComplete( config );
            }
        } );

        return sdk;
    }

    // BANNERS

    public void createBanner(final String adUnitId, final String bannerPosition)
    {
        createAdView( adUnitId, getAdViewAdFormat( adUnitId ), bannerPosition, DEFAULT_AD_VIEW_OFFSET );
    }

    public void createBanner(final String adUnitId, final float x, final float y)
    {
        createAdView( adUnitId, getAdViewAdFormat( adUnitId ), DEFAULT_AD_VIEW_POSITION, getOffsetPixels( x, y, getCurrentActivity() ) );
    }

    public void loadBanner(final String adUnitId)
    {
        loadAdView( adUnitId, getAdViewAdFormat( adUnitId ) );
    }

    public void setBannerPlacement(final String adUnitId, final String placement)
    {
        setAdViewPlacement( adUnitId, getAdViewAdFormat( adUnitId ), placement );
    }

    public void startBannerAutoRefresh(final String adUnitId)
    {
        startAdViewAutoRefresh( adUnitId, getAdViewAdFormat( adUnitId ) );
    }

    public void stopBannerAutoRefresh(final String adUnitId)
    {
        stopAdViewAutoRefresh( adUnitId, getAdViewAdFormat( adUnitId ) );
    }

    public void setBannerWidth(final String adUnitId, final int widthDp)
    {
        setAdViewWidth( adUnitId, widthDp, getAdViewAdFormat( adUnitId ) );
    }

    public void updateBannerPosition(final String adUnitId, final String bannerPosition)
    {
        updateAdViewPosition( adUnitId, bannerPosition, DEFAULT_AD_VIEW_OFFSET, getAdViewAdFormat( adUnitId ) );
    }

    public void updateBannerPosition(final String adUnitId, final float x, final float y)
    {
        updateAdViewPosition( adUnitId, DEFAULT_AD_VIEW_POSITION, getOffsetPixels( x, y, getCurrentActivity() ), getAdViewAdFormat( adUnitId ) );
    }

    public void showBanner(final String adUnitId)
    {
        showAdView( adUnitId, getAdViewAdFormat( adUnitId ) );
    }

    public void hideBanner(final String adUnitId)
    {
        hideAdView( adUnitId, getAdViewAdFormat( adUnitId ) );
    }

    public void destroyBanner(final String adUnitId)
    {
        destroyAdView( adUnitId, getAdViewAdFormat( adUnitId ) );
    }

    public void setBannerBackgroundColor(final String adUnitId, final String hexColorCode)
    {
        setAdViewBackgroundColor( adUnitId, getAdViewAdFormat( adUnitId ), hexColorCode );
    }

    public void setBannerExtraParameter(final String adUnitId, final String key, final String value)
    {
        setAdViewExtraParameter( adUnitId, getAdViewAdFormat( adUnitId ), key, value );
    }

    public void setBannerLocalExtraParameter(final String adUnitId, final String key, final Object value)
    {
        setAdViewLocalExtraParameter( adUnitId, getAdViewAdFormat( adUnitId ), key, value );
    }

    public void setBannerCustomData(final String adUnitId, final String customData)
    {
        setAdViewCustomData( adUnitId, getAdViewAdFormat( adUnitId ), customData );
    }

    public String getBannerLayout(final String adUnitId)
    {
        return getAdViewLayout( adUnitId, getAdViewAdFormat( adUnitId ) );
    }

    public static float getAdaptiveBannerHeight(final float width)
    {
        return getDeviceSpecificAdViewAdFormat().getAdaptiveSize( (int) width, getCurrentActivity() ).getHeight();
    }

    // MRECS

    public void createMRec(final String adUnitId, final String mrecPosition)
    {
        createAdView( adUnitId, MaxAdFormat.MREC, mrecPosition, DEFAULT_AD_VIEW_OFFSET );
    }

    public void createMRec(final String adUnitId, final float x, final float y)
    {
        createAdView( adUnitId, MaxAdFormat.MREC, DEFAULT_AD_VIEW_POSITION, getOffsetPixels( x, y, getCurrentActivity() ) );
    }

    public void loadMRec(final String adUnitId)
    {
        loadAdView( adUnitId, MaxAdFormat.MREC );
    }

    public void setMRecPlacement(final String adUnitId, final String placement)
    {
        setAdViewPlacement( adUnitId, MaxAdFormat.MREC, placement );
    }

    public void startMRecAutoRefresh(final String adUnitId)
    {
        startAdViewAutoRefresh( adUnitId, MaxAdFormat.MREC );
    }

    public void stopMRecAutoRefresh(final String adUnitId)
    {
        stopAdViewAutoRefresh( adUnitId, MaxAdFormat.MREC );
    }

    public void updateMRecPosition(final String adUnitId, final String mrecPosition)
    {
        updateAdViewPosition( adUnitId, mrecPosition, DEFAULT_AD_VIEW_OFFSET, MaxAdFormat.MREC );
    }

    public void updateMRecPosition(final String adUnitId, final float x, final float y)
    {
        updateAdViewPosition( adUnitId, DEFAULT_AD_VIEW_POSITION, getOffsetPixels( x, y, getCurrentActivity() ), MaxAdFormat.MREC );
    }

    public void showMRec(final String adUnitId)
    {
        showAdView( adUnitId, MaxAdFormat.MREC );
    }

    public void hideMRec(final String adUnitId)
    {
        hideAdView( adUnitId, MaxAdFormat.MREC );
    }

    public void setMRecExtraParameter(final String adUnitId, final String key, final String value)
    {
        setAdViewExtraParameter( adUnitId, MaxAdFormat.MREC, key, value );
    }

    public void setMRecLocalExtraParameter(final String adUnitId, final String key, final Object value)
    {
        setAdViewLocalExtraParameter( adUnitId, MaxAdFormat.MREC, key, value );
    }

    public void setMRecCustomData(final String adUnitId, final String customData)
    {
        setAdViewCustomData( adUnitId, MaxAdFormat.MREC, customData );
    }

    public String getMRecLayout(final String adUnitId)
    {
        return getAdViewLayout( adUnitId, MaxAdFormat.MREC );
    }

    public void destroyMRec(final String adUnitId)
    {
        destroyAdView( adUnitId, MaxAdFormat.MREC );
    }

    // INTERSTITIALS

    public void loadInterstitial(final String adUnitId)
    {
        MaxInterstitialAd interstitial = retrieveInterstitial( adUnitId );
        interstitial.loadAd();
    }

    public boolean isInterstitialReady(final String adUnitId)
    {
        MaxInterstitialAd interstitial = retrieveInterstitial( adUnitId );
        return interstitial.isReady();
    }

    public void showInterstitial(final String adUnitId, final String placement, final String customData)
    {
        MaxInterstitialAd interstitial = retrieveInterstitial( adUnitId );
        interstitial.showAd( placement, customData );
    }

    public void setInterstitialExtraParameter(final String adUnitId, final String key, final String value)
    {
        MaxInterstitialAd interstitial = retrieveInterstitial( adUnitId );
        interstitial.setExtraParameter( key, value );
    }

    public void setInterstitialLocalExtraParameter(final String adUnitId, final String key, final Object value)
    {
        MaxInterstitialAd interstitial = retrieveInterstitial( adUnitId );
        interstitial.setLocalExtraParameter( key, value );
    }

    // APP OPEN ADS

    public void loadAppOpenAd(final String adUnitId)
    {
        MaxAppOpenAd appOpenAd = retrieveAppOpenAd( adUnitId );
        appOpenAd.loadAd();
    }

    public boolean isAppOpenAdReady(final String adUnitId)
    {
        MaxAppOpenAd appOpenAd = retrieveAppOpenAd( adUnitId );
        return appOpenAd.isReady();
    }

    public void showAppOpenAd(final String adUnitId, final String placement, final String customData)
    {
        MaxAppOpenAd appOpenAd = retrieveAppOpenAd( adUnitId );
        appOpenAd.showAd( placement, customData );
    }

    public void setAppOpenAdExtraParameter(final String adUnitId, final String key, final String value)
    {
        MaxAppOpenAd appOpenAd = retrieveAppOpenAd( adUnitId );
        appOpenAd.setExtraParameter( key, value );
    }

    public void setAppOpenAdLocalExtraParameter(final String adUnitId, final String key, final Object value)
    {
        MaxAppOpenAd appOpenAd = retrieveAppOpenAd( adUnitId );
        appOpenAd.setLocalExtraParameter( key, value );
    }

    // REWARDED

    public void loadRewardedAd(final String adUnitId)
    {
        MaxRewardedAd rewardedAd = retrieveRewardedAd( adUnitId );
        rewardedAd.loadAd();
    }

    public boolean isRewardedAdReady(final String adUnitId)
    {
        MaxRewardedAd rewardedAd = retrieveRewardedAd( adUnitId );
        return rewardedAd.isReady();
    }

    public void showRewardedAd(final String adUnitId, final String placement, final String customData)
    {
        MaxRewardedAd rewardedAd = retrieveRewardedAd( adUnitId );
        rewardedAd.showAd( placement, customData );
    }

    public void setRewardedAdExtraParameter(final String adUnitId, final String key, final String value)
    {
        MaxRewardedAd rewardedAd = retrieveRewardedAd( adUnitId );
        rewardedAd.setExtraParameter( key, value );
    }

    public void setRewardedAdLocalExtraParameter(final String adUnitId, final String key, final Object value)
    {
        MaxRewardedAd rewardedAd = retrieveRewardedAd( adUnitId );
        rewardedAd.setLocalExtraParameter( key, value );
    }

    // AD INFO

    private Dictionary getAdInfo(final MaxAd ad)
    {
        Dictionary adInfo = new Dictionary();
        adInfo.put( "adUnitId", ad.getAdUnitId() );
        adInfo.put( "adFormat", ad.getFormat().getLabel() );
        adInfo.put( "networkName", ad.getNetworkName() );
        adInfo.put( "creativeId", !TextUtils.isEmpty( ad.getCreativeId() ) ? ad.getCreativeId() : "" );
        adInfo.put( "placement", !TextUtils.isEmpty( ad.getPlacement() ) ? ad.getPlacement() : "" );
        adInfo.put( "revenue", ad.getRevenue() );
        adInfo.put( "revenuePrecision", ad.getRevenuePrecision() );
        adInfo.put( "waterfallInfo", createAdWaterfallInfo( ad.getWaterfall() ) );
        adInfo.put( "dspName", !TextUtils.isEmpty( ad.getDspName() ) ? ad.getDspName() : "" );

        return adInfo;
    }

    // AD WATERFALL INFO

    private Dictionary createAdWaterfallInfo(final MaxAdWaterfallInfo waterfallInfo)
    {
        Dictionary waterfallInfoObject = new Dictionary();
        if ( waterfallInfo == null ) return waterfallInfoObject;

        waterfallInfoObject.put( "name", waterfallInfo.getName() );
        waterfallInfoObject.put( "testName", waterfallInfo.getTestName() );

        final List<MaxNetworkResponseInfo> networkResponseInfo = waterfallInfo.getNetworkResponses();
        final int networkResponseInfoSize = networkResponseInfo.size();
        Object[] networkResponsesArray = new Object[networkResponseInfoSize];
        for ( int i = 0; i < networkResponseInfoSize; i++ )
        {
            networkResponsesArray[i] = createNetworkResponseInfo( networkResponseInfo.get( i ) );
        }
        waterfallInfoObject.put( "networkResponses", networkResponsesArray );

        waterfallInfoObject.put( "latencyMillis", String.valueOf( waterfallInfo.getLatencyMillis() ) );

        return waterfallInfoObject;
    }

    private Dictionary createNetworkResponseInfo(final MaxNetworkResponseInfo response)
    {
        Dictionary networkResponseObject = new Dictionary();

        networkResponseObject.put( "adLoadState", response.getAdLoadState().ordinal() );

        MaxMediatedNetworkInfo mediatedNetworkInfo = response.getMediatedNetwork();
        if ( mediatedNetworkInfo != null )
        {
            Dictionary networkInfoObject = new Dictionary();
            networkInfoObject.put( "name", response.getMediatedNetwork().getName() );
            networkInfoObject.put( "adapterClassName", response.getMediatedNetwork().getAdapterClassName() );
            networkInfoObject.put( "adapterVersion", response.getMediatedNetwork().getAdapterVersion() );
            networkInfoObject.put( "sdkVersion", response.getMediatedNetwork().getSdkVersion() );

            networkResponseObject.put( "mediatedNetwork", networkInfoObject );
        }

        networkResponseObject.put( "credentials", Utils.toGodotDictionary( response.getCredentials() ) );
        networkResponseObject.put( "isBidding", response.isBidding() );

        MaxError error = response.getError();
        if ( error != null )
        {
            Dictionary errorObject = new Dictionary();
            errorObject.put( "errorMessage", error.getMessage() );
            errorObject.put( "adLoadFailureInfo", error.getAdLoadFailureInfo() );
            errorObject.put( "errorCode", Integer.toString( error.getCode() ) );

            networkResponseObject.put( "error", errorObject );
        }

        networkResponseObject.put( "latencyMillis", response.getLatencyMillis() );

        return networkResponseObject;
    }

    // AD VALUE

    public String getAdValue(final String adUnitId, final String key)
    {
        if ( TextUtils.isEmpty( adUnitId ) ) return "";

        final MaxAd ad = getAd( adUnitId );
        if ( ad == null ) return "";

        return ad.getAdValue( key );
    }

    // AD CALLBACKS

    @Override
    public void onAdLoaded(MaxAd ad)
    {
        String signalName;
        MaxAdFormat adFormat = ad.getFormat();
        if ( adFormat.isAdViewAd() )
        {
            if ( MaxAdFormat.MREC == adFormat )
            {
                signalName = Signal.MREC_ON_AD_LOADED;
            }
            else
            {
                signalName = Signal.BANNER_ON_AD_LOADED;
            }
            positionAdView( ad );

            // Do not auto-refresh by default if the ad view is not showing yet (e.g. first load during app launch and publisher does not automatically show banner upon load success)
            // We will resume auto-refresh in {@link #showBanner(String)}.
            MaxAdView adView = retrieveAdView( ad.getAdUnitId(), adFormat );
            if ( adView != null && adView.getVisibility() != View.VISIBLE )
            {
                adView.stopAutoRefresh();
            }
        }
        else if ( MaxAdFormat.INTERSTITIAL == adFormat )
        {
            signalName = Signal.INTERSTITIAL_ON_AD_LOADED;
        }
        else if ( MaxAdFormat.APP_OPEN == adFormat )
        {
            signalName = Signal.APP_OPEN_ON_AD_LOADED;
        }
        else if ( MaxAdFormat.REWARDED == adFormat )
        {
            signalName = Signal.REWARDED_ON_AD_LOADED;
        }
        else
        {
            logInvalidAdFormat( adFormat );
            return;
        }

        synchronized ( adInfoMapLock )
        {
            adInfoMap.put( ad.getAdUnitId(), ad );
        }

        Dictionary adInfo = getAdInfo( ad );
        Utils.runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                plugin.get().emitSignal( signalName, ad.getAdUnitId(), adInfo );
            }
        } );
    }

    @Override
    public void onAdLoadFailed(final String adUnitId, final MaxError error)
    {
        if ( TextUtils.isEmpty( adUnitId ) )
        {
            logStackTrace( new IllegalArgumentException( "adUnitId cannot be null" ) );
            return;
        }

        String signalName;
        if ( adViews.containsKey( adUnitId ) )
        {
            MaxAdFormat adViewAdFormat = adViewAdFormats.get( adUnitId );
            if ( MaxAdFormat.MREC == adViewAdFormat )
            {
                signalName = Signal.MREC_ON_AD_LOAD_FAILED;
            }
            else
            {
                signalName = Signal.BANNER_ON_AD_LOAD_FAILED;
            }
        }
        else if ( interstitials.containsKey( adUnitId ) )
        {
            signalName = Signal.INTERSTITIAL_ON_AD_LOAD_FAILED;
        }
        else if ( appOpenAds.containsKey( adUnitId ) )
        {
            signalName = Signal.APP_OPEN_ON_AD_LOAD_FAILED;
        }
        else if ( rewardedAds.containsKey( adUnitId ) )
        {
            signalName = Signal.REWARDED_ON_AD_LOAD_FAILED;
        }
        else
        {
            logStackTrace( new IllegalStateException( "invalid adUnitId: " + adUnitId ) );
            return;
        }

        synchronized ( adInfoMapLock )
        {
            adInfoMap.remove( adUnitId );
        }

        Dictionary errorInfo = new Dictionary();
        errorInfo.put( "name", signalName );
        errorInfo.put( "errorCode", Integer.toString( error.getCode() ) );
        errorInfo.put( "errorMessage", error.getMessage() );
        errorInfo.put( "waterfallInfo", createAdWaterfallInfo( error.getWaterfall() ) );

        Utils.runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                plugin.get().emitSignal( signalName, adUnitId, errorInfo );
            }
        } );
    }

    @Override
    public void onAdClicked(final MaxAd ad)
    {
        final MaxAdFormat adFormat = ad.getFormat();
        final String signalName;
        if ( MaxAdFormat.BANNER == adFormat || MaxAdFormat.LEADER == adFormat )
        {
            signalName = Signal.BANNER_ON_AD_CLICKED;
        }
        else if ( MaxAdFormat.MREC == adFormat )
        {
            signalName = Signal.MREC_ON_AD_CLICKED;
        }
        else if ( MaxAdFormat.INTERSTITIAL == adFormat )
        {
            signalName = Signal.INTERSTITIAL_ON_AD_CLICKED;
        }
        else if ( MaxAdFormat.APP_OPEN == adFormat )
        {
            signalName = Signal.APP_OPEN_ON_AD_CLICKED;
        }
        else if ( MaxAdFormat.REWARDED == adFormat )
        {
            signalName = Signal.REWARDED_ON_AD_CLICKED;
        }
        else
        {
            logInvalidAdFormat( adFormat );
            return;
        }

        Dictionary adInfo = getAdInfo( ad );
        Utils.runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                plugin.get().emitSignal( signalName, ad.getAdUnitId(), adInfo );
            }
        } );
    }

    @Override
    public void onAdDisplayed(final MaxAd ad)
    {
        // BMLs do not support [DISPLAY]
        final MaxAdFormat adFormat = ad.getFormat();
        if ( !adFormat.isFullscreenAd() ) return;

        final String signalName;
        if ( MaxAdFormat.INTERSTITIAL == adFormat )
        {
            signalName = Signal.INTERSTITIAL_ON_AD_DISPLAYED;
        }
        else if ( MaxAdFormat.APP_OPEN == adFormat )
        {
            signalName = Signal.APP_OPEN_ON_AD_DISPLAYED;
        }
        else if ( MaxAdFormat.REWARDED == adFormat )
        {
            signalName = Signal.REWARDED_ON_AD_DISPLAYED;
        }
        else
        {
            logInvalidAdFormat( adFormat );
            return;
        }

        Dictionary adInfo = getAdInfo( ad );
        Utils.runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                plugin.get().emitSignal( signalName, ad.getAdUnitId(), adInfo );
            }
        } );
    }

    @Override
    public void onAdDisplayFailed(final MaxAd ad, final MaxError error)
    {
        // BMLs do not support [DISPLAY]
        final MaxAdFormat adFormat = ad.getFormat();
        if ( !adFormat.isFullscreenAd() ) return;

        final String signalName;
        if ( MaxAdFormat.INTERSTITIAL == adFormat )
        {
            signalName = Signal.INTERSTITIAL_ON_AD_DISPLAY_FAILED;
        }
        else if ( MaxAdFormat.APP_OPEN == adFormat )
        {
            signalName = Signal.APP_OPEN_ON_AD_DISPLAY_FAILED;
        }
        else if ( MaxAdFormat.REWARDED == adFormat )
        {
            signalName = Signal.REWARDED_ON_AD_DISPLAY_FAILED;
        }
        else
        {
            logInvalidAdFormat( adFormat );
            return;
        }

        Dictionary adInfo = getAdInfo( ad );

        Dictionary errorInfo = new Dictionary();
        errorInfo.put( "errorCode", Integer.toString( error.getCode() ) );
        errorInfo.put( "errorMessage", error.getMessage() );
        errorInfo.put( "mediatedNetworkErrorCode", Integer.toString( error.getMediatedNetworkErrorCode() ) );
        errorInfo.put( "mediatedNetworkErrorMessage", error.getMediatedNetworkErrorMessage() );
        errorInfo.put( "waterfallInfo", createAdWaterfallInfo( error.getWaterfall() ) );

        Utils.runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                plugin.get().emitSignal( signalName, ad.getAdUnitId(), errorInfo, adInfo );
            }
        } );
    }

    @Override
    public void onAdHidden(final MaxAd ad)
    {
        // BMLs do not support [HIDDEN]
        final MaxAdFormat adFormat = ad.getFormat();
        if ( !adFormat.isFullscreenAd() ) return;

        String signalName;
        if ( MaxAdFormat.INTERSTITIAL == adFormat )
        {
            signalName = Signal.INTERSTITIAL_ON_AD_HIDDEN;
        }
        else if ( MaxAdFormat.APP_OPEN == adFormat )
        {
            signalName = Signal.APP_OPEN_ON_AD_HIDDEN;
        }
        else if ( MaxAdFormat.REWARDED == adFormat )
        {
            signalName = Signal.REWARDED_ON_AD_HIDDEN;
        }
        else
        {
            logInvalidAdFormat( adFormat );
            return;
        }

        Dictionary adInfo = getAdInfo( ad );

        Utils.runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                plugin.get().emitSignal( signalName, ad.getAdUnitId(), adInfo );
            }
        } );
    }

    @Override
    public void onUserRewarded(final MaxAd ad, final MaxReward reward)
    {
        final MaxAdFormat adFormat = ad.getFormat();
        if ( adFormat != MaxAdFormat.REWARDED )
        {
            logInvalidAdFormat( adFormat );
            return;
        }

        final String rewardLabel = reward != null ? reward.getLabel() : "";
        final int rewardAmountInt = reward != null ? reward.getAmount() : 0;
        final String rewardAmount = Integer.toString( rewardAmountInt );

        final String signalName = Signal.REWARDED_ON_AD_RECEIVED_REWARD;

        Dictionary adInfo = getAdInfo( ad );

        Dictionary rewardInfo = new Dictionary();
        rewardInfo.put( "label", rewardLabel );
        rewardInfo.put( "amount", rewardAmount );

        Utils.runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                plugin.get().emitSignal( signalName, ad.getAdUnitId(), rewardInfo, adInfo );
            }
        } );
    }

    @Override
    public void onAdRevenuePaid(final MaxAd ad)
    {
        final MaxAdFormat adFormat = ad.getFormat();
        final String signalName;
        if ( MaxAdFormat.BANNER == adFormat || MaxAdFormat.LEADER == adFormat )
        {
            signalName = Signal.BANNER_ON_AD_REVENUE_PAID;
        }
        else if ( MaxAdFormat.MREC == adFormat )
        {
            signalName = Signal.MREC_ON_AD_REVENUE_PAID;
        }
        else if ( MaxAdFormat.INTERSTITIAL == adFormat )
        {
            signalName = Signal.INTERSTITIAL_ON_AD_REVENUE_PAID;
        }
        else if ( MaxAdFormat.APP_OPEN == adFormat )
        {
            signalName = Signal.APP_OPEN_ON_AD_REVENUE_PAID;
        }
        else if ( MaxAdFormat.REWARDED == adFormat )
        {
            signalName = Signal.REWARDED_ON_AD_REVENUE_PAID;
        }
        else
        {
            logInvalidAdFormat( adFormat );
            return;
        }

        Dictionary adInfo = getAdInfo( ad );

        Utils.runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                plugin.get().emitSignal( signalName, ad.getAdUnitId(), adInfo );
            }
        } );
    }

    @Override
    public void onAdExpanded(final MaxAd ad)
    {
        final MaxAdFormat adFormat = ad.getFormat();
        if ( !adFormat.isAdViewAd() ) return;

        final String signalName;
        if ( MaxAdFormat.BANNER == adFormat || MaxAdFormat.LEADER == adFormat )
        {
            signalName = Signal.BANNER_ON_AD_EXPANDED;
        }
        else if ( MaxAdFormat.MREC == adFormat )
        {
            signalName = Signal.MREC_ON_AD_EXPANDED;
        }
        else
        {
            logInvalidAdFormat( adFormat );
            return;
        }

        Dictionary adInfo = getAdInfo( ad );
        Utils.runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                plugin.get().emitSignal( signalName, ad.getAdUnitId(), adInfo );
            }
        } );
    }

    @Override
    public void onAdCollapsed(final MaxAd ad)
    {
        final MaxAdFormat adFormat = ad.getFormat();
        if ( !adFormat.isAdViewAd() ) return;

        final String signalName;
        if ( MaxAdFormat.BANNER == adFormat || MaxAdFormat.LEADER == adFormat )
        {
            signalName = Signal.BANNER_ON_AD_COLLAPSED;
        }
        else if ( MaxAdFormat.MREC == adFormat )
        {
            signalName = Signal.MREC_ON_AD_COLLAPSED;
        }
        else
        {
            logInvalidAdFormat( adFormat );
            return;
        }

        Dictionary adInfo = getAdInfo( ad );
        Utils.runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                plugin.get().emitSignal( signalName, ad.getAdUnitId(), adInfo );
            }
        } );
    }

    // INTERNAL METHODS

    private void createAdView(final String adUnitId, final MaxAdFormat adFormat, final String adViewPosition, final Point adViewOffsetPixels)
    {
        // Run on main thread to ensure there are no concurrency issues with other ad view methods
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Creating " + adFormat.getLabel() + " with ad unit id \"" + adUnitId + "\" and position: \"" + adViewPosition + "\"" );

                //Check if a banner was already created with the ad unit ID
                if ( adViews.get( adUnitId ) != null )
                {
                    Log.w( TAG, "Trying to create a " + adFormat.getLabel() + " that was already created. This will cause the current ad to be hidden." );
                }

                // Retrieve ad view from the map
                final MaxAdView adView = retrieveAdView( adUnitId, adFormat, adViewPosition, adViewOffsetPixels );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist" );
                    return;
                }

                safeAreaBackground.setVisibility( View.GONE );
                adView.setVisibility( View.GONE );

                if ( adView.getParent() == null )
                {
                    final Activity currentActivity = getCurrentActivity();
                    final RelativeLayout relativeLayout = new RelativeLayout( currentActivity );
                    currentActivity.addContentView( relativeLayout, new LinearLayout.LayoutParams( LinearLayout.LayoutParams.MATCH_PARENT,
                                                                                                   LinearLayout.LayoutParams.MATCH_PARENT ) );
                    relativeLayout.addView( adView );

                    // Position ad view immediately so if publisher sets color before ad loads, it will not be the size of the screen
                    adViewAdFormats.put( adUnitId, adFormat );
                    positionAdView( adUnitId, adFormat );
                }

                // Enable adaptive banners by default.
                if ( !adViewExtraParametersToSetAfterCreate.containsKey( "adaptive_banner" ) && ( adFormat == MaxAdFormat.BANNER || adFormat == MaxAdFormat.LEADER ) )
                {
                    adView.setExtraParameter( "adaptive_banner", "true" );
                }

                // Handle initial extra parameters if publisher sets it before creating ad view
                if ( adViewExtraParametersToSetAfterCreate.containsKey( adUnitId ) )
                {
                    Map<String, String> extraParameters = adViewExtraParametersToSetAfterCreate.get( adUnitId );
                    if ( extraParameters != null )
                    {
                        for ( Map.Entry<String, String> extraParameter : extraParameters.entrySet() )
                        {
                            adView.setExtraParameter( extraParameter.getKey(), extraParameter.getValue() );

                            maybeHandleExtraParameterChanges( adUnitId, adFormat, extraParameter.getKey(), extraParameter.getValue() );
                        }

                        adViewExtraParametersToSetAfterCreate.remove( adUnitId );
                    }
                }

                // Handle initial local extra parameters if publisher sets it before creating ad view
                if ( adViewLocalExtraParametersToSetAfterCreate.containsKey( adUnitId ) )
                {
                    Map<String, Object> localExtraParameters = adViewLocalExtraParametersToSetAfterCreate.get( adUnitId );
                    if ( localExtraParameters != null )
                    {
                        for ( final Map.Entry<String, Object> localExtraParameter : localExtraParameters.entrySet() )
                        {
                            adView.setLocalExtraParameter( localExtraParameter.getKey(), localExtraParameter.getValue() );
                        }

                        adViewLocalExtraParametersToSetAfterCreate.remove( adUnitId );
                    }
                }

                // Handle initial custom data if publisher sets it before creating ad view
                if ( adViewCustomDataToSetAfterCreate.containsKey( adUnitId ) )
                {
                    String customData = adViewCustomDataToSetAfterCreate.get( adUnitId );
                    adView.setCustomData( customData );

                    adViewCustomDataToSetAfterCreate.remove( adUnitId );
                }

                adView.loadAd();

                // Disable auto-refresh if publisher sets it before creating the ad view.
                if ( disabledAutoRefreshAdViewAdUnitIds.contains( adUnitId ) )
                {
                    adView.stopAutoRefresh();
                }

                // The publisher may have requested to show the banner before it was created. Now that the banner is created, show it.
                if ( adUnitIdsToShowAfterCreate.contains( adUnitId ) )
                {
                    showAdView( adUnitId, adFormat );
                    adUnitIdsToShowAfterCreate.remove( adUnitId );
                }
            }
        } );
    }

    private void loadAdView(final String adUnitId, final MaxAdFormat adFormat)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist" );
                    return;
                }

                if ( !disabledAutoRefreshAdViewAdUnitIds.contains( adUnitId ) )
                {
                    if ( adView.getVisibility() != View.VISIBLE )
                    {
                        e( "Auto-refresh will resume when the " + adFormat.getLabel() + " ad is shown. You should only call LoadBanner() or LoadMRec() if you explicitly pause auto-refresh and want to manually load an ad." );
                        return;
                    }

                    e( "You must stop auto-refresh if you want to manually load " + adFormat.getLabel() + " ads." );
                    return;
                }

                adView.loadAd();
            }
        } );
    }

    private void setAdViewPlacement(final String adUnitId, final MaxAdFormat adFormat, final String placement)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Setting placement \"" + placement + "\" for " + adFormat.getLabel() + " with ad unit id \"" + adUnitId + "\"" );

                final MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist" );
                    return;
                }

                adView.setPlacement( placement );
            }
        } );
    }

    private void startAdViewAutoRefresh(final String adUnitId, final MaxAdFormat adFormat)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Starting " + adFormat.getLabel() + " auto refresh for ad unit identifier \"" + adUnitId + "\"" );

                disabledAutoRefreshAdViewAdUnitIds.remove( adUnitId );

                MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist for ad unit identifier \"" + adUnitId + "\"" );
                    return;
                }

                adView.startAutoRefresh();
            }
        } );
    }

    private void stopAdViewAutoRefresh(final String adUnitId, final MaxAdFormat adFormat)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Stopping " + adFormat.getLabel() + " auto refresh for ad unit identifier \"" + adUnitId + "\"" );

                disabledAutoRefreshAdViewAdUnitIds.add( adUnitId );

                MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist for ad unit identifier \"" + adUnitId + "\"" );
                    return;
                }

                adView.stopAutoRefresh();
            }
        } );
    }

    private void setAdViewWidth(final String adUnitId, final int widthDp, final MaxAdFormat adFormat)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Setting width " + widthDp + " for \"" + adFormat + "\" with ad unit identifier \"" + adUnitId + "\"" );

                int minWidthDp = adFormat.getSize().getWidth();
                if ( widthDp < minWidthDp )
                {
                    e( "The provided width: " + widthDp + "dp is smaller than the minimum required width: " + minWidthDp + "dp for ad format: " + adFormat + ". Please set the width higher than the minimum required." );
                }

                adViewWidths.put( adUnitId, widthDp );
                positionAdView( adUnitId, adFormat );
            }
        } );
    }

    private void updateAdViewPosition(final String adUnitId, final String adViewPosition, final Point offsetPixels, final MaxAdFormat adFormat)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Updating " + adFormat.getLabel() + " position to \"" + adViewPosition + "\" for ad unit id \"" + adUnitId + "\"" );

                // Retrieve ad view from the map
                final MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist" );
                    return;
                }

                adViewPositions.put( adUnitId, adViewPosition );
                adViewOffsets.put( adUnitId, offsetPixels );
                positionAdView( adUnitId, adFormat );
            }
        } );
    }

    private void showAdView(final String adUnitId, final MaxAdFormat adFormat)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Showing " + adFormat.getLabel() + " with ad unit id \"" + adUnitId + "\"" );

                final MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist for ad unit id " + adUnitId );

                    // The adView has not yet been created. Store the ad unit ID, so that it can be displayed once the banner has been created.
                    adUnitIdsToShowAfterCreate.add( adUnitId );
                    return;
                }

                safeAreaBackground.setVisibility( View.VISIBLE );
                adView.setVisibility( View.VISIBLE );

                if ( !disabledAutoRefreshAdViewAdUnitIds.contains( adUnitId ) )
                {
                    adView.startAutoRefresh();
                }
            }
        } );
    }

    private void hideAdView(final String adUnitId, final MaxAdFormat adFormat)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Hiding " + adFormat.getLabel() + " with ad unit id \"" + adUnitId + "\"" );
                adUnitIdsToShowAfterCreate.remove( adUnitId );

                final MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist" );
                    return;
                }

                safeAreaBackground.setVisibility( View.GONE );
                adView.setVisibility( View.GONE );
                adView.stopAutoRefresh();
            }
        } );
    }

    private String getAdViewLayout(final String adUnitId, final MaxAdFormat adFormat)
    {
        d( "Getting " + adFormat.getLabel() + " absolute position with ad unit id \"" + adUnitId + "\"" );

        MaxAdView adView = retrieveAdView( adUnitId, adFormat );
        if ( adView == null )
        {
            e( adFormat.getLabel() + " does not exist" );
            return "";
        }

        int[] location = new int[2];
        adView.getLocationOnScreen( location );

        int originX = AppLovinSdkUtils.pxToDp( getCurrentActivity(), location[0] );
        int originY = AppLovinSdkUtils.pxToDp( getCurrentActivity(), location[1] );
        int width = AppLovinSdkUtils.pxToDp( getCurrentActivity(), adView.getWidth() );
        int height = AppLovinSdkUtils.pxToDp( getCurrentActivity(), adView.getHeight() );

        JSONObject rectMap = new JSONObject();
        JsonUtils.putString( rectMap, "origin_x", String.valueOf( originX ) );
        JsonUtils.putString( rectMap, "origin_y", String.valueOf( originY ) );
        JsonUtils.putString( rectMap, "width", String.valueOf( width ) );
        JsonUtils.putString( rectMap, "height", String.valueOf( height ) );

        return rectMap.toString();
    }

    private void destroyAdView(final String adUnitId, final MaxAdFormat adFormat)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Destroying " + adFormat.getLabel() + " with ad unit id \"" + adUnitId + "\"" );

                final MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist" );
                    return;
                }

                final ViewParent parent = adView.getParent();
                if ( parent instanceof ViewGroup )
                {
                    ( (ViewGroup) parent ).removeView( adView );
                }

                adView.setListener( null );
                adView.setRevenueListener( null );
                adView.setAdReviewListener( null );
                adView.destroy();

                adViews.remove( adUnitId );
                adViewAdFormats.remove( adUnitId );
                adViewPositions.remove( adUnitId );
                adViewOffsets.remove( adUnitId );
                adViewWidths.remove( adUnitId );
                disabledAdaptiveBannerAdUnitIds.remove( adUnitId );
            }
        } );
    }

    private void setAdViewBackgroundColor(final String adUnitId, final MaxAdFormat adFormat, final String hexColorCode)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Setting " + adFormat.getLabel() + " with ad unit id \"" + adUnitId + "\" to color: " + hexColorCode );

                final MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist" );
                    return;
                }

                int backgroundColor = Color.parseColor( hexColorCode );
                publisherBannerBackgroundColor = backgroundColor;
                safeAreaBackground.setBackgroundColor( backgroundColor );
                adView.setBackgroundColor( backgroundColor );
            }
        } );
    }

    private void setAdViewExtraParameter(final String adUnitId, final MaxAdFormat adFormat, final String key, final String value)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Setting " + adFormat.getLabel() + " extra with key: \"" + key + "\" value: " + value );

                // Retrieve ad view from the map
                final MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView != null )
                {
                    adView.setExtraParameter( key, value );
                }
                else
                {
                    d( adFormat.getLabel() + " does not exist for ad unit ID " + adUnitId + ". Saving extra parameter to be set when it is created." );

                    // The adView has not yet been created. Store the extra parameters, so that they can be added once the banner has been created.
                    Map<String, String> extraParameters = adViewExtraParametersToSetAfterCreate.get( adUnitId );
                    if ( extraParameters == null )
                    {
                        extraParameters = new HashMap<>( 1 );
                        adViewExtraParametersToSetAfterCreate.put( adUnitId, extraParameters );
                    }

                    extraParameters.put( key, value );
                }

                // Certain extra parameters need to be handled immediately
                maybeHandleExtraParameterChanges( adUnitId, adFormat, key, value );
            }
        } );
    }

    private void setAdViewLocalExtraParameter(final String adUnitId, final MaxAdFormat adFormat, final String key, final Object value)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                d( "Setting " + adFormat.getLabel() + " local extra with key: \"" + key + "\" value: " + value );

                // Retrieve ad view from the map
                final MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView != null )
                {
                    adView.setLocalExtraParameter( key, value );
                }
                else
                {
                    d( adFormat.getLabel() + " does not exist for ad unit ID " + adUnitId + ". Saving local extra parameter to be set when it is created." );

                    // The adView has not yet been created. Store the local extra parameters, so that they can be added once the adview has been created.
                    Map<String, Object> localExtraParameters = adViewLocalExtraParametersToSetAfterCreate.get( adUnitId );
                    if ( localExtraParameters == null )
                    {
                        localExtraParameters = new HashMap<>( 1 );
                        adViewLocalExtraParametersToSetAfterCreate.put( adUnitId, localExtraParameters );
                    }

                    localExtraParameters.put( key, value );
                }
            }
        } );
    }

    private void maybeHandleExtraParameterChanges(final String adUnitId, final MaxAdFormat adFormat, final String key, final String value)
    {
        if ( MaxAdFormat.MREC != adFormat )
        {
            if ( "force_banner".equalsIgnoreCase( key ) )
            {
                boolean shouldForceBanner = Boolean.parseBoolean( value );
                MaxAdFormat forcedAdFormat = shouldForceBanner ? MaxAdFormat.BANNER : getDeviceSpecificAdViewAdFormat();

                adViewAdFormats.put( adUnitId, forcedAdFormat );
                positionAdView( adUnitId, forcedAdFormat );
            }
            else if ( "adaptive_banner".equalsIgnoreCase( key ) )
            {
                boolean useAdaptiveBannerAdSize = Boolean.parseBoolean( value );
                if ( useAdaptiveBannerAdSize )
                {
                    disabledAdaptiveBannerAdUnitIds.remove( adUnitId );
                }
                else
                {
                    disabledAdaptiveBannerAdUnitIds.add( adUnitId );
                }

                positionAdView( adUnitId, adFormat );
            }
        }
    }

    private void setAdViewCustomData(final String adUnitId, final MaxAdFormat adFormat, final String customData)
    {
        runSafelyOnUiThread( getCurrentActivity(), new Runnable()
        {
            @Override
            public void run()
            {
                // Retrieve ad view from the map
                final MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView != null )
                {
                    adView.setCustomData( customData );
                }
                else
                {
                    d( adFormat.getLabel() + " does not exist for ad unit ID " + adUnitId + ". Saving custom data to be set when it is created." );

                    // The adView has not yet been created. Store the custom data, so that they can be added once the AdView has been created.
                    adViewCustomDataToSetAfterCreate.put( adUnitId, customData );
                }
            }
        } );
    }

    private void logInvalidAdFormat(MaxAdFormat adFormat)
    {
        logStackTrace( new IllegalStateException( "invalid ad format: " + adFormat ) );
    }

    private void logStackTrace(Exception e)
    {
        e( Log.getStackTraceString( e ) );
    }

    private static void d(final String message)
    {
        final String fullMessage = "[" + TAG + "] " + message;
        Log.d( SDK_TAG, fullMessage );
    }

    private static void e(final String message)
    {
        final String fullMessage = "[" + TAG + "] " + message;
        Log.e( SDK_TAG, fullMessage );
    }

    private MaxInterstitialAd retrieveInterstitial(final String adUnitId)
    {
        MaxInterstitialAd result = interstitials.get( adUnitId );
        if ( result == null )
        {
            result = new MaxInterstitialAd( adUnitId, sdk, getCurrentActivity() );
            result.setListener( this );
            result.setRevenueListener( this );

            interstitials.put( adUnitId, result );
        }

        return result;
    }

    private MaxAppOpenAd retrieveAppOpenAd(final String adUnitId)
    {
        MaxAppOpenAd result = appOpenAds.get( adUnitId );
        if ( result == null )
        {
            result = new MaxAppOpenAd( adUnitId, sdk );
            result.setListener( this );
            result.setRevenueListener( this );

            appOpenAds.put( adUnitId, result );
        }

        return result;
    }

    private MaxRewardedAd retrieveRewardedAd(final String adUnitId)
    {
        MaxRewardedAd result = rewardedAds.get( adUnitId );
        if ( result == null )
        {
            result = MaxRewardedAd.getInstance( adUnitId, sdk, getCurrentActivity() );
            result.setListener( this );
            result.setRevenueListener( this );

            rewardedAds.put( adUnitId, result );
        }

        return result;
    }

    private MaxAdView retrieveAdView(final String adUnitId, final MaxAdFormat adFormat)
    {
        return retrieveAdView( adUnitId, adFormat, null, null );
    }

    private MaxAdView retrieveAdView(final String adUnitId, final MaxAdFormat adFormat, final String adViewPosition, Point adViewOffset)
    {
        MaxAdView result = adViews.get( adUnitId );
        if ( result == null && adViewPosition != null && adViewOffset != null )
        {
            result = new MaxAdView( adUnitId, adFormat, sdk, getCurrentActivity() );
            result.setListener( this );
            result.setRevenueListener( this );

            adViews.put( adUnitId, result );
            adViewPositions.put( adUnitId, adViewPosition );
            adViewOffsets.put( adUnitId, adViewOffset );

            // Allow pubs to pause auto-refresh immediately, by default.
            result.setExtraParameter( "allow_pause_auto_refresh_immediately", "true" );
        }

        return result;
    }

    private void positionAdView(MaxAd ad)
    {
        positionAdView( ad.getAdUnitId(), ad.getFormat() );
    }

    private void positionAdView(final String adUnitId, final MaxAdFormat adFormat)
    {
        getCurrentActivity().runOnUiThread( new Runnable()
        {
            @Override
            public void run()
            {
                final MaxAdView adView = retrieveAdView( adUnitId, adFormat );
                if ( adView == null )
                {
                    e( adFormat.getLabel() + " does not exist" );
                    return;
                }

                final RelativeLayout relativeLayout = (RelativeLayout) adView.getParent();
                if ( relativeLayout == null )
                {
                    e( adFormat.getLabel() + "'s parent does not exist" );
                    return;
                }

                final Rect windowRect = new Rect();
                relativeLayout.getWindowVisibleDisplayFrame( windowRect );

                final String adViewPosition = adViewPositions.get( adUnitId );
                final Point adViewOffset = adViewOffsets.get( adUnitId );
                final Insets insets = getSafeInsets();
                final boolean isAdaptiveBannerDisabled = disabledAdaptiveBannerAdUnitIds.contains( adUnitId );
                final boolean isWidthDpOverridden = adViewWidths.containsKey( adUnitId );

                //
                // Determine ad width
                //
                final int adViewWidthDp;

                // Check if publisher has overridden width as dp
                if ( isWidthDpOverridden )
                {
                    adViewWidthDp = adViewWidths.get( adUnitId );
                }
                // Top center / bottom center stretches full screen
                else if ( "top_center".equalsIgnoreCase( adViewPosition ) || "bottom_center".equalsIgnoreCase( adViewPosition ) )
                {
                    int adViewWidthPx = windowRect.width();
                    adViewWidthDp = AppLovinSdkUtils.pxToDp( getCurrentActivity(), adViewWidthPx );
                }
                // Else use standard widths of 320, 728, or 300
                else
                {
                    adViewWidthDp = adFormat.getSize().getWidth();
                }

                //
                // Determine ad height
                //
                final int adViewHeightDp;

                if ( ( adFormat == MaxAdFormat.BANNER || adFormat == MaxAdFormat.LEADER ) && !isAdaptiveBannerDisabled )
                {
                    adViewHeightDp = adFormat.getAdaptiveSize( adViewWidthDp, getCurrentActivity() ).getHeight();
                }
                else
                {
                    adViewHeightDp = adFormat.getSize().getHeight();
                }

                final int widthPx = AppLovinSdkUtils.dpToPx( getCurrentActivity(), adViewWidthDp );
                final int heightPx = AppLovinSdkUtils.dpToPx( getCurrentActivity(), adViewHeightDp );

                final RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) adView.getLayoutParams();
                params.height = heightPx;
                adView.setLayoutParams( params );

                // Parse gravity
                int gravity = 0;

                // Reset rotation, translation and margins so that the banner can be positioned again
                adView.setRotation( 0 );
                adView.setTranslationX( 0 );
                params.setMargins( 0, 0, 0, 0 );

                int marginLeft = insets.left + adViewOffset.x;
                int marginTop = insets.top + adViewOffset.y;
                int marginRight = insets.right;
                int marginBottom = insets.bottom;
                if ( "centered".equalsIgnoreCase( adViewPosition ) )
                {
                    gravity = Gravity.CENTER_VERTICAL | Gravity.CENTER_HORIZONTAL;

                    if ( MaxAdFormat.MREC == adFormat || isWidthDpOverridden )
                    {
                        params.width = widthPx;
                    }
                    else
                    {
                        params.width = RelativeLayout.LayoutParams.MATCH_PARENT;
                    }
                }
                else
                {
                    // Figure out vertical params
                    if ( adViewPosition.contains( "top" ) )
                    {
                        gravity = Gravity.TOP;
                    }
                    else if ( adViewPosition.contains( "bottom" ) )
                    {
                        gravity = Gravity.BOTTOM;
                    }

                    // Figure out horizontal params
                    if ( adViewPosition.contains( "center" ) )
                    {
                        gravity |= Gravity.CENTER_HORIZONTAL;

                        if ( MaxAdFormat.MREC == adFormat || isWidthDpOverridden )
                        {
                            params.width = widthPx;
                        }
                        else
                        {
                            params.width = RelativeLayout.LayoutParams.MATCH_PARENT;
                        }

                        // Check if the publisher wants the ad view to be vertical and update the position accordingly ('center_left' or 'center_right').
                        final boolean containsLeft = adViewPosition.contains( "left" );
                        final boolean containsRight = adViewPosition.contains( "right" );
                        if ( containsLeft || containsRight )
                        {
                            // First, center the ad view in the view.
                            gravity |= Gravity.CENTER_VERTICAL;

                            if ( MaxAdFormat.MREC == adFormat )
                            {
                                gravity |= adViewPosition.contains( "left" ) ? Gravity.LEFT : Gravity.RIGHT;
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
                                 *                  |   |           |
                                 *                  | ^ |   ^       |
                                 *                  | +-----+       |
                                 *                  Translation     |
                                 *                  |   |           |
                                 *                  |   |           |
                                 *                  +---+-----------+
                                 */

                                int windowWidth = windowRect.width() - insets.left - insets.right;
                                int windowHeight = windowRect.height() - insets.top - insets.bottom;
                                int longSide = Math.max( windowWidth, windowHeight );
                                int shortSide = Math.min( windowWidth, windowHeight );

                                // For banners, set the width to the height of the screen to span the ad across the screen after it is rotated.
                                // Android by default clips a view bounds if it goes over the size of the screen. We can overcome it by setting negative margins to match our required size.
                                // The margins should be negative in portrait to stretch the banner to match the height of the screen and positive in landscape to squish it to fit the shorter height.
                                int marginSign = ( windowHeight > windowWidth ) ? -1 : 1;
                                int margin = marginSign * ( longSide - shortSide ) / 2;
                                marginLeft += margin;
                                marginRight += margin;

                                // The view is now at the center of the screen and so is it's pivot point. Move its center such that when rotated, it snaps into the vertical position we need.
                                final int translationRaw = ( windowWidth / 2 ) - ( heightPx / 2 );
                                final int translationX = containsLeft ? -translationRaw : translationRaw;
                                adView.setTranslationX( translationX );

                                // We have the view's center in the correct position. Now rotate it to snap into place.
                                adView.setRotation( 90 );
                            }

                            // Hack alert: For the rotation and translation to be applied correctly, need to set the background color (Unity only, similar to what we do in Cross Promo).
                            relativeLayout.setBackgroundColor( Color.TRANSPARENT );
                        }
                    }
                    else
                    {
                        params.width = widthPx;

                        if ( adViewPosition.contains( "left" ) )
                        {
                            gravity |= Gravity.LEFT;
                        }
                        else if ( adViewPosition.contains( "right" ) )
                        {
                            gravity |= Gravity.RIGHT;
                        }
                    }
                }

                // Check if the publisher has set a banner background color, and if we should show a safe area background.
                // We only need to change safe area properties for banners and leaders.
                if ( MaxAdFormat.BANNER == adFormat || MaxAdFormat.LEADER == adFormat )
                {
                    if ( publisherBannerBackgroundColor != null )
                    {
                        FrameLayout.LayoutParams safeAreaLayoutParams = (FrameLayout.LayoutParams) safeAreaBackground.getLayoutParams();
                        int safeAreaBackgroundGravity = Gravity.CENTER_HORIZONTAL;
                        if ( "top_center".equals( adViewPosition ) )
                        {
                            safeAreaBackgroundGravity |= Gravity.TOP;

                            safeAreaLayoutParams.height = insets.top;
                            safeAreaLayoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;

                            safeAreaBackground.setVisibility( adView.getVisibility() );

                            // Remove left and right insets so that the banner spans full width when background color is set.
                            marginLeft -= insets.left;
                            marginRight -= insets.right;
                        }
                        else if ( "bottom_center".equals( adViewPosition ) )
                        {
                            safeAreaBackgroundGravity |= Gravity.BOTTOM;

                            safeAreaLayoutParams.height = insets.bottom;
                            safeAreaLayoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;

                            safeAreaBackground.setVisibility( adView.getVisibility() );

                            // Remove left and right insets so that the banner spans full width when background color is set.
                            marginLeft -= insets.left;
                            marginRight -= insets.right;
                        }
                        else
                        {
                            safeAreaBackground.setVisibility( View.GONE );
                        }

                        safeAreaLayoutParams.gravity = safeAreaBackgroundGravity;

                        safeAreaBackground.requestLayout();
                    }
                    else
                    {
                        safeAreaBackground.setVisibility( View.GONE );
                    }
                }

                params.setMargins( marginLeft, marginTop, marginRight, marginBottom );
                relativeLayout.setGravity( gravity );
            }
        } );
    }

    private static Insets getSafeInsets()
    {
        Insets insets = new Insets();
        if ( Build.VERSION.SDK_INT < Build.VERSION_CODES.P ) return insets;

        Window window = getCurrentActivity().getWindow();
        if ( window == null ) return insets;

        WindowInsets windowInsets = window.getDecorView().getRootWindowInsets();
        if ( windowInsets == null ) return insets;

        DisplayCutout displayCutout = windowInsets.getDisplayCutout();
        if ( displayCutout == null ) return insets;

        insets.left = displayCutout.getSafeInsetLeft();
        insets.top = displayCutout.getSafeInsetTop();
        insets.right = displayCutout.getSafeInsetRight();
        insets.bottom = displayCutout.getSafeInsetBottom();
        return insets;
    }

    protected static Map<String, String> deserializeParameters(final String serialized)
    {
        if ( !TextUtils.isEmpty( serialized ) )
        {
            try
            {
                return JsonUtils.toStringMap( JsonUtils.jsonObjectFromJsonString( serialized, new JSONObject() ) );
            }
            catch ( Throwable th )
            {
                e( "Failed to deserialize: (" + serialized + ") with exception: " + th );
                return Collections.emptyMap();
            }
        }
        else
        {
            return Collections.emptyMap();
        }
    }

    private MaxAdFormat getAdViewAdFormat(final String adUnitId)
    {
        if ( adViewAdFormats.containsKey( adUnitId ) )
        {
            return adViewAdFormats.get( adUnitId );
        }
        else
        {
            return getDeviceSpecificAdViewAdFormat();
        }
    }

    private static MaxAdFormat getDeviceSpecificAdViewAdFormat()
    {
        return AppLovinSdkUtils.isTablet( getCurrentActivity() ) ? MaxAdFormat.LEADER : MaxAdFormat.BANNER;
    }

    private static Activity getCurrentActivity()
    {
        Activity activity = currentActivity != null ? currentActivity.get() : null;

        if ( activity == null && godotActivity != null )
        {
            activity = godotActivity.get();
        }

        return activity;
    }

    private static Point getOffsetPixels(final float xDp, final float yDp, final Context context)
    {
        return new Point( AppLovinSdkUtils.dpToPx( context, (int) xDp ), AppLovinSdkUtils.dpToPx( context, (int) yDp ) );
    }

    private MaxAd getAd(final String adUnitId)
    {
        synchronized ( adInfoMapLock )
        {
            return adInfoMap.get( adUnitId );
        }
    }

    private static class SdkThreadFactory
            implements ThreadFactory
    {
        @Override
        public Thread newThread(Runnable r)
        {
            final Thread result = new Thread( r, "AppLovinSdk:AppLovinMAX-Godot-Plugin:shared" );
            result.setDaemon( true );
            result.setPriority( Thread.NORM_PRIORITY );
            result.setUncaughtExceptionHandler( new Thread.UncaughtExceptionHandler()
            {
                public void uncaughtException(Thread thread, Throwable th)
                {
                    Log.e( TAG, "Caught unhandled exception", th );
                }
            } );

            return result;
        }
    }
}
