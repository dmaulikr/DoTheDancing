//
//  MatchmakingClient.h
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import <Foundation/Foundation.h>

@interface MatchmakingClient : NSObject <GKSessionDelegate>

@property (nonatomic, strong) GKSession *session;

- (void)startSearchingForServersWithSessionID:(NSString *)sessionID;

@end
