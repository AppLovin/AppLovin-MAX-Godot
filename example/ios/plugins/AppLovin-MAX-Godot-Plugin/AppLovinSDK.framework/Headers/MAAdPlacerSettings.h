//
//  MAAdPlacerSettings.h
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 2/16/22.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This class contains settings to configure an Ad Placer.
 *
 * @c MAAdPlacerSettings must be initialized with a valid native ad unit identifier. Add fixed positions using @c addFixedPosition: or set the @c repeatingInterval before initializing an @c MAAdPlacer with the settings.
 */
@interface MAAdPlacerSettings : NSObject

/**
 * The ad unit identifier for loading native ads.
 */
@property (nonatomic, copy, readonly) NSString *adUnitIdentifier;

/**
 * The placement to tie the future ad events to.
 */
@property (nonatomic, copy, nullable) NSString *placement;

/**
 * The fixed index paths to place ads at in a stream in sorted order. Can be modified using @c addFixedPosition: and @c resetFixedPositions.
 */
@property (nonatomic, strong, readonly) NSOrderedSet<NSIndexPath *> *fixedPositions;

/**
 * An interval to repeatedly place ads at in a stream. A valid repeating interval is any value greater than or equal to 2. A value less than 2 will disable it.
 *
 * Repeating ads are added only in sections with fixed positions, after the last fixed position in each section. If no fixed positions are set, repeating ads are added to the first section starting after @c repeatingInterval items.
 */
@property (nonatomic, assign) NSUInteger repeatingInterval;

/**
 * The maximum number of ads in a stream. Defaults to 256.
 *
 * If a stream contains multiple sections, this determines the maximum number of ads per section.
 */
@property (nonatomic, assign) NSUInteger maximumAdCount;

/**
 * The maximum number of ads to start preloading for placement in a stream. Defaults to 4.
 */
@property (nonatomic, assign) NSUInteger maximumPreloadedAdCount;

/**
 * Returns true if the repeating interval has been set to a value greater than or equal to 2.
 */
@property (nonatomic, assign, readonly, getter=isRepeatingEnabled) BOOL repeatingEnabled;

/**
 * Whether the positioning info is valid, i.e., fixed positions or a valid repeating interval have been set.
 */
@property (nonatomic, assign, readonly, getter=hasValidPositioning) BOOL validPositioning;

/**
 * Add a fixed position for an ad in a stream.
 *
 * @param indexPath An index path to place an ad at.
 */
- (void)addFixedPosition:(NSIndexPath *)indexPath;

/**
 * Remove all fixed positions.
 */
- (void)resetFixedPositions;

/**
 * Initializes an @c MAAdPlacerSettings instance with a native ad unit identifier.
 *
 * @param adUnitIdentifier A native ad unit identifier.
 */
+ (instancetype)settingsWithAdUnitIdentifier:(NSString *)adUnitIdentifier;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
