//
//  LNAppDelegate.m
//  LNCocoaExample
//
//  Created by David Keegan on 10/29/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "LNAppDelegate.h"
#import "LessNeglect.h"

@implementation LNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[LNManager sharedInstance] setCode:@"<code>" andSecret:@"<secret>"];
    LNPerson *currentPerson = [LNPerson personWithName:@"Christopher Gooley" andEmail:@"gooley@lessneglect.com"];
    currentPerson.properties = @{LNPersonPropertyAvatarURL: @"https://foliohd.com/image/sqavatar/gooley.jpg"};
    [[LNManager sharedInstance] setCurrentPerson:currentPerson];

    // wizard step 1
//    LNActionEvent *registerEvent = [LNActionEvent eventWithName:LNEventActionRegistered];
//    [[LNManager sharedInstance] postEvent:registerEvent forCurrentPersonWithCompletionBlock:^(id JSON, NSError *error){
//        NSLog(@"%@", error ?: JSON);
//    }];

    // wizard step 2
//    LNActionEvent *uploadEvent = [LNActionEvent eventWithName:LNEventAppActivityUploaded(@"media")];
//    [uploadEvent addLinkWithName:@"thumbnail_url" andURL:[NSURL URLWithString:@"https://foliohd.com/image/square/100764.jpg"]];
//    [uploadEvent addLinkWithName:@"link_url" andURL:[NSURL URLWithString:@"https://foliohd.com/image/hd/100764.jpg"]];
//    [[LNManager sharedInstance] postEvent:uploadEvent forCurrentPersonWithCompletionBlock:^(id JSON, NSError *error){
//        NSLog(@"%@", error ?: JSON);
//    }];

    // wizard step 3
//    LNMessageEvent *messageEvent =
//    [LNMessageEvent messageEventWithBody:@"Help me, guys" andSubject:@"I can not figure out how to upload. Please help me."];
//    [[LNManager sharedInstance] postEvent:messageEvent forCurrentPersonWithCompletionBlock:^(id JSON, NSError *error){
//        NSLog(@"%@", error ?: JSON);
//    }];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
