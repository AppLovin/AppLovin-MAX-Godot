//
//  ALCMessage.h
//  AppLovinSDK
//
//  Created by Thomas So on 7/4/19.
//

#import <AppLovinSDK/ALCPublisher.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Class representing messages passed in the Communicator SDK.
 */
@interface ALCMessage : NSNotification

/**
 * The unique id of the message.
 */
@property (nonatomic, copy, readonly) NSString *uniqueIdentifier;

/**
 * The topic of the message.  A full list of supported topics may be found in ALCTopic.h.
 */
@property (nonatomic, copy, readonly) NSString *topic;

/**
 * The id of the publisher of the message.
 */
@property (nonatomic, copy, readonly) NSString *publisherIdentifier;

/**
 * The raw data of the message.
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *data;

/**
 * Initialize a message with data in a pre-determined format for a given topic.
 */
- (instancetype)initWithData:(NSDictionary<NSString *, id> *)data topic:(NSString *)topic fromPublisher:(id<ALCPublisher>)publisher;
- (instancetype)initWithName:(NSNotificationName)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
