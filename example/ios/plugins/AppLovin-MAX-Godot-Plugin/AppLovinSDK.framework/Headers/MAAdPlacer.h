//
//  MAAdPlacer.h
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 2/16/22.
//

#import <UIKit/UIKit.h>
#import <AppLovinSDK/MAAdPlacerSettings.h>

@class MAAd;
@class MANativeAdViewBinder;

NS_ASSUME_NONNULL_BEGIN

@protocol MAAdPlacerDelegate <NSObject>

@optional
- (void)didLoadAdAtIndexPath:(NSIndexPath *)indexPath;
- (void)didRemoveAdsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)didClickAd:(MAAd *)ad;
- (void)didPayRevenueForAd:(MAAd *)ad;

@end

/**
 * This class loads native ads and calculates ad positioning info within a content stream.
 *
 * @note If you're working with a @c UITableView or @c UICollectionView, you should consider using @c MATableViewPlacer or @c MACollectionViewAdPlacer respectively. If you wish to create an implementation for a custom UI component, you should use @c MAAdPlacer or subclass @c MACustomAdPlacer.
 *
 * @discussion Initialize with an @c MAAdPlacerSettings and call @c loadAds: as soon as possible to start queuing up ads to be placed into the stream. The ad placer decides which ad index paths to actually fill based on the currently visible or "fillable" index paths, which should be set using @c updateFillableIndexPaths: to reflect the present UI state. Upon insertion or removal of ads, the delegate will be informed via @c didLoadAdAtIndexPath: and @c didRemoveAdsAtIndexPaths: , which can in turn trigger any necessary UI updates.
 *
 * Use @c renderAdAtIndexPath: to render ads once they are inserted into its corresponding view. The ad placer should also be notified of modifications to the original data in the stream (i.e., insert, delete, move operations).
 */
@interface MAAdPlacer : NSObject

@property (nonatomic, weak, nullable) id<MAAdPlacerDelegate> delegate;

#pragma mark - Ad Rendering Properties

/**
 * The desired size for the ad view.
 *
 * If you're using default templates and this value is not set, ad views automatically size to 360x120 for "Small" and 360x300 for "Medium".
 */
@property (nonatomic, assign) CGSize adSize;

/**
 * The native ad view nib to use for rendering manual template ads.
 */
@property (nonatomic, strong, nullable) UINib *nativeAdViewNib;

/**
 * The native ad view binder to use for rendering manual template ads.
 */
@property (nonatomic, strong, nullable) MANativeAdViewBinder *nativeAdViewBinder;

#pragma mark - Ads

/**
 * Load MAX native ads for stream. Set @code -[MAAdPlacer delegate] @endcode to assign a delegate that should be notified about ad load state.
 */
- (void)loadAds;

/**
 * Clears all ads placed in the stream, as well as any ads queued up for placement.
 */
- (void)clearAds;

/**
 * Clears ads placed in specified sections.
 */
- (void)clearAdsInSections:(NSIndexSet *)sections;

/**
 * Clears ads placed after the specified index path in its corresponding section.
 *
 * @return An array of cleared ad index paths.
 */
- (NSArray<NSIndexPath *> *)clearAdsInSectionAfterIndexPath:(NSIndexPath *)indexPath;

/**
 * Whether an index path represents an ad position.
 */
- (BOOL)isAdIndexPath:(NSIndexPath *)indexPath;

/**
 * Whether an index path contains a placed ad.
 */
- (BOOL)isFilledIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns the size for an ad at a given index path. If an ad is not ready for that index path, returns @c CGSizeZero.
 *
 * If you're using default templates and @c adSize is not set, ad views automatically size to 360x120 for "Small" and 360x300 for "Medium". If the desired width is larger than the @c maximumWidth, the @c maximumWidth will be used while preserving the height for "Small" templates and the aspect ratio for "Medium". The size for manual templates will not be resized to fit.
 */
- (CGSize)sizeForAdAtIndexPath:(NSIndexPath *)indexPath withMaximumWidth:(CGFloat)maximumWidth;

/**
 * Renders an ad into the provided container view if an ad is loaded for that index path.
 */
- (void)renderAdAtIndexPath:(NSIndexPath *)indexPath inView:(UIView *)view;

#pragma mark - Info

/**
 * Updates the index paths to consider for placing ads. This is typically called with the list of visible index paths whenever it changes.
 */
- (void)updateFillableIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/**
 * Returns the number of items in a section after including inserted ads.
 *
 * @param originalNumberOfItems The original number of items in the section of the content stream.
 * @param section The section in the content stream.
 */
- (NSInteger)adjustedNumberOfItems:(NSInteger)originalNumberOfItems inSection:(NSInteger)section;

/**
 * Returns the index path of an item after accounting for inserted ads.
 *
 * @param indexPath The original index path of an item in the original content stream.
 */
- (NSIndexPath *)adjustedIndexPathForOriginalIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns the index path of an item in the original content stream.
 *
 * Ad index paths return nil since they do not have positions in the original stream.
 *
 * @param indexPath The adjusted index path of an item in the content stream with ads.
 */
- (nullable NSIndexPath *)originalIndexPathForAdjustedIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns the index paths of items after accounting for inserted ads.
 */
- (NSArray<NSIndexPath *> *)adjustedIndexPathsForOriginalIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/**
 * Returns the index paths of items in the original content stream.
 */
- (NSArray<NSIndexPath *> *)originalIndexPathsForAdjustedIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

#pragma mark - Item Updates

/**
 * Updates positioning info for the insertion of items.
 *
 * @param indexPaths An array of adjusted index paths for inserted items.
 */
- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/**
 * Updates positioning info for the deletion of items.
 *
 * @param indexPaths An array of adjusted index paths for deleted items.
 */
- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/**
 * Updates positioning info for moving an item.
 *
 * @param sourceIndexPath An adjusted index path for the item to be moved.
 * @param destinationIndexPath An adjusted index path that is the destination of the move.
 */
- (void)moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

#pragma mark - Section Updates

/**
 * Updates positioning info for inserting sections.
 *
 * @param sections An index set for positions where sections have been inserted.
 */
- (void)insertSections:(NSIndexSet *)sections;

/**
 * Updates positioning info for deleting sections.
 *
 * @param sections An index set for positions where sections have been deleting.
 */
- (void)deleteSections:(NSIndexSet *)sections;

/**
 * Updates positioning info for inserting sections.
 *
 * @param section The original index of the section.
 * @param newSection The destination index of the section.
 */
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;

/**
 * Initializes an ad placer object.
 *
 * @param settings An ad placer settings object.
 */
- (instancetype)initWithSettings:(MAAdPlacerSettings *)settings;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
