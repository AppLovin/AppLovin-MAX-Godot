//
//  ALCEntity.h
//  AppLovinSDK
//
//  Created by Thomas So on 7/21/19.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol concerns an entity (publisher or subscriber) in the AppLovin pub/sub system.
 */
@protocol ALCEntity <NSObject>

/**
 * Unique identifier representing the entity (publisher or subscriber) in the AppLovin pub/sub system.
 * Currently used for debugging purposes only - so please provide an easily distinguishable identifier (e.g. "safedk").
 */
- (NSString *)communicatorIdentifier;

@end

NS_ASSUME_NONNULL_END
