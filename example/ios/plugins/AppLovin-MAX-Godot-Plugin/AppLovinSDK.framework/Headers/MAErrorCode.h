//
//  MAErrorCode.h
//  AppLovinSDK
//
//  Created by Thomas So on 5/9/21.
//

/**
 * This enum contains various error codes that the SDK can return when a MAX ad fails to load or display.
 */
typedef NS_ENUM(NSInteger, MAErrorCode)
{
    /**
     * This error code represents an error that could not be categorized into one of the other defined errors. See the message field in the error object for more details.
     */
    MAErrorCodeUnspecified = -1,
    
    /**
     * This error code indicates that MAX returned no eligible ads from any mediated networks for this app/device.
     */
    MAErrorCodeNoFill = 204,
    
    /**
     * This error code indicates that MAX returned eligible ads from mediated networks, but all ads failed to load. See the adLoadFailureInfo field in the error object for more details.
     */
    MAErrorCodeAdLoadFailed = -5001,
    
    /**
     * This error code indicates that the ad request failed due to a generic network error. See the message field in the error object for more details.
     */
    MAErrorCodeNetworkError = -1000,
    
    /**
     * This error code indicates that the ad request timed out due to a slow internet connection.
     */
    MAErrorCodeNetworkTimeout = -1001,
    
    /**
     * This error code indicates that the ad request failed because the device is not connected to the internet.
     */
    MAErrorCodeNoNetwork = -1009,
    
    /**
     * This error code indicates that you attempted to show a fullscreen ad while another fullscreen ad is still showing.
     */
    MAErrorCodeFullscreenAdAlreadyShowing = -23,
    
    /**
     * This error code indicates you are attempting to show a fullscreen ad before the one has been loaded.
     */
    MAErrorCodeFullscreenAdNotReady = -24,
    
    /**
     * This error code indicates you attempted to present a fullscreen ad from an invalid view controller.
     */
    MAErrorCodeFullscreenAdInvalidViewController = -25
};
