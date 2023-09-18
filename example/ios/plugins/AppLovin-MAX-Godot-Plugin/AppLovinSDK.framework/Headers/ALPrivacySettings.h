//
//  ALPrivacySettings.h
//  AppLovinSDK
//
//  Created by Basil Shikin on 3/26/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This class contains privacy settings for AppLovin.
 */
@interface ALPrivacySettings : NSObject

/**
 * Sets whether or not the user has provided consent for information-sharing with AppLovin.
 *
 * @param hasUserConsent @c YES if the user provided consent for information-sharing with AppLovin. @c NO by default.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#general-data-protection-regulation-(%E2%80%9Cgdpr%E2%80%9D)">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ General Data Protection Regulation ("GDPR")</a>
 */
+ (void)setHasUserConsent:(BOOL)hasUserConsent;

/**
 * Checks if the user has provided consent for information-sharing with AppLovin.
 *
 * @return @c YES if the user provided consent for information sharing. @c NO if the user declined to share information or the consent value has not been set (see @c isUserConsentSet).
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#general-data-protection-regulation-(%E2%80%9Cgdpr%E2%80%9D)">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ General Data Protection Regulation ("GDPR")</a>
 */
+ (BOOL)hasUserConsent;

/**
 * Checks if user has set consent for information sharing.
 *
 * @return @c YES if user has set a value of consent for information sharing.
 */
+ (BOOL)isUserConsentSet;

/**
 * Marks the user as age-restricted (i.e. under 16).
 *
 * @param isAgeRestrictedUser @c YES if the user is age-restricted (i.e. under 16).
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#children-data">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ Children Data</a>
 */
+ (void)setIsAgeRestrictedUser:(BOOL)isAgeRestrictedUser;

/**
 * Checks if the user is age-restricted.
 *
 * @return @c YES if the user is age-restricted. @c NO if the user is not age-restricted or the age-restriction value has not been set (see @c isAgeRestrictedUserSet).
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#children-data">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ Children Data</a>
 */
+ (BOOL)isAgeRestrictedUser;

/**
 * Checks if user has set its age restricted settings.
 *
 * @return @c YES if user has set its age restricted settings.
 */
+ (BOOL)isAgeRestrictedUserSet;

/**
 * Sets whether or not the user has opted out of the sale of their personal information.
 *
 * @param doNotSell @c YES if the user opted out of the sale of their personal information.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#california-consumer-privacy-act-(%E2%80%9Cccpa%E2%80%9D)">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ California Consumer Privacy Act ("CCPA")</a>
 */
+ (void)setDoNotSell:(BOOL)doNotSell;

/**
 * Checks if the user has opted out of the sale of their personal information.
 *
 * @return @c YES if the user opted out of the sale of their personal information. @c NO if the user opted in to the sale of their personal information or the value has not been set (see @c isDoNotSellSet).
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/privacy#california-consumer-privacy-act-(%E2%80%9Cccpa%E2%80%9D)">MAX Integration Guide ⇒ iOS ⇒ Privacy ⇒ California Consumer Privacy Act ("CCPA")</a>
 */
+ (BOOL)isDoNotSell;

/**
 * Checks if the user has set the option to sell their personal information.
 *
 * @return @c YES if user has chosen an option to sell their personal information.
 */
+ (BOOL)isDoNotSellSet;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
