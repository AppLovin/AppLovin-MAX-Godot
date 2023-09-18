//
//  ALTargetingData.h
//  sdk
//
//  Created by Basil on 9/18/12.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This enumeration represents content ratings for the ads shown to users.
 * They correspond to IQG Media Ratings.
 */
typedef NS_ENUM(NSInteger, ALAdContentRating)
{
    ALAdContentRatingNone,
    ALAdContentRatingAllAudiences,
    ALAdContentRatingEveryoneOverTwelve,
    ALAdContentRatingMatureAudiences
};

/**
 * This enumeration represents gender.
 */
typedef NS_ENUM(NSInteger, ALGender)
{
    ALGenderUnknown,
    ALGenderFemale,
    ALGenderMale,
    ALGenderOther
};

/**
 * This class allows you to provide user or app data that will improve how we target ads.
 */
@interface ALTargetingData : NSObject

/**
 * The year of birth of the user.
 * Set this property to @c nil to clear this value.
 */
@property (nonatomic, strong, nullable) NSNumber *yearOfBirth;

/**
 * The gender of the user.
 * Set this property to @c ALGenderUnknown to clear this value.
 */
@property (nonatomic, assign) ALGender gender;

/**
 * The maximum ad content rating shown to the user.
 * Set this property to @c ALAdContentRatingNone to clear this value.
 */
@property (nonatomic, assign) ALAdContentRating maximumAdContentRating;

/**
 * The email of the user.
 * Set this property to @c nil to clear this value.
 */
@property (nonatomic, copy, nullable) NSString *email;

/**
 * The phone number of the user. Do not include the country calling code.
 * Set this property to @c nil to clear this value.
 */
@property (nonatomic, copy, nullable) NSString *phoneNumber;

/**
 * The keywords describing the application.
 * Set this property to @c nil to clear this value.
 */
@property (nonatomic, copy, nullable) NSArray<NSString *> *keywords;

/**
 * The interests of the user.
 * Set this property to @c nil to clear this value.
 */
@property (nonatomic, copy, nullable) NSArray<NSString *> *interests;

/**
 * Clear all saved data from this class.
 */
- (void)clearAll;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
