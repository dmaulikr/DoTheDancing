//
//  MatchmakingServer.h
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Packet.h"

@class MatchmakingServer;

@protocol MatchmakingServerDelegate <NSObject>

@optional
- (void)matchmakingServerClientDidConnect:(NSString *)peerID;
- (void)matchmakingServerClientDidDisconnect:(NSString *)peerID;
- (void)matchmakingServerSessionDidEnd;
- (void)matchmakingServerNoNetwork;

@end

@interface MatchmakingServer : NSObject <GKSessionDelegate>

@property (nonatomic) QuitReason quitReason;
@property (nonatomic) int maxClients;
@property (nonatomic, strong) NSMutableArray *connectedClients;
@property (nonatomic, strong) GKSession *session;
@property (nonatomic, weak) id<MatchmakingServerDelegate> delegate;

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID;
- (void)stopAcceptingConnections;
- (void)sendPacketToAllClients:(Packet *)packet;

@end
