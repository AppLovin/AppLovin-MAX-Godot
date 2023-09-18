//
//  MATableViewAdPlacer.h
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 2/18/22.
//

#import <AppLovinSDK/MACustomAdPlacer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class loads and places native ads into a corresponding @c UITableView. The table view's original data source and delegate methods are wrapped by this class in order to automatically insert ad rows, while maintaining the existing table view's behavior.
 */
@interface MATableViewAdPlacer : MACustomAdPlacer

/**
 * Initializes an ad placer for use with the provided table view.
 *
 * @param tableView A table view to place ads in.
 * @param settings An ad placer settings object.
 */
+ (instancetype)placerWithTableView:(UITableView *)tableView settings:(MAAdPlacerSettings *)settings;

- (instancetype)initWithSettings:(MAAdPlacerSettings *)settings NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
