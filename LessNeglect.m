//
//  LessNeglect.m
//  LessNeglectCocoa
//
//  Created by David Keegan on 10/29/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
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
    if((self = [super init])){
        self.magnitude = NSNotFound;
        self.timestamp = [NSDate date];        
    }
    return self;
}

- (NSDictionary *)parameters{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"event[name]"] = self.name;
    if(self.magnitude != NSNotFound){
        parameters[@"event[magnitude]"] = @(self.magnitude);
    }
    if(self.externalIdentifier){
        parameters[@"event[external_identifier]"] = self.externalIdentifier;
    }
    parameters[@"event[timestamp]"] = @([self.timestamp timeIntervalSince1970]);
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
    if((self = [super init])){
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
    parameters[@"event[timestamp]"] = @([self.timestamp timeIntervalSince1970]);    
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end

#pragma mark - Person
@implementation LNPerson

+ (id)personWithName:(NSString *)name andEmail:(NSString *)email{
    return [[[self class] alloc] initWithName:name andEmail:email];
}

- (void)updateProperties:(NSDictionary *)properties{
    NSMutableDictionary *mutableProperties = [self.properties mutableCopy];
    [mutableProperties addEntriesFromDictionary:properties];
    self.properties = [NSDictionary dictionaryWithDictionary:properties];
}

- (id)initWithName:(NSString *)name andEmail:(NSString *)email{
    if((self = [super init])){
        self.name = name;
        self.email = email;
    }
    return self;
}

- (void)setGravatarAvatar{
    NSString *email = [self.email lowercaseString];
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    const char *ptr = [email UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    NSMutableString *md5 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
		[md5 appendFormat:@"%02x", md5Buffer[i]];
    }

    NSString *url = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@", md5];
    [self updateProperties:@{LNPersonPropertyAvatarURL:url}];
}

- (NSDictionary *)parameters{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"person[email]"] = self.email;    
    if(self.name){
        parameters[@"person[name]"] = self.name;
    }
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

static NSString *kEventQueueName = @"com.lessneglect.eventqueue";

@interface LNQueuedEvent : NSObject <NSCoding>
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDictionary *parameters;
+ (id)queuedEventWithPath:(NSString *)path andParameters:(NSDictionary *)parameters;
@end

@implementation LNQueuedEvent

+ (id)queuedEventWithPath:(NSString *)path andParameters:(NSDictionary *)parameters{
    return [[[self class] alloc] initWithPath:path andParameters:parameters];
}

- (id)initWithPath:(NSString *)path andParameters:(NSDictionary *)parameters{
    if((self = [super init])){
        self.path = path;
        self.parameters = parameters;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    NSString *path = [aDecoder decodeObjectForKey:@"path"];
    NSDictionary *parameters = [aDecoder decodeObjectForKey:@"parameters"];
    return [self initWithPath:path andParameters:parameters];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.path forKey:@"path"];
    [aCoder encodeObject:self.parameters forKey:@"parameters"];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@ %@", self.path, self.parameters];
}

@end

@interface LNManager()
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *secret;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableSet *currentlySyncing;
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

- (id)init{
    if((self = [super init])){
        self.currentlySyncing = [NSMutableSet set];

        [[NSFileManager defaultManager] createDirectoryAtPath:[self queuedEventsDirectoryPath]
                                  withIntermediateDirectories:YES attributes:nil error:nil];

        [NSTimer scheduledTimerWithTimeInterval:5*60 target:self selector:@selector(postQueuedEvents)
                                       userInfo:nil repeats:YES];
    }
    return self;
}

- (NSString *)queuedEventsDirectoryPath{
    NSURL *applicationSupport =
    [[NSFileManager defaultManager]
     URLForDirectory:NSApplicationSupportDirectory
     inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    return [[applicationSupport path] stringByAppendingPathComponent:kEventQueueName];
}

- (void)postQueuedEvents{
    if(!self.code || !self.secret){
        return;
    }
    if([[self httpClient] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable){
        return;
    }
    
    __weak __typeof__(self) wself = self;
    [self dispatchOnSynchronousQueue:^{
        NSArray *eventFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self queuedEventsDirectoryPath] error:nil];
        if([eventFiles count] == 0){
            return;
        }

        NSMutableArray *filesAndProperties = [NSMutableArray arrayWithCapacity:[eventFiles count]];
        [eventFiles enumerateObjectsUsingBlock:^(NSString *eventFile, NSUInteger idx, BOOL *stop){
            if([eventFile hasSuffix:@"plist"]){
                NSString *identifier = [eventFile stringByDeletingPathExtension];
                if(![wself.currentlySyncing containsObject:identifier]){
                    NSString *eventFilePath = [[self queuedEventsDirectoryPath] stringByAppendingPathComponent:eventFile];
                    NSDictionary *properties = [[NSFileManager defaultManager] attributesOfItemAtPath:eventFilePath error:nil];
                    NSDate *modDate = [properties objectForKey:NSFileModificationDate];
                    [filesAndProperties addObject:@{@"path":eventFilePath, @"modData":modDate}];
                    [wself.currentlySyncing addObject:identifier];
                }
            }
        }];

        NSArray *sortedEventFiles =
        [filesAndProperties sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj2 objectForKey:@"modData"] compare:[obj1 objectForKey:@"modData"]];
        }];

        [sortedEventFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            NSString *eventFilePath = [obj objectForKey:@"path"];
            LNQueuedEvent *queuedEvent = (LNQueuedEvent *)[NSKeyedUnarchiver unarchiveObjectWithFile:eventFilePath];
            NSOperation *operation =
            [wself operationWithMethod:@"POST" path:queuedEvent.path parameters:queuedEvent.parameters
                    andCompletionBlock:^(id JSON, NSError *error){
                        NSAssert(!error, @"Request failed with error: %@", error);
                        [wself dispatchOnSynchronousQueue:^{
                            if([[JSON objectForKey:@"success"] boolValue]){
                                [[NSFileManager defaultManager] removeItemAtPath:eventFilePath error:nil];
                            }
                            NSString *identifier = [[eventFilePath lastPathComponent] stringByDeletingPathExtension];
                            [wself.currentlySyncing removeObject:identifier];
                        }];
                    }];
            [operation start];
        }];
    }];
}

- (void)addEventToQueueWithPath:(NSString *)path withParameters:(NSDictionary *)parameters{
    [self dispatchOnSynchronousQueue:^{     
        NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
        LNQueuedEvent *queuedEvent = [LNQueuedEvent queuedEventWithPath:path andParameters:parameters];
        NSString *eventFilePath = [[self queuedEventsDirectoryPath] stringByAppendingPathComponent:identifier];
        eventFilePath = [eventFilePath stringByAppendingPathExtension:@"plist"];
        [NSKeyedArchiver archiveRootObject:queuedEvent toFile:eventFilePath];
        if(self.logEvents){
            NSLog(@"%@: %@", NSStringFromClass([self class]), queuedEvent);
        }
    }];
}

- (void)dispatchOnSynchronousQueue:(void (^)())block{
    static dispatch_queue_t queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        queue = dispatch_queue_create([kEventQueueName UTF8String], DISPATCH_QUEUE_SERIAL);
    });
    dispatch_async(queue, block);
}

- (void)setCode:(NSString *)code andSecret:(NSString *)secret{
    self.code = code;
    self.secret = secret;
}

- (void)postEventForCurrentPerson:(LNEvents *)event{
    if(self.currentPerson == nil){
        return;
    }
    [self postEvent:event forPerson:self.currentPerson];
}

- (void)postEvent:(LNEvents *)event forPerson:(LNPerson *)person{
    NSParameterAssert(event);
    NSParameterAssert(person);
    NSMutableDictionary *parameters = [[event parameters] mutableCopy];
    [parameters addEntriesFromDictionary:[person parameters]];
    [self addEventToQueueWithPath:@"/api/v2/events" withParameters:parameters];
}

- (void)updateCurrentPerson{
    if(self.currentPerson == nil){
        return;
    }
    [self updatePerson:self.currentPerson];
}

- (void)updatePerson:(LNPerson *)person{
    NSParameterAssert(person);
    [self addEventToQueueWithPath:@"/api/v2/people" withParameters:[person parameters]];
}

- (AFHTTPClient *)httpClient{
    return [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://api.lessneglect.com"]];
}

- (NSOperation *)operationWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
                  andCompletionBlock:(void(^)(id JSON, NSError *error))completionBlock{
    NSAssert(self.code || self.secret, @"The code and secret must be set.");
    
    AFHTTPClient *httpClient = [self httpClient];
    [httpClient setAuthorizationHeaderWithUsername:self.code password:self.secret];
    NSURLRequest *request = [httpClient requestWithMethod:method path:path parameters:parameters];

    NSOperation *operation =
    [AFJSONRequestOperation
      JSONRequestOperationWithRequest:request
      success:^(NSURLRequest *blockRequest, NSHTTPURLResponse *response, id JSON){
        completionBlock(JSON, nil);
    } failure:^(NSURLRequest *blockRequest, NSHTTPURLResponse *response, NSError *error, id JSON){
        completionBlock(nil, error);
    }];
    return operation;
}

@end
