//
//  MAAdReviewDelegate.h
//  AppLovinSDK
//
//  Created by Nana Amoah on 3/29/22.
//

@class MAAd;

NS_ASSUME_NONNULL_BEGIN

/**
 * This protocol defines a delegate to be notified when the Ad Review SDK successfully generates a creative id.
 */
@protocol MAAdReviewDelegate <NSObject>

/**
 * The SDK invokes this callback when the Ad Review SDK successfully generates a creative id.
 *
 * The SDK invokes this callback on the UI thread.
 *
 * @param creativeIdentifier The Ad Review creative id tied to the ad, if any. You can report creative issues to our Ad review team using this id.
 * @param ad                                     The ad for which the ad review event was detected.
 */
- (void)didGenerateCreativeIdentifier:(NSString *)creativeIdentifier forAd:(MAAd *)ad;

@end

NS_ASSUME_NONNULL_END
