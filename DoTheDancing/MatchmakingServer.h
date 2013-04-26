//
//  MatchmakingServer.h
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import <Foundation/Foundation.h>

@interface MatchmakingServer : NSObject <GKSessionDelegate>

@property (nonatomic) int maxClients;
@property (nonatomic, strong) NSArray *connectedClients;
@property (nonatomic, strong) GKSession *session;

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID;

@end
