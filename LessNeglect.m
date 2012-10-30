//
//  LessNeglect.m
//  LessNeglectCocoa
//
//  Created by David Keegan on 10/29/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "LessNeglect.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

NSString *actionAndItem(NSString *action, NSString *item){
    return [NSString stringWithFormat:@"%@:%@", action, item];
}

#pragma mark - Person Properties
NSString *const LNPersonPropertyCreatedAt = @"created_at";
NSString *const LNPersonPropertyAvatarURL = @"avatar_url";
NSString *const LNPersonPropertyTwitter = @"twitter";
NSString *const LNPersonPropertyIsPaying = @"is_paying";
NSString *const LNPersonPropertyAccountLevel = @"account_level";
NSString *const LNPersonPropertyAccountLevelName = @"account_level_name";
NSString *const LNPersonPropertyURL = @"url";

#pragma mark - Account Events
NSString *const LNEventActionRegistered = @"registered";
NSString *const LNEventActionUpgraded = @"upgraded";
NSString *const LNEventActionDeletedAccount = @"deleted-account";
NSString *LNEventActionPurchased(NSString *item){
    return actionAndItem(@"purchased", item);
}
NSString *const LNEventActionUpdatedAccount = @"updated-account";

#pragma mark - User Events
NSString *const LNEventUserLoggedIn = @"logged-in";
NSString *const LNEventUserLoggedOut = @"logged-out";
NSString *const LNEventUserLoggedForgotPassword = @"forgot-password";
NSString *const LNEventUserLoggedChangedPassword = @"changed-password";
NSString *const LNEventUserLoggedUpdatedProfile = @"updated-profile";

#pragma mark - App Activity
NSString *LNEventAppActivityCreated(NSString *item){
    return actionAndItem(@"created", item);
}
NSString *LNEventAppActivityUploaded(NSString *item){
    return actionAndItem(@"uploaded", item);    
}
NSString *LNEventAppActivityDeleted(NSString *item){
    return actionAndItem(@"deleted", item);    
}
NSString *LNEventAppActivityModified(NSString *item){
    return actionAndItem(@"modified", item);    
}
NSString *LNEventAppActivityViewed(NSString *item){
    return actionAndItem(@"viewed", item);
}

#pragma mark - Events
@implementation LNEvents

+ (id)eventWithName:(NSString *)name{
    return [[[self class] alloc] initWithName:name];    
}

- (id)initWithName:(NSString *)name{
    if((self = [self init])){
        self.name = name;
    }
    return self;
}

- (id)init{
    if(self = [super init]){
        self.magnitude = NSNotFound;
    }
    return self;
}

- (NSDictionary *)parameters{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"event[name]"] = self.name;
    if(self.magnitude != NSNotFound){
        parameters[@"event[magnitude]"] = @(self.magnitude);
    }
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end

@implementation LNActionEvent

- (void)addLinkWithName:(NSString *)name andURL:(NSURL *)url{
    NSMutableArray *links = [self.links mutableCopy];
    [links addObject:[LNActionLink actionLinkWithName:name andURL:url]];
    self.links = links;
}

- (NSDictionary *)parameters{
    NSMutableDictionary *parameters = [[super parameters] mutableCopy];
    parameters[@"event[klass]"] = @"actionevent";
    if(self.note){
        parameters[@"event[note]"] = self.note;
    }
    NSUInteger linkIndex = 0;
    for(id obj in self.links){
        if([obj isKindOfClass:[LNActionLink class]]){
            LNActionLink *actionLink = (LNActionLink *)obj;
            NSString *nameString = [NSString stringWithFormat:@"event[links][%lu][name]", (unsigned long)linkIndex];
            NSString *hrefString = [NSString stringWithFormat:@"event[links][%lu][href]", (unsigned long)linkIndex];
            parameters[nameString] = actionLink.name;
            parameters[hrefString] = actionLink.url;
            linkIndex++;
        }
    }
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end

@implementation LNMessageEvent

+ (id)messageEventWithBody:(NSString *)body andSubject:(NSString *)subject{
    return [[[self class] alloc] initWithBody:body andSubject:subject];
}

- (id)initWithBody:(NSString *)body andSubject:(NSString *)subject{
    if(self = [super init]){
        self.body = body;
        self.subject = subject;
    }
    return self;
}

- (NSDictionary *)parameters{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"event[klass]"] = @"message";
    parameters[@"event[body]"] = self.body;    
    if(self.subject){
        parameters[@"event[subject]"] = self.subject;
    }
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end

#pragma mark - Person
@implementation LNPerson

+ (id)personWithName:(NSString *)name andEmail:(NSString *)email{
    return [[[self class] alloc] initWithName:name andEmail:email];
}

- (id)initWithName:(NSString *)name andEmail:(NSString *)email{
    if((self = [super init])){
        self.name = name;
        self.email = email;
    }
    return self;
}

- (NSDictionary *)parameters{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"person[name]"] = self.name;
    parameters[@"person[email]"] = self.email;
    if(self.externalIdentifier){
        parameters[@"person[external_identifier]"] = self.externalIdentifier;
    }
    if([self.properties count]){
        [self.properties enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop){
            parameters[[NSString stringWithFormat:@"person[properties][%@]", key]] = obj;
        }];
    }
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end

#pragma mark - Action Link
@implementation LNActionLink

+ (id)actionLinkWithName:(NSString *)name andURL:(NSURL *)url{
    return [[[self class] alloc] initWithName:name andURL:url];
}

- (id)initWithName:(NSString *)name andURL:(NSURL *)url{
    if((self = [super init])){
        self.name = name;
        self.url = url;
    }
    return self;
}

@end

#pragma mark - Manager
@interface LNManager()
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *secret;
@end

@implementation LNManager

+ (id)sharedInstance{
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void)setCode:(NSString *)code andSecret:(NSString *)secret{
    self.code = code;
    self.secret = secret;
}

- (void)postEvent:(LNEvents *)event forCurrentPersonWithCompletionBlock:(void (^)(id, NSError *))completionBlock{
    [self postEvent:event forPerson:self.currentPerson withCompletionBlock:completionBlock];
}

- (void)postEvent:(LNEvents *)event forPerson:(LNPerson *)person
withCompletionBlock:(void(^)(id JSON, NSError *error))completionBlock{
    NSMutableDictionary *parameters = [[event parameters] mutableCopy];
    [parameters addEntriesFromDictionary:[person parameters]];
    [self requestWithMethod:@"POST" path:@"/api/v2/events" andParameters:parameters withCompletionBlock:completionBlock];
}

- (void)updateCurrentPersonWithCompletionBlock:(void(^)(id JSON, NSError *error))completionBlock{
    [self updatePerson:self.currentPerson withCompletionBlock:completionBlock];
}

- (void)updatePerson:(LNPerson *)person withCompletionBlock:(void(^)(id JSON, NSError *error))completionBlock{
    [self requestWithMethod:@"POST" path:@"/api/v2/people" andParameters:[person parameters] withCompletionBlock:completionBlock];
}

- (void)requestWithMethod:(NSString *)method path:(NSString *)path andParameters:(NSDictionary *)parameters
      withCompletionBlock:(void(^)(id JSON, NSError *error))completionBlock{
    NSAssert(self.code && self.secret, @"The code and secret must be set.");
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:
                                [NSURL URLWithString:@"https://api.lessneglect.com"]];
    [httpClient setAuthorizationHeaderWithUsername:self.code password:self.secret];
    NSURLRequest *request = [httpClient requestWithMethod:method path:path parameters:parameters];

    // The responce from the api is not application/json
    AFHTTPRequestOperation *operation =
    [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *blockOperation, id responseObject){
        completionBlock([NSJSONSerialization JSONObjectWithData:blockOperation.responseData options:0 error:nil], nil);
    } failure:^(AFHTTPRequestOperation *blockOperation, NSError *error){
        completionBlock(nil, error);
    }];
    [operation start];
    
//    [[AFJSONRequestOperation
//      JSONRequestOperationWithRequest:request
//      success:^(NSURLRequest *blockRequest, NSHTTPURLResponse *response, id JSON){
//        completionBlock(JSON, nil);
//    } failure:^(NSURLRequest *blockRequest, NSHTTPURLResponse *response, NSError *error, id JSON){
//        completionBlock(nil, error);
//    }] start];
}

@end
