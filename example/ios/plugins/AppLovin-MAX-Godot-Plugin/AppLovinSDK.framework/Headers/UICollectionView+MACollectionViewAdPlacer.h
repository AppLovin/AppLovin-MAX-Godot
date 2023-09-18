//
//  UICollectionView+MACollectionViewAdPlacer.h
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 3/8/22.
//

#import <UIKit/UIKit.h>

@class MACollectionViewAdPlacer;

NS_ASSUME_NONNULL_BEGIN

/**
 * When using an @c MACollectionViewAdPlacer, you should replace the usage of the original @c UICollectionView properties/methods in your code with the prefixed version from this category.
 * These methods help simplify your application logic by automatically returning "original" index paths (by accounting for added ad index paths in the stream) as well as serving to inform the ad placer of changes to its associated collection view.
 */
@interface UICollectionView (MACollectionViewAdPlacer)

/**
 * The ad placer associated with this collection view.
 *
 * This value is automatically set when initializing @c MACollectionViewAdPlacer.
 */
@property (nonatomic, weak, nullable) MACollectionViewAdPlacer *adPlacer;

/**
 * The object that acts as the original data source of the collection view.
 *
 * Initializing an @c MACollectionViewAdPlacer will replace the original data source. This property allows access to the original data source object if needed.
 */
@property (nonatomic, weak, nullable, setter=al_setDataSource:) id<UICollectionViewDataSource> al_dataSource;

/**
 * The object that acts as the original delegate of the collection view.
 *
 * Initializing an @c MACollectionViewAdPlacer will replace the original delegate. This property allows access to the original delegate object if needed.
 */
@property (nonatomic, weak, nullable, setter=al_setDelegate:) id<UICollectionViewDelegate> al_delegate;

#pragma mark - Creating Cells

/**
 * Dequeues a reusable cell object located by its identifier.
 *
 * @param identifier The reuse identifier for the specified cell. This parameter must not be @c nil.
 * @param indexPath The index path specifying the location of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the index path to perform additional configuration based on the cell’s position in the collection view.
 */
- (__kindof UICollectionViewCell *)al_dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Getting the State of the Collection View

/**
 * An array of visible non-ad cells currently displayed by the collection view.
 *
 * @return An array of @c UICollectionViewCell objects. If no cells are visible, this method returns an empty array.
 */
@property (nonatomic, readonly) NSArray<__kindof UICollectionViewCell *> *al_visibleCells;

#pragma mark - Inserting, Deleting, and Moving Items

/**
 * Inserts new items at the specified index paths, and notifies the associated ad placer.
 *
 * @param indexPaths An array of @c NSIndexPath objects, each of which contains a section index and item index at which to insert a new cell. This parameter must not be @c nil.
 */
- (void)al_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/**
 * Deletes the items at the specified index paths, and notifies the associated ad placer..
 *
 * @param indexPaths An array of @c NSIndexPath objects, each of which contains a section index and item index for the item you want to delete from the collection view. This parameter must not be @c nil.
 */
- (void)al_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/**
 * Moves an item from one location to another in the collection view, and notifies the associated ad placer.
 *
 * @param indexPath The index path of the item you want to move. This parameter must not be @c nil.
 * @param newIndexPath The index path of the item’s new location. This parameter must not be @c nil.
 */
- (void)al_moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

#pragma mark - Inserting, Deleting, and Moving Sections

/**
 * Inserts new sections at the specified indexes, and notifies the associated ad placer.
 *
 * @param sections An index set containing the indexes of the sections you want to insert. This parameter must not be @c nil.
 */
- (void)al_insertSections:(NSIndexSet *)sections;

/**
 * Deletes the sections at the specified indexes, and notifies the associated ad placer.
 *
 * @param sections The indexes of the sections you want to delete. This parameter must not be @c nil.
 */
- (void)al_deleteSections:(NSIndexSet *)sections;

/**
 * Moves a section from one location to another in the collection view, and notifies the associated ad placer.
 *
 * @param section The index of the section you want to move.
 * @param newSection The index in the collection view that is the destination of the move for the section. The existing section at that location moves up or down to an adjoining index position to make room for it.
 */
- (void)al_moveSection:(NSInteger)section toSection:(NSInteger)newSection;

#pragma mark - Selecting Cells

/**
 * The original index paths for the selected items.
 */
@property (nonatomic, readonly, nullable) NSArray<NSIndexPath *> *al_indexPathsForSelectedItems;

/**
 * Selects the item at the specified index path and optionally scrolls it into view.
 *
 * @param indexPath The index path of the item to select. Specifying @c nil for this parameter clears the current selection.
 * @param animated Specify @c YES to animate the change in the selection or @c NO to make the change
 * without animating it.
 * @param scrollPosition An option that specifies where the item should be positioned when scrolling
 * finishes.
 */
- (void)al_selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;

/**
 * Deselects the item at the specified index.
 *
 * @param indexPath The index path of the item to select. Specifying @c nil results in no change to the current selection.
 * @param animated  Specify @c YES to animate the change in the selection or @c NO to make the change without animating it.
 */
- (void)al_deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

#pragma mark - Locating Items and Views

/**
 * An array of the visible non-ad items in the collection view.
 */
@property (nonatomic, readonly) NSArray<NSIndexPath *> *al_indexPathsForVisibleItems;

/**
 * Gets the index path of the item at the specified point in the collection view.
 *
 * @param point A point in the collection view’s coordinate system.
 *
 * @return The index path of the item at the specified point or @c nil if an ad or no item was found at the specified point.
 */
- (NSIndexPath *)al_indexPathForItemAtPoint:(CGPoint)point;

/**
 * Gets the index path of the specified cell.
 *
 * @param cell The cell object whose index path you want.
 *
 * @return The index path of the cell or @c nil if the specified cell contains an ad or is not in the collection view.
 */
- (NSIndexPath *)al_indexPathForCell:(UICollectionViewCell *)cell;

/**
 * Gets the cell object at the index path you specify.
 *
 * @param indexPath The index path that specifies the section and item number of the cell.
 *
 * @return The cell object at the corresponding index path. In versions of iOS earlier than iOS 15, this method returns @c nil if the cell isn't visible or if @c indexPath is out of range. In iOS 15 and later, this method returns a non-nil cell if the collection view retains a prepared cell at the specified index path, even if the cell isn't currently visible.
 */
- (UICollectionViewCell *)al_cellForItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Getting Layout Information

/**
 * Gets the layout information for the item at the specified index path.
 *
 * @param indexPath The index path of the item.
 *
 * @return The layout attributes for the item or @c nil if no item exists at the specified path.
 */
- (UICollectionViewLayoutAttributes *)al_layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Scrolling an Item Into View

/**
 * Scrolls the collection view contents until the specified item is visible.
 *
 * @param indexPath The index path of the item to scroll into view.
 * @param scrollPosition An option that specifies where the item should be positioned when scrolling finishes. For a list of possible values, see @c UICollectionViewScrollPosition.
 * @param animated Specify @c YES to animate the scrolling behavior or @c NO to adjust the scroll view’s visible content immediately.
 */
- (void)al_scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

#pragma mark - Animating Multiple Changes to the Collection View

/**
 * Animates multiple insert, delete, reload, and move operations as a group.
 *
 * @param updates The block that performs the relevant insert, delete, reload, or move operations.
 * @param completion A completion handler block to execute when all of the operations are finished. This block takes a single Boolean parameter that contains the value YES if all of the related animations completed successfully or NO if they were interrupted. This parameter may be nil.
 */
- (void)al_performBatchUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^ _Nullable)(BOOL finished))completion;

#pragma mark - Reloading Content

/**
 * Reloads all of the data for the collection view.
 */
- (void)al_reloadData;

/**
 * Reloads the data in the specified sections of the collection view.
 *
 * @param sections The indexes of the sections to reload.
 */
- (void)al_reloadSections:(NSIndexSet *)sections;

/**
 * Reloads just the items at the specified index paths.
 *
 * @param indexPaths An array of @c NSIndexPath objects identifying the items you want to update.
 */
- (void)al_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

@end

NS_ASSUME_NONNULL_END
