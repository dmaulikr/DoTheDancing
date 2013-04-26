//
//  MatchmakingClient.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "MatchmakingClient.h"

@implementation MatchmakingClient

- (void)startSearchingForServersWithSessionID:(NSString *)sessionID
{   
	self.session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeClient];
	self.session.delegate = self;
	self.session.available = YES;
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	CCLOG(@"MatchmakingClient: peer %@ changed state %d", [session displayNameForPeer:peerID], state);
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	CCLOG(@"MatchmakingClient: connection request from peer %@", [session displayNameForPeer:peerID]);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	CCLOG(@"MatchmakingClient: connection with peer %@ failed %@", [session displayNameForPeer:peerID], error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	CCLOG(@"MatchmakingClient: session failed %@", error);
}

@end
