//
//  MACustomAdPlacer.h
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 3/17/22.
//

#import <AppLovinSDK/MAAdPlacer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This subclass of @c MAAdPlacer contains additional functionality that isn't necessarily needed for the use of @c MAAdPlacer on its own, i.e., auto-refresh and look-ahead.
 *
 * @warning @c MACustomAdPlacer should only be used via its subclasses, e.g., @c MACollectionViewAdPlacer and @c MATableViewAdPlacer, since it contains methods that must be implemented based on the specific UI component.
 */
@interface MACustomAdPlacer : MAAdPlacer

/**
 * The number of off-screen items after the last visible item to consider for ad placement in a content stream. This allows upcoming ad positions to be ready before they are visible to the user.
 *
 * This can be disabled by setting to 0. Defaults to 8.
 */
@property (nonatomic, assign) NSUInteger lookAhead;

/**
 * Allows updates to be made safely to a stream by temporarily disabling auto-reload during data modification.
 */
- (void)pauseForUpdates:(void (^)(void))updates;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
