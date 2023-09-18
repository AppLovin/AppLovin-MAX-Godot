//
//  MANativeAdView.h
//  AppLovinSDK
//
//  Created by Thomas So on 5/22/20.
//

#import <UIKit/UIKit.h>

@class MANativeAd;
@class MANativeAdViewBinder;

NS_ASSUME_NONNULL_BEGIN

/**
 * Base view class containing native ad templates for banners, leaders, and mrecs.
 *
 *  NOTE: The IBOutlets binding doesn't work in interface builder once the SDK is distributed as xcframeworks. Use the -[MANativeAdView bindViewsWithAdViewBinder:] to bind the native ad views.
 *  Alternatively, you can manually import this header file into your project to use interface builder outlets to bind the views.
 */
@interface MANativeAdView : UIView

/**
 * The native ad title label.
 */
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

/**
 * The native ad advertiser label.
 */
@property (nonatomic, weak) IBOutlet UILabel *advertiserLabel;

/**
 * The native ad body label.
 */
@property (nonatomic, weak) IBOutlet UILabel *bodyLabel;

/**
 * The native ad CTA button.
 */
@property (nonatomic, weak, nullable) IBOutlet UIButton *callToActionButton;

/**
 * The native ad icon ImageView.
 */
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;

/**
 * The native ad icon view.
 */
@property (nonatomic, weak) IBOutlet UIView *iconContentView __deprecated_msg("iconContentView is deprecated and will be removed in the future. Use iconImageView instead.");

/**
 * The native ad options view.
 */
@property (nonatomic, weak) IBOutlet UIView *optionsContentView;

/**
 * The native ad media view for holding an arbitrary content view provided by the 3rd-party SDK.
 */
@property (nonatomic, weak) IBOutlet UIView *mediaContentView;

/**
 * The native ad star rating view for holding the star rating view.
 */
@property (nonatomic, weak) IBOutlet UIView *starRatingContentView;

/**
 * Binds the native asset ad views to this native ad using view tags.
 */
- (void)bindViewsWithAdViewBinder:(MANativeAdViewBinder *)adViewBinder;

+ (instancetype)nativeAdViewFromAd:(MANativeAd *)ad;
+ (instancetype)nativeAdViewFromAd:(nullable MANativeAd *)ad withTemplate:(nullable NSString *)templateType;

@end

NS_ASSUME_NONNULL_END
