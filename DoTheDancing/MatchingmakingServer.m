//
//  MatchingmakingServer.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "MatchingmakingServer.h"

@implementation MatchingmakingServer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.maxClients = 8;
    }
    
    return self;
}

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID
{
	self.connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
    
	self.session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeServer];
	self.session.delegate = self;
	self.session.available = YES;
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	CCLOG(@"MatchmakingServer: peer %@ changed state %d", [session displayNameForPeer:peerID], state);
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	CCLOG(@"MatchmakingServer: connection request from peer %@", [session displayNameForPeer:peerID]);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	CCLOG(@"MatchmakingServer: connection with peer %@ failed %@", [session displayNameForPeer:peerID], error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	CCLOG(@"MatchmakingServer: session failed %@", error);
}

@end
