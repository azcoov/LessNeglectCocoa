//
//  LessNeglect.h
//  LessNeglectCocoa
//
//  Created by David Keegan on 10/29/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Person Properties
extern NSString *const LNPersonPropertyCreatedAt;
extern NSString *const LNPersonPropertyAvatarURL;
extern NSString *const LNPersonPropertyTwitter;
extern NSString *const LNPersonPropertyIsPaying;
extern NSString *const LNPersonPropertyAccountLevel;
extern NSString *const LNPersonPropertyAccountLevelName;
extern NSString *const LNPersonPropertyURL;

#pragma mark - Account Events
extern NSString *const LNEventActionRegistered;
extern NSString *const LNEventActionUpgraded;
extern NSString *const LNEventActionDeletedAccount;
extern NSString *LNEventActionPurchased(NSString *item);
extern NSString *const LNEventActionUpdatedAccount;

#pragma mark - User Events
extern NSString *const LNEventUserLoggedIn;
extern NSString *const LNEventUserLoggedOut;
extern NSString *const LNEventUserLoggedForgotPassword;
extern NSString *const LNEventUserLoggedChangedPassword;
extern NSString *const LNEventUserLoggedUpdatedProfile;

#pragma mark - App Activity
extern NSString *LNEventAppActivityCreated(NSString *item);
extern NSString *LNEventAppActivityUploaded(NSString *item);
extern NSString *LNEventAppActivityDeleted(NSString *item);
extern NSString *LNEventAppActivityModified(NSString *item);
extern NSString *LNEventAppActivityViewed(NSString *item);

#pragma mark - Events
@interface LNEvents : NSObject
@property (strong, nonatomic) NSString *name;
@property (nonatomic) NSUInteger magnitude;
+ (id)eventWithName:(NSString *)name;
- (id)initWithName:(NSString *)name;
@end

@interface LNActionEvent : LNEvents
@property (strong, nonatomic) NSString *note;
@property (strong, nonatomic) NSArray *links;
- (void)addLinkWithName:(NSString *)name andURL:(NSURL *)url;
@end

@interface LNMessageEvent : LNEvents
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;
+ (id)messageEventWithBody:(NSString *)body andSubject:(NSString *)subject;
- (id)initWithBody:(NSString *)body andSubject:(NSString *)subject;
@end

#pragma mark - Person
@interface LNPerson : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *externalIdentifier;
@property (strong, nonatomic) NSDictionary *properties;
+ (id)personWithName:(NSString *)name andEmail:(NSString *)email;
- (id)initWithName:(NSString *)name andEmail:(NSString *)email;
@end

#pragma mark - Action Link
@interface LNActionLink : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *url;
+ (id)actionLinkWithName:(NSString *)name andURL:(NSURL *)url;
- (id)initWithName:(NSString *)name andURL:(NSURL *)url;
@end

#pragma mark - Manager
@interface LNManager : NSObject

@property (strong, nonatomic) LNPerson *currentPerson;

+ (id)sharedInstance;

- (void)setCode:(NSString *)code andSecret:(NSString *)secret;

- (void)updatePerson:(LNPerson *)person
 withCompletionBlock:(void(^)(id JSON, NSError *error))completionBlock;
- (void)updateCurrentPersonWithCompletionBlock:(void(^)(id JSON, NSError *error))completionBlock;

- (void)postEvent:(LNEvents *)event forPerson:(LNPerson *)person
withCompletionBlock:(void(^)(id JSON, NSError *error))completionBlock;
- (void)postEvent:(LNEvents *)event forCurrentPersonWithCompletionBlock:(void(^)(id JSON, NSError *error))completionBlock;

@end
