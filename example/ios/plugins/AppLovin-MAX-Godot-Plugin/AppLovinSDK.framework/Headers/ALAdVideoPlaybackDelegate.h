//
//  ALAdVideoPlaybackDelegate.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

@class ALAd;
@class ALAdService;

NS_ASSUME_NONNULL_BEGIN

@protocol ALAdVideoPlaybackDelegate <NSObject>

/**
 * The SDK invokes this method when a video starts playing in an ad.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad  Ad in which video playback began.
 */
- (void)videoPlaybackBeganInAd:(ALAd *)ad;

/**
 * The SDK invokes this method when a video stops playing in an ad.
 *
 * The SDK invokes this method on the main UI thread.
 *
 * @param ad                Ad in which video playback ended.
 * @param percentPlayed     How much of the video was watched, as a percent, between 0 and 100.
 * @param wasFullyWatched   Whether or not the video was watched to 95% or more of completion.
 */
- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched;

@end

NS_ASSUME_NONNULL_END
