//
//  LNAppDelegate.m
//  LNCocoaExample
//
//  Created by David Keegan on 10/29/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "LNAppDelegate.h"
#import "LessNeglect.h"
#import "REComposeViewController.h"

@implementation LNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[LNManager sharedInstance] setCode:@"<code>" andSecret:@"<secret>"];
    [[LNManager sharedInstance] setLogEvents:YES]; // for debugging

    LNPerson *currentPerson = [LNPerson personWithName:@"Christopher Gooley" andEmail:@"gooley@lessneglect.com"];
    currentPerson.properties = @{LNPersonPropertyAvatarURL: @"https://foliohd.com/image/sqavatar/gooley.jpg"};
    [[LNManager sharedInstance] setCurrentPerson:currentPerson];

    // wizard step 1
    LNActionEvent *registerEvent = [LNActionEvent eventWithName:LNEventActionRegistered];
    [[LNManager sharedInstance] postEventForCurrentPerson:registerEvent];

    // wizard step 2
    LNActionEvent *uploadEvent = [LNActionEvent eventWithName:LNEventAppActivityUploaded(@"media")];
    [uploadEvent addLinkWithName:@"thumbnail_url" andURL:[NSURL URLWithString:@"https://foliohd.com/image/square/100764.jpg"]];
    [uploadEvent addLinkWithName:@"link_url" andURL:[NSURL URLWithString:@"https://foliohd.com/image/hd/100764.jpg"]];
    [[LNManager sharedInstance] postEventForCurrentPerson:uploadEvent];

    // wizard step 3
    LNMessageEvent *messageEvent =
    [LNMessageEvent messageEventWithBody:@"Help me, guys" andSubject:@"I can not figure out how to upload. Please help me."];
    [[LNManager sharedInstance] postEventForCurrentPerson:messageEvent];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UIViewController alloc] init];

    CGRect buttonRect = CGRectZero;
    buttonRect.size = CGSizeMake(200, 44);
    buttonRect.origin.x = round(CGRectGetMidX([[UIScreen mainScreen] bounds])-CGRectGetMidX(buttonRect));
    buttonRect.origin.y = round(CGRectGetMidY([[UIScreen mainScreen] bounds])-CGRectGetMidY(buttonRect));
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [messageButton setTitle:@"Send Feedback..." forState:UIControlStateNormal];
    [messageButton addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
    messageButton.frame = buttonRect;
    [self.window.rootViewController.view addSubview:messageButton];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)messageAction:(id)sender{
    REComposeViewController *composeViewController = [[REComposeViewController alloc] init];
    composeViewController.title = @"Feedback";
    composeViewController.text = @"Hi there!";
    composeViewController.completionHandler = ^(REComposeResult result){
        if(result == REComposeResultPosted){
            [[LNManager sharedInstance] postEventForCurrentPerson:
             [LNMessageEvent messageEventWithBody:composeViewController.text
                                       andSubject:composeViewController.title]];
        }
    };
    [self.window.rootViewController presentViewController:composeViewController animated:YES completion:nil];
}

@end
