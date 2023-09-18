//
//  UITableView+MATableViewAdPlacer.h
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 2/22/22.
//

#import <UIKit/UIKit.h>

@class MATableViewAdPlacer;

NS_ASSUME_NONNULL_BEGIN

/**
 * When using an @c MATableViewAdPlacer, you should replace the usage of the original @c UITableView properties/methods in your code with the prefixed version from this category.
 * These methods help simplify your application logic by automatically returning "original" index paths (by accounting for added ad index paths in the stream) as well as serving to inform the ad placer of changes to its associated table view.
 */
@interface UITableView (MATableViewAdPlacer)

/**
 * The ad placer associated with this collection view.
 *
 * This value is automatically set when initializing @c MATableViewAdPlacer.
 */
@property (nonatomic, weak, nullable) MATableViewAdPlacer *adPlacer;

/**
 * The object that acts as the original data source of the collection view.
 *
 * Initializing an @c MATableViewAdPlacer will replace the original data source. This property allows access to the original data source object if needed.
 */
@property (nonatomic, weak, nullable, setter=al_setDataSource:) id<UITableViewDataSource> al_dataSource;

/**
 * The object that acts as the original delegate of the collection view.
 *
 * Initializing an @c MATableViewAdPlacer will replace the original delegate. This property allows access to the original delegate object if needed.
 */
@property (nonatomic, weak, nullable, setter=al_setDelegate:) id<UITableViewDelegate> al_delegate;

#pragma mark - Recycling Table View Cells

/**
 * Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
 * @param identifier A string identifying the cell object to be reused. This parameter must not be nil.
 * @param indexPath The index path specifying the location of the cell. Always specify the index path provided to you by your data source object. This method uses the index path to perform additional configuration based on the cell’s position in the table view.
 */
- (__kindof UITableViewCell *)al_dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Getting Cells and Section-Based Views

/**
 * The non-ad table cells that are visible in the table view.
 */
@property (nonatomic, readonly) NSArray<__kindof UITableViewCell *> *al_visibleCells;

/**
 * An array of index paths, each identifying a visible non-ad row in the table view.
 */
@property (nonatomic, readonly, nullable) NSArray<NSIndexPath *> *al_indexPathsForVisibleRows;

/**
 * Returns the table cell at the index path you specify.
 *
 * @param indexPath The index path locating the row in the table view.
 *
 * @return The cell object at the corresponding index path. In versions of iOS earlier than iOS 15, this method returns @c nil if the cell isn’t visible or if @c indexPath is out of range. In iOS 15 and later, this method returns a non-nil cell if the table view retains a prepared cell at the specified index path, even if the cell isn’t currently visible.
 */
- (nullable __kindof UITableViewCell *)al_cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns an index path that represents the row and section of a specified table view cell.
 *
 * @param cell A cell object of the table view.
 *
 * @return An index path representing the row and section of the cell, or @c nil if the index path is invalid or is for an ad row.
 */
- (nullable NSIndexPath *)al_indexPathForCell:(UITableViewCell *)cell;

/**
 * Returns an index path that identifies the original row and section at the specified point.
 *
 * @param point A point in the local coordinate system of the table view (the table view’s bounds).
 *
 * @return An index path representing the row and section associated with point, or @c nil if the point is out of the bounds of any row.
 */
- (nullable NSIndexPath *)al_indexPathForRowAtPoint:(CGPoint)point;

/**
 * Returns an index path that identifies the row and section at the specified point.
 *
 * @param rect A rectangle defining an area of the table view in local coordinates.
 *
 * @return An array of @c NSIndexPath objects each representing a row and section index identifying a non-ad row within @c rect. Returns an empty array if there aren’t any rows to return.
 */
- (nullable NSArray<NSIndexPath *> *)al_indexPathsForRowsInRect:(CGRect)rect;

#pragma mark - Selecting Rows

/**
 * An original index path that identifies the row and section of the selected row.
 */
@property (nonatomic, readonly, nullable) NSIndexPath *al_indexPathForSelectedRow;

/**
 * The original index paths that represent the selected rows.
 */
@property (nonatomic, readonly, nullable) NSArray<NSIndexPath *> *al_indexPathsForSelectedRows;

/**
 * Selects a row in the table view that an index path identifies, optionally scrolling the row to a location in the table view.
 *
 * @param indexPath An index path identifying a row in the table view.
 * @param animated @c YES if you want to animate the selection and any change in position; @c NO if the change should be immediate.
 * @param scrollPosition A constant that identifies a relative position in the table view (top, middle, bottom) for the row when scrolling concludes. See @c UITableViewScrollPosition for descriptions of valid constants.
 */
- (void)al_selectRowAtIndexPath:(nullable NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;

/**
 * Deselects a row that an index path identifies, with an option to animate the deselection.
 *
 * @param indexPath An index path identifying a row in the table view.
 * @param animated @c YES if you want to animate the deselection, and @c NO if the change should be immediate.
 */
- (void)al_deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

#pragma mark - Inserting, Deleting, and Moving Rows
/**
 * Inserts rows in the table view at the locations that an array of index paths identifies, with an option to animate the insertion. Notifies the associated ad placer.
 *
 * @param indexPaths An array of index path objects, each representing a row index and section index that together identify a row in the table view.
 * @param animation A constant that either specifies the kind of animation to perform when inserting the cell or requests no animation. See @c UITableViewRowAnimation for descriptions of the constants.
 */
- (void)al_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

/**
 * Deletes the rows that an array of index paths identifies, with an option to animate the deletion. Notifies the associated ad placer.
 *
 * @param indexPaths An array of NSIndexPath objects identifying the rows to delete.
 * @param animation A constant that indicates how the deletion is to be animated, for example, fade out or slide out from the bottom. See @c UITableViewRowAnimation for descriptions of these constants.
 */
- (void)al_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

/**
 * Moves the row at a specified location to a destination location. Notifies the associated ad placer.
 *
 * @param indexPath An index path identifying the row to move.
 * @param newIndexPath An index path identifying the row that is the destination of the row at @c indexPath. The existing row at that location slides up or down to an adjoining index position to make room for it.
 */
- (void)al_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

#pragma mark - Inserting, Deleting, and Moving Sections

/**
 * Inserts one or more sections in the table view, with an option to animate the insertion. Notifies the associated ad placer.
 *
 * @param sections An index set that specifies the sections to insert in the table view. If a section already exists at the specified index location, it is moved down one index location.
 * @param animation A constant that indicates how the insertion is to be animated, for example, fade in or slide in from the left. See @c UITableViewRowAnimation for descriptions of these constants.
 */
- (void)al_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

/**
 * Deletes one or more sections in the table view, with an option to animate the deletion. Notifies the associated ad placer.
 *
 * @param sections An index set that specifies the sections to delete from the table view. If a section exists after the specified index location, it is moved up one index location.
 * @param animation A constant that either specifies the kind of animation to perform when deleting the section or requests no animation. See @c UITableViewRowAnimation for descriptions of the constants.
 */
- (void)al_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

/**
 * Moves a section to a new location in the table view.
 *
 * @param section The index of the section to move.
 * @param newSection The index in the table view that is the destination of the move for the section. The existing section at that location slides up or down to an adjoining index position to make room for it.
 */
- (void)al_moveSection:(NSInteger)section toSection:(NSInteger)newSection;

#pragma mark - Reloading and Updating

/**
 * Animates multiple insert, delete, reload, and move operations as a group.
 *
 * @param updates The block that performs the relevant insert, delete, reload, or move operations. In addition to modifying the table's rows, update your table's data source to reflect your changes. This block has no return value and takes no parameters.
 * @param completion A completion handler block to execute when all of the operations are finished.
 */
- (void)al_performBatchUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^ _Nullable)(BOOL finished))completion API_AVAILABLE(ios(11.0), tvos(11.0));

/**
 * Begins a series of method calls that insert, delete, or select rows and sections of the table view.
 */
- (void)al_beginUpdates;

/**
 * Concludes a series of method calls that insert, delete, select, or reload rows and sections of the table view.
 */
- (void)al_endUpdates;

/**
 * Reloads the rows and sections of the table view.
 */
- (void)al_reloadData;

/**
 * Reloads the specified sections using the provided animation effect.
 *
 * @param sections An index set identifying the sections to reload.
 * @param animation A constant that indicates how the reloading is to be animated, for example, fade out or slide out from the bottom. See @c UITableViewRowAnimation for descriptions of these constants. The animation constant affects the direction in which both the old and the new section rows slide. For example, if the animation constant is @c UITableViewRowAnimationRight, the old rows slide out to the right and the new cells slide in from the right.
 */
- (void)al_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

/**
 * Reloads the specified rows using the provided animation effect.
 *
 * @param indexPaths An array of @c NSIndexPath objects identifying the rows to reload.
 * @param animation A constant that indicates how the reloading is to be animated, for example, fade out or slide out from the bottom. See @c UITableViewRowAnimation for descriptions of these constants. The animation constant affects the direction in which both the old and the new rows slide. For example, if the animation constant is @c UITableViewRowAnimationRight, the old rows slide out to the right and the new cells slide in from the right.
 */
- (void)al_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

#pragma mark - Scrolling the Table View

/**
 * Scrolls through the table view until a row that an index path identifies is at a particular location on the screen.
 *
 * @param indexPath An index path that identifies a row in the table view by its row index and its section index. @c NSNotFound is a valid row index for scrolling to a section with zero rows.
 * @param scrollPosition A constant that identifies a relative position in the table view (top, middle, bottom) for row when scrolling concludes. See @c UITableViewScrollPosition for descriptions of valid constants.
 * @param animated @c YES if you want to animate the change in position; @c NO if it should be immediate.
 */
- (void)al_scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

#pragma mark - Getting the Drawing Areas for the Table

/**
 * Returns the drawing area for a row that an index path identifies.
 *
 * @param indexPath An index path object that identifies a row by its index and its section index.
 *
 * @return A rectangle defining the area in which the table view draws the row or CGRectZero if indexPath is invalid.
 */
- (CGRect)al_rectForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
