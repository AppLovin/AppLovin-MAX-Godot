//
//  ALAtomicBoolean.h
//  AppLovinSDK
//
//  Created by Thomas So on 3/5/17.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * A boolean value that may be updated atomically.
 *
 * NOTE: This class is used by our adapters (ironSource), do not change API.
 */
@interface ALAtomicBoolean : NSObject

/**
 * Returns the current value.
 */
- (BOOL)get;

/**
 * Unconditionally sets to the given value.
 */
- (void)set:(BOOL)newValue;

/**
 * Atomically sets to the given value and returns the previous value.
 */
- (BOOL)getAndSet:(BOOL)newValue;

/**
 * Atomically sets the value to the given updated value if the current value == the expected value.
 *
 * @param expect The expected value.
 * @param update The new value.
 *
 * @return YES if successful. NO return indicates that the actual value was not equal to the expected value.
 */
- (BOOL)compareAndSet:(BOOL)expect update:(BOOL)update;

/**
 * Creates an instance with the default BOOL value.
 */
- (instancetype)initWithValue:(BOOL)initialValue;

@end

NS_ASSUME_NONNULL_END
