//
//  MANativeAdViewBinder.h
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 11/26/21.
//

@class MANativeAdViewBinderBuilder;

NS_ASSUME_NONNULL_BEGIN

typedef void (^MANativeAdViewBinderBuilderBlock) (MANativeAdViewBinderBuilder *builder);

@interface MANativeAdViewBinderBuilder : NSObject

@property (nonatomic, assign) NSInteger titleLabelTag;
@property (nonatomic, assign) NSInteger advertiserLabelTag;
@property (nonatomic, assign) NSInteger bodyLabelTag;
@property (nonatomic, assign) NSInteger iconImageViewTag;
@property (nonatomic, assign) NSInteger optionsContentViewTag;
@property (nonatomic, assign) NSInteger starRatingContentViewTag;
@property (nonatomic, assign) NSInteger mediaContentViewTag;
@property (nonatomic, assign) NSInteger callToActionButtonTag;

@end

@interface MANativeAdViewBinder : NSObject

/**
 * A non-zero tag for the title label view to be rendered. The maximum length will be 50 characters.
 */
@property (nonatomic, assign, readonly) NSInteger titleLabelTag;

/**
 * A non-zero tag for advertiser label view to be rendered. The maximum length will be 25 characters.
 */
@property (nonatomic, assign, readonly) NSInteger advertiserLabelTag;

/**
 * A non-zero tag for body label view to be rendered. The maximum length will be 150 characters.
 */
@property (nonatomic, assign, readonly) NSInteger bodyLabelTag;

/**
 * A non-zero tag for icon image view to be rendered.
 */
@property (nonatomic, assign, readonly) NSInteger iconImageViewTag;

/**
 * A non-zero tag for options content view to be rendered.
 */
@property (nonatomic, assign, readonly) NSInteger optionsContentViewTag;

/**
 * A non-zero tag for star rating content view to be rendered.
 */
@property (nonatomic, assign, readonly) NSInteger starRatingContentViewTag;

/**
 * A non-zero tag for media content view to be rendered.
 */
@property (nonatomic, assign, readonly) NSInteger mediaContentViewTag;

/**
 * A non-zero tag for call to action button view to be rendered. The maximum length will be 15 characters.
 */
@property (nonatomic, assign, readonly) NSInteger callToActionButtonTag;

/**
 * Instantiates a @c MANativeAdViewBinder from a builder.
 */
- (instancetype)initWithBuilderBlock:(MANativeAdViewBinderBuilderBlock)builder;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
