//
//  MACollectionViewAdPlacer.h
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 3/8/22.
//

#import <AppLovinSDK/MACustomAdPlacer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class loads and places native ads into a corresponding @c UICollectionView. The collection view's original data source and delegate methods are wrapped by this class in order to automatically insert ad items, while maintaining the existing collection view's behavior.
 *
 * @note If you're using storyboards, the collection view's "Estimate Size" must be set to "None".
 */
@interface MACollectionViewAdPlacer : MACustomAdPlacer

/**
 * Whether or not unfilled ad positions should be collapsed to appear hidden. Defaults to @c YES.
 *
 * The default behavior works best for collection views that have a single content item per row/column. If the collection view has multiple items per row/column, disabling this feature may prevent items from unexpected re-positioning, depending on configured content size and ad positions.
 */
@property (nonatomic, assign, getter=shouldCollapseEmptyAds) BOOL collapseEmptyAds;

/**
 * Initializes an ad placer for use with the provided collection view.
 *
 * @param collectionView A collection view to place ads in.
 * @param settings An ad placer settings object.
 */
+ (instancetype)placerWithCollectionView:(UICollectionView *)collectionView settings:(MAAdPlacerSettings *)settings;

- (instancetype)initWithSettings:(MAAdPlacerSettings *)settings NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
