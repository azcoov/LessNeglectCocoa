This library is an Objective-C wrapper for the [LessNeglect](http://lessneglect.com) service, it is working but still in development.

`LessNeglectCocoa` is built ontop of the award winning [AFNetworking](https://github.com/AFNetworking/AFNetworking).

```obj-c
[[LNManager sharedInstance] setCode:@"<code>" andSecret:@"<secret>"];
LNPerson *currentPerson = [LNPerson personWithName:@"Christopher Gooley" andEmail:@"gooley@lessneglect.com"];
currentPerson.properties = @{LNPersonPropertyAvatarURL: @"https://foliohd.com/image/sqavatar/gooley.jpg"};
[[LNManager sharedInstance] setCurrentPerson:currentPerson];

// wizard step 1
LNActionEvent *registerEvent = [LNActionEvent eventWithName:LNEventActionRegistered];
[[LNManager sharedInstance] postEvent:registerEvent forCurrentPersonWithCompletionBlock:^(id JSON, NSError *error){
    NSLog(@"%@", error ?: JSON);
}];

// wizard step 2
LNActionEvent *uploadEvent = [LNActionEvent eventWithName:LNEventAppActivityUploaded(@"media")];
[uploadEvent addLinkWithName:@"thumbnail_url" andURL:[NSURL URLWithString:@"https://foliohd.com/image/square/100764.jpg"]];
[uploadEvent addLinkWithName:@"link_url" andURL:[NSURL URLWithString:@"https://foliohd.com/image/hd/100764.jpg"]];
[[LNManager sharedInstance] postEvent:uploadEvent forCurrentPersonWithCompletionBlock:^(id JSON, NSError *error){
    NSLog(@"%@", error ?: JSON);
}];

// wizard step 3
LNMessageEvent *messageEvent =
[LNMessageEvent messageEventWithBody:@"Help me, guys" andSubject:@"I can not figure out how to upload. Please help me."];
[[LNManager sharedInstance] postEvent:messageEvent forCurrentPersonWithCompletionBlock:^(id JSON, NSError *error){
    NSLog(@"%@", error ?: JSON);
}];
```