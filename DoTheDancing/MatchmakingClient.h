//
//  MatchmakingClient.h
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class MatchmakingClient;

@protocol MatchmakingClientDelegate <NSObject>

- (void)matchmakingClientDidConnectToServer:(NSString *)peerID;
- (void)matchmakingClientDidDisconnectFromServer:(NSString *)peerID;


@optional
- (void)matchmakingClientDidReceiveNewConnectedPeersList:(NSString*)peerString;
- (void)matchmakingClientDidReceiveIndexOfRemovedClient:(NSInteger)peerIndex;

// PacketTypeStartDanceMoveDance
- (void)matchmakingClientStartDanceMoveDanceWithDanceMoveType:(DanceMoves)danceMoveType;

// PacketTypeSegueToDanceMoveSelection
- (void)matchmakingClientSegueToSelectDanceMove;

// PacketTypeSegueToDanceMoveInstructions
- (void)matchmakingClientSegueToInstructionsWithDanceMoveType:(DanceMoves)danceMoveType;


@end

@interface MatchmakingClient : NSObject <GKSessionDelegate>

@property (nonatomic) QuitReason quitReason;
@property (nonatomic, strong) GKSession *session;
@property (nonatomic, weak) id<MatchmakingClientDelegate> delegate;
@property (nonatomic, strong) NSString *serverPeerID;

- (void)startSearchingForServersWithSessionID:(NSString *)sessionID;
- (void)connectToServerWithPeerID:(NSString *)peerID;
- (void)disconnectFromServer;

@end
